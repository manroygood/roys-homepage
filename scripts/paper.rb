#!/usr/bin/env ruby
# Add a paper to the homepage and the CV, or update a preprint once it is published.
#
#   ruby scripts/paper.rb add 2503.19222 [--slug NAME] [--pdf FILE] [--no-pdf] [--no-cv]
#   ruby scripts/paper.rb add 10.1137/23M1627729 [--arxiv ID] [--slug NAME] [--pdf FILE] [--no-cv]
#   ruby scripts/paper.rb publish SLUG 10.1137/23M1627729 [--pdf FILE] [--no-cv]
#   ruby scripts/paper.rb cv
#
# `add` with an arXiv ID makes a preprint: content/publication/SLUG/{index.md,cite.bib,SLUG.pdf}
# and a "submitted" line at the top of the CV's refereed papers. `add` with a DOI makes an
# already-published paper. `publish` turns a preprint into a journal article from its DOI
# (Crossref metadata and BibTeX), rewriting the CV line in place. `add` and `publish` rebuild
# the CV and copy its PDF to static/files/ unless --no-cv is given; `cv` does only that.
#
# Nothing is committed. The CV lives outside git, so scholarly.ltx is backed up to
# scholarly.ltx.bak before each edit. Set CV_DIR to use a different CV folder.

require "json"
require "yaml"
require "date"
require "fileutils"
require "net/http"
require "uri"
require "rexml/document"
require "optparse"

Encoding.default_external = Encoding::UTF_8

ROOT = File.expand_path("..", __dir__)
PUB_DIR = File.join(ROOT, "content/publication")
AUTHORS_DIR = File.join(ROOT, "data/authors")
CV_DIR = File.expand_path(ENV.fetch("CV_DIR", "~/Documents/Employment/CV"))
CV_TEX = "CVgoodman.tex"
CV_PAPERS = File.join(CV_DIR, "scholarly.ltx")
CV_SITE_PDF = File.join(ROOT, "static/files/CVgoodman.pdf")
OWNER_CV_NAME = "R. H. Goodman"
REFEREED_HEADING = '\subrubric{Refereed Journal Papers}'

def die(msg) = abort("paper.rb: #{msg}")

def fetch(url, accept: nil, limit: 5)
  die("too many redirects for #{url}") if limit.zero?
  uri = URI(url)
  req = Net::HTTP::Get.new(uri)
  req["Accept"] = accept if accept
  req["User-Agent"] = "roys-homepage paper.rb (mailto:goodman@njit.edu)"
  res = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", read_timeout: 60) { |h| h.request(req) }
  case res
  when Net::HTTPRedirection then fetch(URI.join(url, res["location"]).to_s, accept: accept, limit: limit - 1)
  when Net::HTTPSuccess then res.body.force_encoding("UTF-8")
  else die("GET #{url} failed: #{res.code} #{res.message}")
  end
end

def squish(s) = s.to_s.gsub(/\s+/, " ").strip
def strip_tags(s) = squish(s.to_s.gsub(/<[^>]+>/, " ")).gsub(/\s+([,.;:)])/, '\1')

# ---------- metadata sources ----------

# Returns {title:, authors: [[given, family]], abstract:, date:, arxiv:, category:, doi:}
def arxiv_meta(id)
  xml = fetch("https://export.arxiv.org/api/query?id_list=#{id}")
  doc = REXML::Document.new(xml)
  entry = REXML::XPath.first(doc, "//xmlns:entry", "xmlns" => "http://www.w3.org/2005/Atom")
  die("arXiv has no paper #{id}") unless entry && entry.elements["title"]
  t = ->(name) { squish(entry.elements[name]&.text) }
  authors = entry.get_elements("author").map do |a|
    parts = squish(a.elements["name"].text).split(" ")
    [parts[0..-2].join(" "), parts[-1]]
  end
  {
    title: t.("title"),
    authors: authors,
    abstract: t.("summary"),
    date: DateTime.parse(t.("published")),
    arxiv: id,
    category: REXML::XPath.first(entry, "arxiv:primary_category", "arxiv" => "http://arxiv.org/schemas/atom")&.attributes&.[]("term"),
    doi: squish(REXML::XPath.first(entry, "arxiv:doi", "arxiv" => "http://arxiv.org/schemas/atom")&.text).then { _1.empty? ? nil : _1 },
  }
end

