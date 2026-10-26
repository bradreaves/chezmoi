# Expert Logline Style

## Goal

Compress the paper's distinctive contribution into one pithy, information-dense sentence for a technically sophisticated reader. A logline should help an expert decide whether to read the paper without restating its title or abstract.

## Construction

Choose the strongest combination of:

1. The artifact, method, dataset, protocol, or analysis.
2. What it enables, discovers, compares, or disproves.
3. The best quantitative evidence, scale, limitation, or practical implication.

Put the contribution first. Prefer concrete subjects and active verbs:

- “A cryptographic protocol automates…”
- “Static analysis detects…”
- “Measurements across 66,000 lines find…”
- “Interviews with 21 authors reveal…”

Use numbers selectively. Include them when they establish scale, effectiveness, prevalence, or a surprising contrast. Omit secondary statistics that make the sentence read like a compressed abstract.

## House style

- Write one declarative sentence, normally 15–35 words.
- Use present tense for the contribution and findings.
- Name the method or system when its name is informative.
- Prefer a semicolon or participial phrase to connect one result to one implication.
- Preserve meaningful technical terms; do not explain standard CS terminology to experts.
- State limitations when they are the main result.
- Use numerals for measured results.

Avoid:

- “This paper,” “the authors,” “we,” or venue/year boilerplate.
- Empty praise such as “novel,” “innovative,” “important,” or “comprehensive.”
- Background-only openings such as “Security is increasingly important.”
- Laundry lists of contributions.
- Claims stronger than the evidence in the paper.
- Copying a sentence from the abstract.

## Representative examples

These synthetic examples capture the desired style without serving as templates to copy mechanically:

- An interdomain-routing monitor combines control- and data-plane signals to detect short-lived hijacks that prefix-only systems miss.
- Whole-program taint analysis traces untrusted configuration values into privileged build steps, exposing injection paths across thousands of repositories.
- Measurements from 18 regional networks show that encrypted DNS shifts observability toward a small set of resolvers without consistently improving lookup latency.
- A capability-based protocol lets roaming devices prove revocation status without disclosing stable identifiers to visited networks.
- Longitudinal scans find that emergency certificate replacement finishes quickly at major providers but leaves a persistent tail of vulnerable embedded systems.
- Comparing four patch-localization strategies shows that commit-wide labeling substantially inflates vulnerability datasets and downstream detector accuracy.

## Useful patterns

### System or method

`<Artifact> <does capability>, <quantified effectiveness or key constraint>.`

### Measurement study

`<Measurement scope> finds <central result>, <practical or conceptual implication>.`

### Comparative evaluation

`Comparing <systems/data> shows <decisive contrast>, <consequence>.`

### Qualitative study

`<Study population and method> reveal <mechanism or recurring problem>, <implication>.`

## Final checks

Before accepting a logline, ask:

- Could this sentence describe another paper in the same session? If yes, make it more specific.
- Does it contain the paper's actual contribution rather than its motivation?
- Is every number or causal claim supported by the paper?
- Can any clause be removed without losing distinguishing information?
- Is it exactly one sentence?
