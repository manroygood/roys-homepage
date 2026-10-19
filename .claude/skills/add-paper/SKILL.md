---
name: add-paper
description: Add one of Roy's papers to the homepage and CV from an arXiv ID or DOI, or update a preprint to its published journal version. Use when Roy mentions a new paper, a new preprint, or that a paper was accepted or published.
---

# Adding a paper

`scripts/paper.rb` does the mechanical work; this skill covers the judgment around it.
Run it from the repo root with Ruby (stdlib only).

| Situation | Command |
|---|---|
| New preprint on arXiv | `ruby scripts/paper.rb add ARXIV_ID --image FILE --slug SLUG` |
| Preprint now published | `ruby scripts/paper.rb publish SLUG DOI` |
| Published, never a preprint here | `ruby scripts/paper.rb add DOI --image FILE --slug SLUG [--arxiv ARXIV_ID]` |
| Only rebuild/copy the CV | `ruby scripts/paper.rb cv` |

Other flags: `--image FILE` on `publish` (replace the featured image), `--pdf FILE` (use a local PDF, e.g. the accepted manuscript), `--no-pdf`, `--no-cv`.

What the script does:
- Writes `content/publication/SLUG/index.md` and `cite.bib`, saves the arXiv PDF as `SLUG.pdf` (the page's PDF button), and copies the `--image` file to `featured.<ext>`. `add` refuses to run without `--image`.
- Preprints get `publication_types: [article]` (shown as "Preprint") and `publication.name: "arXiv preprint arXiv:ID"`; published papers get `article-journal`, the journal name/short name/volume/issue/pages from Crossref, a "Journal" link to the DOI, and Crossref's BibTeX.
- Matches authors to `data/authors/*.yaml` by family name and first initial (Roy is `admin`); unmatched authors are listed by full name.
- Adds a `\pub{YEAR}{Authors}{Title}{submitted}` line at the top of "Refereed Journal Papers" in `~/Documents/Employment/CV/scholarly.ltx` (the `\pub` macro in `packages.tex` adds the italics, commas and period). `publish` finds that line by title, keeps the title as written in the CV, and replaces `submitted` with `Short J. \textbf{vol}, pages`. It backs up to `scholarly.ltx.bak`, rebuilds with latexmk, and copies `CVgoodman.pdf` to `static/files/`.

## Steps

1. Get the arXiv ID or DOI and a featured image file (.png, .jpg, .gif or .webp) from Roy. The image is required: do not create the page, pick a figure from the PDF, or substitute a placeholder until Roy provides one. If Roy gives a title only, search arXiv/Crossref and confirm the match with Roy.
2. Pick a short slug in the style of the existing folders (`leapfrogPRF`, `QGLAB`, `massive-vortices-i`); for `publish`, find the existing folder (`grep -l ARXIV_ID content/publication/*/index.md`).
3. Run the script and read its output. Check:
   - Author matching. For a co-author with no profile, ask Roy whether to create `data/authors/<slug>.yaml` (copy the shape of an existing one) and then use that slug in `authors:`.
   - The CV line it printed. CV titles are in sentence case (capitalize only the first word, the first word after a colon, proper nouns such as Bose--Einstein or Schrödinger, and acronyms such as NLS or MATLAB), so convert the arXiv title in `scholarly.ltx`; also check initials and the ISO 4 journal abbreviation. Leave the website page's title as published. After a `publish`, move the line if it is no longer in date order. Then run `ruby scripts/paper.rb cv`.
   - `publish`: Crossref titles can differ in capitalization from arXiv; the page keeps the arXiv abstract and Roy's custom body text.
4. Fill in what the metadata can't: `tags` (reuse tags from similar papers, `grep -h -A3 '^tags' content/publication/*/index.md`), `featured`, `summary`, and `url_code`. Ask Roy rather than invent.
5. Check the page: `hugo server` and open `/publication/SLUG/` and `/papers/`.
6. Show Roy `git diff --stat` and commit on the current branch (page folder plus `static/files/CVgoodman.pdf`). Also commit the CV change in `~/Documents/Employment/CV` (its own git repository, no remote). Push the homepage only when Roy asks.

Notes:
- The CV folder is a git repository; `scholarly.ltx.bak` also holds the version before the script's last edit.
- On `publish` with a new `--pdf`, the old arXiv PDF stays in the folder; the page shows one PDF button (an explicit `url_pdf` wins), so delete the file that should no longer be offered.
- Journal-published papers use the Crossref publication date (online first) as `date`, which sets the year shown and the sort order.
