# Roy Goodman's homepage

Source for [roygoodman.net](https://roygoodman.net), the academic homepage of Roy Goodman
(Department of Mathematical Sciences, New Jersey Institute of Technology): research,
publications, talks, teaching, students and CV.

The site is built with [Hugo](https://gohugo.io) on the [HugoBlox](https://github.com/HugoBlox/kit)
Academic CV template (Tailwind CSS). It replaces the older Wowchemy/Bootstrap site in
[manroygood/roy-goodman](https://github.com/manroygood/roy-goodman), and was migrated in
October 2026 to look as much like that site as possible.

## Building and deploying

Requirements: Hugo extended **0.167 or newer** (0.162.0 has a bug that breaks this site), Node, and pnpm.

```bash
pnpm install
hugo server          # preview at http://localhost:1313
```

Netlify builds the site from `main` using `netlify.toml` (Hugo 0.168.0, then Pagefind for search).
Pushing to `main` deploys it.

## Layout of the content

| Folder | What it holds |
|---|---|
| `content/publication/` | One folder per paper: `index.md`, `cite.bib`, the PDF and `featured.*` |
| `content/event/` | Talks |
| `content/post/` | Blog posts |
| `content/course/` | Course pages, including archived ones |
| `content/papers.md`, `teaching.md`, `students.md`, `other.md` | Landing pages built from blocks |
| `data/authors/*.yaml` | Profiles for Roy (`admin`) and co-authors and students |
| `static/files/CVgoodman.pdf` | The CV, built from LaTeX elsewhere (see below) |

The folder names (`publication`, `event`, `post`, `course`) and slugs match the old site, so its URLs keep working.

## Adding a paper

`scripts/paper.rb` (plain Ruby, no gems) creates a publication page and the CV entry from an arXiv ID or DOI:

```bash
ruby scripts/paper.rb add 2503.19222 --image figure.png --slug my-paper   # new preprint
ruby scripts/paper.rb publish my-paper 10.1137/23M1627729                  # once it is published
ruby scripts/paper.rb add 10.1103/PhysRevE.105.025311 --image figure.png   # published, no preprint
ruby scripts/paper.rb cv                                                   # just rebuild and copy the CV
```

It gets metadata from arXiv and Crossref, matches co-authors to `data/authors/`, adds or updates the
`\pub{...}` line in the CV (`~/Documents/Employment/CV/scholarly.ltx`, its own local git repository),
rebuilds the CV with latexmk and copies the PDF into `static/files/`. The Claude Code skill in
`.claude/skills/add-paper/` runs the script and handles the rest: tags, the CV title in sentence case,
a preview, and the commit.

## Customizations

The look of the old site is rebuilt with these overrides. The template itself is untouched.

**Blocks** (`layouts/_partials/hbx/blocks/`), each ported from an old Wowchemy widget:
- `about`: avatar, name and links on the left; bio, interests and education on the right
- `collection-2col`: section title in a left column, list on the right
- `contact-legacy`: contact details with an OpenStreetMap map
- `course-grid`: course cards with tag filter buttons
- `people`: students grouped by `user_groups`, with round avatars
- `tag-cloud`

**List views** (`layouts/_partials/views/`): `compact` and `card-legacy`, the old view 2 and view 3.

**Page layouts**:
- `layouts/publication/list.html`: every publication on one page, with search and type and year filters
- `layouts/publication/single.html` and `layouts/_partials/pub_line.html`: a full citation line under the title
- `layouts/post/single.html`: adds the post subtitle
- `layouts/event/list.html`: talks grouped by year
- `layouts/authors/term.html`: author pages with the about block and recent items
- `layouts/_partials/page_links.html`: one PDF button, then Cite and DOI first, as on the old site

**Smaller fixes**:
- `layouts/_partials/hooks/head-end/fonts.html` loads Google Fonts directly. The template's loader builds a URL that Google rejects. The fonts are set under `fonts:` in `config/_default/params.yaml`.
- `layouts/_partials/hooks/head-end/legacy-style.html` holds a few CSS tweaks that match the old site.
- `layouts/_markup/render-passthrough.html` escapes math such as `$0<x<1$` so it isn't parsed as HTML.
- `layouts/_shortcodes/staticref.html` is the Wowchemy shortcode, kept so old content renders.
- `config/_default/hugo.yaml` allows `tailwindcss` in `security.exec.allow`, which Hugo 0.163 and later require.

## Vendored template

The HugoBlox modules are vendored in `_vendor/` so the site builds even if upstream changes or disappears.
To upgrade:

```bash
hugo mod get -u && hugo mod vendor
```

`layouts/post/single.html`, `layouts/publication/single.html` and `layouts/_partials/page_links.html` are
copies of template files with small changes. After an upgrade, compare them with the new versions in `_vendor/`.

## License

The template code is MIT-licensed by Lore Labs (see `LICENSE.md`). The content (text, papers, images
and CV) is © Roy Goodman.
