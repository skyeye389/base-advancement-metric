# Revision Bible — Base Advancement Metric (BA / BAP)

This document records the major conceptual and engineering revisions leading to the v1.0 public release.
Minor formatting changes and bug fixes are intentionally excluded.

---

## v0.1 — Conceptual Origin
**Change:** Initial definition of Base Advancement (BA)  
**Rationale:** Measure batter contribution via baserunner movement rather than outcomes (RBI, runs).

---

## v0.2 — Runner Agency Clarified
**Change:** Excluded batter’s own advancement from BA  
**Rationale:** Batter advancement is captured by traditional metrics (TB, OPS); BA focuses on team context.

---

## v0.3 — Negative Advancement Introduced
**Change:** Explicit penalties for runner erasure (double plays, force outs)  
**Rationale:** Advancement must be symmetric; erasing runners is materially harmful.

---

## v0.4 — MaxOpp Normalization
**Change:** Added MaxOpp (maximum advancement opportunity per PA)  
**Rationale:** Separate opportunity from execution; reduce lineup-position bias.

---

## v0.5 — Pitching Counterpart (BAP)
**Change:** Defined Base Advancement Prevention (BAP) as mirror image of BA  
**Rationale:** Pitchers influence advancement; metric symmetry improves interpretability.

---

## v0.6 — Conservation Invariant
**Change:** Enforced game-level invariant: ΣBA + ΣBAP = 0  
**Rationale:** Advancement is zero-sum between offense and defense; provides validation check.

---

## v0.7 — Attribution Rules Hardened
**Change:** Excluded non-batter-driven advancement (errors, wild pitches, passed balls)  
**Rationale:** Preserve batter agency; avoid conflating defensive mistakes with skill.

---

## v0.8 — Quiz-Based Edge Case Validation
**Change:** Formal quiz framework for ambiguous plays  
**Rationale:** Stress-test scoring logic; ensure consistency across rare states.

---

## v0.9 — Engine / Report Split
**Change:** Split monolithic Rmd into engine script and reporting Rmd  
**Rationale:** Improve reproducibility, clarity, and user control over outputs.

---

## v1.0 — Public Release Freeze
**Change:** Scoring logic frozen; documentation completed  
**Rationale:** Enable public release with stable semantics while allowing future extensions.

---

## Post–v1.0 (Planned)
- Retrosheet ingestion adapter
- League-wide validation
- Secondary metrics incorporating run expectancy
- Career-level aggregation

---

**Author:** Gary Kuleck  
**Status:** v1.0 frozen (February 2026)