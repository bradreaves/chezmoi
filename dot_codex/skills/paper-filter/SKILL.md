---
name: paper-filter
description: Find and screen computer science research papers from a user-specified venue and year against natural-language selection criteria, then create a validated BibTeX bibliography enriched with abstracts, direct PDF links, and expert one-sentence loglines. Use when a user asks to review conference proceedings, filter a venue's papers by topic or methodology, build a reading list, or produce BibTeX for papers matching criteria such as network security, static analysis, privacy, machine learning, or measurement.
---

# Paper Filter

Turn a venue, year, and natural-language criterion into a carefully screened, source-backed `.bib` file. Treat this as a literature-review task, not a keyword search.

## Inputs

Require three semantic inputs, whether supplied in one prompt or inferred unambiguously from context:

1. Venue name or common acronym.
2. Publication year.
3. Natural-language inclusion criterion.

Ask only when a missing input cannot be recovered safely. Resolve venue aliases such as “Oakland” to IEEE Symposium on Security and Privacy, but verify ambiguous names before proceeding.

## Workflow

### 1. Resolve the proceedings

- Verify the canonical venue name, year, proceedings title, and publication type.
- Prefer, in order: the official proceedings or accepted-paper list, DBLP venue/year table of contents, then a publisher index.
- Use live web research because proceedings and access links change.
- Enumerate every main-track research paper before filtering. Exclude keynotes, posters, demos, tutorials, panels, front matter, and colocated workshops unless the user explicitly includes them.
- Treat full and short peer-reviewed main-track papers as papers. State any different scope assumption in a leading BibTeX comment.

### 2. Build canonical citation records

- Use each DBLP per-record BibTeX export as the preferred base when available. Preserve its author order, title, venue, year, pages, and DOI.
- If DBLP is unavailable or incomplete, use official publisher metadata or Crossref and reconcile discrepancies against the paper PDF.
- Preserve DBLP citation keys. Otherwise create stable unique keys in the form `FirstAuthorYearTitleToken`.
- Normalize page ranges to BibTeX double hyphens, protect title capitalization, and escape BibTeX-sensitive characters.
- Keep `doi` as a bare DOI. Set `url` to a direct, public PDF when one exists; prefer the official PDF, then an author or institutional copy. Use the DOI landing page only when no direct PDF is available.

### 3. Recover and verify abstracts

- Prefer the official proceedings abstract, then the publisher page, paper PDF, author or institutional copy, and finally scholarly metadata services such as Semantic Scholar or OpenAlex.
- Copy the published abstract rather than generating one. Normalize whitespace and obvious extraction artifacts without changing meaning.
- Detect incomplete abstracts: abrupt endings, suspiciously short text, footnotes inserted mid-sentence, markup such as `<scp>`, replacement characters, or extraction debris.
- Recheck incomplete records against the first page of the PDF. Never invent missing abstract text.

### 4. Screen for relevance

- Read every title and abstract. Do not rely only on venue sessions, keywords, or title matches.
- Include a paper when its research question, method, artifact, evaluation, or principal implication materially satisfies the user's criterion.
- Exclude papers that only mention the criterion incidentally, use it solely as background, or share ambiguous vocabulary with it.
- For borderline papers, inspect the PDF introduction, contributions, methods, and CCS concepts or author keywords. Favor a defensible substantive match over superficial recall.
- Apply one consistent threshold across the full proceedings. Do not silently tighten the criterion as the list grows.

### 5. Write expert loglines

Before drafting loglines, read [references/logline-style.md](references/logline-style.md) completely.

- Write exactly one original sentence per included paper.
- Base the sentence on the abstract and, when necessary, the paper itself.
- Lead with the contribution or central result; include the strongest scale, quantitative result, or concrete capability when it improves discrimination.
- Write for experts. Omit generic motivation, author names, venue names, and phrases such as “this paper presents.”
- Do not copy an abstract sentence verbatim.

### 6. Emit BibTeX

Write one `.bib` file in proceedings order unless the user requests another arrangement. If no filename is given, use `<venue-slug>-<year>-<criteria-slug>.bib`.

Every included record must contain:

```bibtex
@inproceedings{CitationKey,
  author    = {...},
  title     = {{...}},
  booktitle = {...},
  year      = {2025},
  month     = oct,
  pages     = {1--16},
  publisher = {...},
  doi       = {10.xxxx/xxxxx},
  url       = {https://example.org/paper.pdf},
  abstract  = {...},
  logline   = {...}
}
```

Retain additional authoritative fields such as `address`, `series`, or `isbn` when useful. Do not add relevance explanations inside entries.

Start the file with concise `%` comments recording:

- Canonical venue and year.
- User's selection criterion.
- Included publication types and important exclusions.
- Any unavoidable metadata limitation, such as unavailable public PDFs.

### 7. Validate

Run the bundled validator using its absolute path:

```bash
python3 /absolute/path/to/paper-filter/scripts/validate_bib.py output.bib --year 2025
```

Also run `bibtex` or `biber` parsing when available. Fix all errors and investigate warnings about short abstracts, non-PDF URLs, malformed page ranges, or weak loglines.

Manually audit at least:

- Included-paper count against the screening decisions.
- Unique citation keys and DOIs.
- Author order, title, venue, year, and pages.
- Direct PDF resolution where available.
- Abstract completeness.
- One-sentence, paper-specific loglines.

## Handoff

Report the output path, included count, proceedings scope, selection boundary, and validation result. Mention meaningful borderline choices or unavailable PDFs, but do not burden the user with routine retrieval details.

