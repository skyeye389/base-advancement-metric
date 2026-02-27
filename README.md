# Base Advancement Metric (BA / BAP)

## Overview
**Base Advancement (BA)** is a state-based offensive metric that measures how effectively a batter advances *existing baserunners* during a plate appearance, independent of the batter’s own advancement.

**Base Advancement Prevention (BAP)** is the pitching counterpart, measuring how effectively a pitcher suppresses baserunner advancement given identical base–out states.

BA/BAP are **process-based** metrics. They complement traditional outcome- and context-driven statistics (AVG, OPS, WPA, RE24) by isolating what happened to runners as a direct result of batter or pitcher agency.

---

## Why BA / BAP?
Most baseball metrics implicitly weight outcomes (hits, walks, runs) and only indirectly capture **situational productivity**. BA/BAP instead track **explicit base–out state transitions**, allowing:

- credit for productive outs and sacrifices  
- penalties for erasing runners (e.g., double plays)  
- separation of opportunity from execution via normalization  

BA/BAP are **orthogonal**, not competitive, with existing sabermetric tools.

For a detailed comparison, see:
- `docs/WHY_BA_NOT_WPA.md`

---

## Metric Definitions (v1.0)

### Base Advancement (BA)
- Credits a batter for each base advanced by *existing* runners
- Excludes the batter’s own advancement
- Penalizes runner erasures
- Excludes non-batter-driven advances (errors, wild pitches, passed balls)

### Base Advancement Prevention (BAP)
- Mirror image of BA from the pitcher’s perspective
- Prevented advancement is positive; allowed advancement is negative
- Conserves to zero with BA at the game level:

  **Σ BA + Σ BAP = 0**

---

## Validation Status
- Scoring logic frozen at **v1.0**
- Validated on 2022 Baltimore Orioles games (initial sample: 41+, expanding)
- Internal invariants verified (state consistency, conservation)

BA/BAP are descriptive metrics intended for analysis and research, not forecasting.

---

## Repository Structure

```
base-advancement-metric/
├── README.md
├── LICENSE
├── CITATION.cff
│
├── R/
│   ├── engine_BA_BAP_v1.0.R
│   └── report_BA_BAP_v1.0.Rmd
│
├── docs/
│   ├── REVISION_BIBLE.md
│   ├── SCORING_LOGIC_EVOLUTION.md
│   ├── QUIZ_OUTCOMES_v2.md
│   ├── WHY_BA_NOT_WPA.md
│   └── LIMITATIONS_AND_USE_CASES.md
│
└── examples/
    └── example_output_csvs/
```

---The examples/ directory contains sample output CSVs generated from a limited set of Baltimore Orioles 2022 games.

These files are provided for illustrative purposes only and are not intended for league-wide or comparative inference. Users should generate their own outputs using their own data sources.

## How to Run

### Option 1 — CSV Outputs Only
Run the engine script:
```r
source("R/engine_BA_BAP_v1.0.R")
run_engine(input_dir = "path/to/game/files")
```

Produces CSVs in `processed_output/`.

---

### Option 2 — HTML Report
Knit the report:
```r
R/ report_BA_BAP_v1.0.Rmd
```

Reads existing CSVs and produces an HTML summary.

---

### Option 3 — Both (Recommended)
1. Run the engine to generate CSVs  
2. Knit the report to generate HTML  

---

## Data Sources and Ethics
- **Baseball-Reference** play-by-play exports are used for validation and model development
- No automated scraping is performed
- **Retrosheet** is the planned long-term data backbone for league-scale analysis

See `docs/LIMITATIONS_AND_USE_CASES.md` for details.

---

## Known Limitations
- Lineup context affects opportunity
- Small-sample volatility
- Input formatting inconsistencies across data sources

These are documented transparently and addressed in the roadmap.

---

## Roadmap
- Retrosheet ingestion adapter
- League-wide and career-level analysis
- Secondary metrics incorporating run expectancy
- Expanded pitcher attribution

---

## Citation
If you use this work, please cite using the information in `CITATION.cff`.

---

## License
This project is released under the MIT License.

---

## Acknowledgements
- Play-by-play data sourced from Baseball-Reference (used respectfully and manually)
- Developed with the assistance of AI tools, with full human oversight


## Author
Gary Kuleck  
ORCID: https://orcid.org/0009-0009-7869-5977