# Returns {title:, authors:, abstract:, date:, journal:, short_journal:, volume:, issue:, pages:, doi:, url:}
def crossref_meta(doi)
  m = JSON.parse(fetch("https://api.crossref.org/works/#{URI.encode_www_form_component(doi)}"))["message"]
  parts = (m["published-online"] || m["published-print"] || m["published"] || m["issued"])["date-parts"][0]
  {
    title: strip_tags(m["title"]&.first),
    authors: (m["author"] || []).map { [squish(_1["given"]), squish(_1["family"])] },
    abstract: strip_tags(m["abstract"].to_s.sub(/\A\s*<jats:title>.*?<\/jats:title>/m, "")),
    date: Date.new(parts[0], parts[1] || 1, parts[2] || 1),
    journal: strip_tags(m["container-title"]&.first),
    short_journal: strip_tags(m["short-container-title"]&.first),
    volume: m["volume"],
    issue: m["issue"],
    pages: (m["page"] || m["article-number"])&.tr("-", "–"),
    doi: doi,
    url: "https://doi.org/#{doi}",
  }
end

def crossref_bibtex(doi, key)
  bib = squish(fetch("https://doi.org/#{doi}", accept: "application/x-bibtex"))
  bib = bib.sub(/\A@(\w+)\{[^,]*,/) { "@#{$1}{#{key}," }.gsub(/(?<!\\)&/, "\\\\&").gsub("–", "--")
  # One field per line.
  bib.gsub(/,\s*(\w+)=/) { ",\n\t#{$1} = " }.sub(/\s*\}\z/, "\n}") + "\n"
end

# ---------- authors ----------

def author_profiles
  Dir[File.join(AUTHORS_DIR, "*.yaml")].map do |f|
    y = YAML.safe_load_file(f)
    n = y["name"] || {}
    { slug: y["slug"] || File.basename(f, ".yaml"), given: n["given"].to_s, family: n["family"].to_s }
  end
end

def ascii_fold(s) = s.scrub("").unicode_normalize(:nfkd).gsub(/\p{Mn}/, "").downcase

# Map [given, family] to a data/authors slug, matching family name and first initial.
def author_slug(given, family, profiles)
  hit = profiles.find do |p|
    ascii_fold(p[:family]) == ascii_fold(family) && ascii_fold(p[:given])[0] == ascii_fold(given)[0]
  end
  hit&.dig(:slug)
end

def cv_name(given, family, slug)
  return OWNER_CV_NAME if slug == "admin"
  initials = given.split(/\s+/).map { |g| g.split("-").map { "#{_1[0]}." }.join("-") }.join(" ")
  "#{initials} #{family}".strip
end

def cv_author_list(names)
  return names.join if names.size < 2
  return names.join(" and ") if names.size == 2
  "#{names[0..-2].join(", ")}, and #{names[-1]}"
end

# ---------- page files ----------

def slugify(title)
  stop = %w[a an the of in on for and to with via from by its their using]
  words = ascii_fold(title).gsub(/[^a-z0-9\s-]/, " ").split.reject { stop.include?(_1) }
  words.first(4).join("-")
end

def q(s) = s.to_s.to_json # JSON strings are valid YAML double-quoted scalars

def front_matter(meta, slugs_or_names, published:)
  lines = ["---", "title: #{q(meta[:title])}"]
  lines << "date: #{meta[:date].strftime("%Y-%m-%d")}"
  lines << "publishDate: #{Date.today.strftime("%Y-%m-%d")}"
  lines << "authors:"
  slugs_or_names.each { lines << "  - #{q(_1)}" }
  lines << "publication_types:"
  lines << "  - #{published ? "article-journal" : "article"}"
  lines << "publication:"
  if published
    lines << "  name: #{q(meta[:journal])}"
    lines << "  short_name: #{q(meta[:short_journal])}" unless meta[:short_journal].to_s.empty?
    %i[volume issue pages].each { |k| lines << "  #{k}: #{q(meta[k])}" if meta[k] }
  else
    lines << "  name: #{q("arXiv preprint arXiv:#{meta[:arxiv]}")}"
  end
  lines << "abstract: #{q(meta[:abstract])}"
  lines << "summary: \"\""
  lines << "tags: []"
  lines << "categories:"
  lines << "  - published"
  lines << "featured: false"
  lines << "links:"
  if published
    lines << "  - name: Journal"
    lines << "    url: #{meta[:url]}"
  end
  if meta[:arxiv]
    lines << "  - name: arXiv"
    lines << "    url: https://arxiv.org/abs/#{meta[:arxiv]}"
  end
  lines << "url_pdf: \"\""
  lines << "url_code: \"\""
  lines << "---"
  lines.join("\n") + "\n"
end

