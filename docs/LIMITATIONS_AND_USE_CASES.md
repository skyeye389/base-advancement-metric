# Limitations and Use Cases

## Known Limitations

### 1. Lineup and Opportunity Effects
Batters hitting behind high-OBP teammates receive more advancement opportunities.
BA addresses this via normalization (BA / MaxOpp) but cannot eliminate lineup context entirely.

---

### 2. Sample Size Sensitivity
BA is event-driven and can be noisy in small samples.
Stability improves with larger samples and multi-series aggregation.

---

### 3. Data Quality Dependence
Current v1.0 validation uses Baseball-Reference play-by-play exports.
Formatting inconsistencies require defensive parsing logic.

---

### 4. Defensive Context
BA credits only batter-driven advancement.
Advances caused by errors, wild pitches, or passed balls are excluded by design.

---

## What BA/BAP Should NOT Be Used For (Yet)
- Career ranking
- Hall of Fame arguments
- Player valuation or salary modeling
- WAR replacement

BA/BAP are descriptive, not predictive, metrics.

---

## Appropriate Use Cases

### Offensive Analysis
- Situational hitting effectiveness
- Productive contact vs strikeout tradeoffs
- Complement to OPS/OBP/SLG

---

### Pitching Analysis (BAP)
- Stress management
- Runner containment
- Context-independent run pressure

---

### Teaching and Research
- Base–out state awareness
- Metric design transparency
- Validation of run expectancy models

---

## Roadmap
- Retrosheet ingestion for league-scale data
- Expanded pitcher attribution
- Secondary metrics incorporating run expectancy
- Longitudinal (career-level) analysis

---

## Summary
BA/BAP are intentionally narrow in scope.
Their value lies in clarity, transparency, and complementarity with existing metrics.