def arxiv_bibtex(meta, key)
  <<~BIB
    @misc{#{key},
      title         = {#{meta[:title]}},
      author        = {#{meta[:authors].map { _1.join(" ") }.join(" and ")}},
      year          = {#{meta[:date].year}},
      eprint        = {#{meta[:arxiv]}},
      archiveprefix = {arXiv},
      primaryclass  = {#{meta[:category]}},
      url           = {https://arxiv.org/abs/#{meta[:arxiv]}}
    }
  BIB
end

def split_page(path)
  text = File.read(path)
  m = text.match(/\A---[ \t]*\n(.*?)\n---[ \t]*\n(.*)\z/m) or die("#{path} has no YAML front matter")
  [YAML.safe_load(m[1], permitted_classes: [Date, Time]), m[2]]
end

def stringify_dates(obj)
  case obj
  when Hash then obj.transform_values { stringify_dates(_1) }
  when Array then obj.map { stringify_dates(_1) }
  when Time, DateTime then obj.iso8601
  when Date then obj.strftime("%Y-%m-%d")
  else obj
  end
end

def write_page(path, fm, body)
  yaml = YAML.dump(stringify_dates(fm), line_width: -1).sub(/\A---\n/, "")
  File.write(path, "---\n#{yaml}---\n#{body}")
end

# ---------- CV ----------

def norm_title(s) = ascii_fold(s.to_s).gsub(/\\[a-z]+|[^a-z0-9]/, "")

def edit_cv
  die("CV not found at #{CV_PAPERS} (set CV_DIR)") unless File.exist?(CV_PAPERS)
  text = File.read(CV_PAPERS)
  new_text = yield(text)
  return if new_text == text
  FileUtils.cp(CV_PAPERS, "#{CV_PAPERS}.bak")
  File.write(CV_PAPERS, new_text)
  puts "Updated #{CV_PAPERS} (backup in scholarly.ltx.bak)"
end

def cv_add_preprint(meta, cv_names)
  line = "\\paper{#{meta[:date].year}}{#{cv_author_list(cv_names)}, \\emph{#{meta[:title]}}, submitted.}"
  edit_cv do |text|
    if text.lines.any? { |l| l.include?("\\paper") && norm_title(l).include?(norm_title(meta[:title])) }
      puts "CV already lists this paper; left it alone."
      next text
    end
    text.include?(REFEREED_HEADING) or die("no #{REFEREED_HEADING} in #{CV_PAPERS}")
    puts "CV line: #{line}"
    text.sub(REFEREED_HEADING) { "#{REFEREED_HEADING}\n#{line}" }
  end
end

def cv_publish(meta, cv_names)
  venue = [meta[:short_journal].to_s.empty? ? meta[:journal] : meta[:short_journal], meta[:volume], meta[:pages]&.tr("–", "-")&.sub("-", "--")].compact.join(", ")
  edit_cv do |text|
    lines = text.lines
    i = lines.index { |l| l.include?("\\paper") && norm_title(l).include?(norm_title(meta[:title])) }
    if i
      old = lines[i]
      title = old[/\\emph\{((?:[^{}]|\{[^{}]*\})*)\}/, 1] || meta[:title]
      lines[i] = "\\paper{#{meta[:date].year}}{#{cv_author_list(cv_names)}, \\emph{#{title}}, #{venue}.}\n"
      puts "CV line was: #{old.strip}\nCV line now: #{lines[i].strip}"
      lines.join
    else
      line = "\\paper{#{meta[:date].year}}{#{cv_author_list(cv_names)}, \\emph{#{meta[:title]}}, #{venue}.}"
      puts "Could not find the paper in the CV by title, so added it at the top:\n#{line}"
      text.sub(REFEREED_HEADING) { "#{REFEREED_HEADING}\n#{line}" }
    end
  end
end

def rebuild_cv
  Dir.chdir(CV_DIR) do
    ok = system("latexmk", "-pdf", "-interaction=nonstopmode", "-silent", CV_TEX)
    die("LaTeX failed; see #{File.join(CV_DIR, "CVgoodman.log")}") unless ok
  end
  FileUtils.cp(File.join(CV_DIR, "CVgoodman.pdf"), CV_SITE_PDF)
  puts "Rebuilt the CV and copied it to static/files/CVgoodman.pdf"
end

# ---------- commands ----------

def resolve_authors(meta)
  profiles = author_profiles
  meta[:authors].map do |given, family|
    slug = author_slug(given, family, profiles)
    puts "  #{given} #{family} -> #{slug || "(no author profile; listed by name)"}"
    [slug || "#{given} #{family}", cv_name(given, family, slug)]
  end.transpose
end

def add_pdf(dir, slug, opts, arxiv)
  dest = File.join(dir, "#{slug}.pdf")
  if opts[:pdf]
    FileUtils.cp(opts[:pdf], dest)
  elsif arxiv && !opts[:no_pdf]
    File.binwrite(dest, fetch("https://arxiv.org/pdf/#{arxiv}"))
  else
    return
  end
  puts "Saved #{dest.delete_prefix(ROOT + "/")}"
end

def cmd_add(id, opts)
  doi = id.match?(%r{\A10\.\d+/}) ? id : nil
  arxiv = doi ? nil : id.sub(%r{\A(https?://arxiv\.org/abs/|arXiv:)}i, "").sub(/v\d+\z/, "")
  meta = doi ? crossref_meta(doi) : arxiv_meta(arxiv)
  if doi && opts[:arxiv]
    pre = arxiv_meta(opts[:arxiv].sub(/v\d+\z/, ""))
    meta[:arxiv] = pre[:arxiv]
    meta[:abstract] = pre[:abstract] if meta[:abstract].empty?
  end
  slug = opts[:slug] || slugify(meta[:title])
  dir = File.join(PUB_DIR, slug)
  die("#{dir.delete_prefix(ROOT + "/")} already exists; pick another --slug") if Dir.exist?(dir)
  puts "#{meta[:title]}\nAuthors:"
  page_authors, cv_names = resolve_authors(meta)
  page_authors.include?("admin") or warn("paper.rb: warning: no author matched Roy (admin)")

  FileUtils.mkdir_p(dir)
  File.write(File.join(dir, "index.md"), front_matter(meta, page_authors, published: !!doi))
  File.write(File.join(dir, "cite.bib"), doi ? crossref_bibtex(doi, slug) : arxiv_bibtex(meta, slug))
  add_pdf(dir, slug, opts, arxiv)
  puts "Created content/publication/#{slug}/"
  puts "arXiv also lists DOI #{meta[:doi]}; run `publish #{slug} #{meta[:doi]}` if it is the journal version." if arxiv && meta[:doi]

  return if opts[:no_cv]
  doi ? cv_publish(meta, cv_names) : cv_add_preprint(meta, cv_names)
  rebuild_cv
end

def cmd_publish(slug, doi, opts)
  path = File.join(PUB_DIR, slug, "index.md")
  die("no page at #{path}") unless File.exist?(path)
  meta = crossref_meta(doi)
  fm, body = split_page(path)
  puts "#{meta[:title]}\n  in #{meta[:journal]} #{meta[:volume]}, #{meta[:pages]} (#{meta[:date]})\nAuthors:"
  _, cv_names = resolve_authors(meta)

  fm["date"] = meta[:date]
  fm["publication_types"] = ["article-journal"]
  fm["publication"] = { "name" => meta[:journal], "short_name" => meta[:short_journal],
                        "volume" => meta[:volume], "issue" => meta[:issue], "pages" => meta[:pages] }
                      .reject { |_, v| v.to_s.empty? }
  fm.delete("doi") if fm["doi"].to_s.empty?
  links = (fm["links"] || []).reject { |l| %w[journal doi].include?(l["name"].to_s.downcase) }
  fm["links"] = [{ "name" => "Journal", "url" => meta[:url] }] + links
  fm["abstract"] = meta[:abstract] if fm["abstract"].to_s.empty? && !meta[:abstract].empty?
  write_page(path, fm, body)
  File.write(File.join(PUB_DIR, slug, "cite.bib"), crossref_bibtex(doi, slug))
  if opts[:pdf]
    old = Dir[File.join(PUB_DIR, slug, "*.pdf")]
    add_pdf(File.join(PUB_DIR, slug), slug, opts, nil)
    puts "Other PDFs in the folder, check which should stay: #{old.map { File.basename(_1) }.join(", ")}" if old.size > 1
  end
  puts "Updated content/publication/#{slug}/ to the published version"

  return if opts[:no_cv]
  cv_publish(meta, cv_names)
  rebuild_cv
end

opts = {}
parser = OptionParser.new do |o|
  o.banner = "usage: paper.rb add ARXIV_ID|DOI [options] | publish SLUG DOI [options] | cv"
  o.on("--slug NAME", "folder name under content/publication") { opts[:slug] = _1 }
  o.on("--pdf FILE", "use this PDF instead of downloading from arXiv") { opts[:pdf] = File.expand_path(_1) }
  o.on("--arxiv ID", "with add DOI: also link this arXiv preprint (and use its abstract)") { opts[:arxiv] = _1 }
  o.on("--no-pdf", "don't download the arXiv PDF") { opts[:no_pdf] = true }
  o.on("--no-cv", "don't touch or rebuild the CV") { opts[:no_cv] = true }
end
args = parser.parse(ARGV)
case args
in ["add", id] then cmd_add(id, opts)
in ["publish", slug, doi] then cmd_publish(slug, doi.sub(%r{\Ahttps?://(dx\.)?doi\.org/}, ""), opts)
in ["cv"] then rebuild_cv
else abort(parser.help)
end
