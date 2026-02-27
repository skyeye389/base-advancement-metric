# Scoring Logic Evolution — BA / BAP

This appendix documents how the Base Advancement (BA) and Base Advancement Prevention (BAP)
scoring rules evolved and what is now locked in v1.0.

---

## Core Principle (unchanged)
BA measures **batter agency in advancing runners**, independent of batting average or slugging.
BAP mirrors BA from the pitcher’s perspective.

Invariant:  
**Sum of BA across both teams + Sum of BAP across both teams = 0 (per game)**

---

## BA v1.0 Rules (Locked)

### Credited (+BA)
- +1 per base advanced by existing runners due to batter action
- Walk/HBP: full forced advancement credited
- Productive outs (e.g., groundout advancing runners)
- Sacrifice flies (runner advancement credited, regardless of RBI rules)

### Neutral (0 BA)
- Batter’s own advancement (handled elsewhere)
- Outs that do not advance runners
- Runner caught stealing or picked off independent of batter

### Penalized (−BA)
- Double plays (heavier penalty when erasing advanced runners)
- Lineouts/force plays that erase runners

### Errors
- Advancement due to defensive error beyond the forced base is **not credited**

---

## BAP v1.0 Rules (Locked)

- BAP = −BA on each play
- Pitcher credited for preventing advancement
- Pitcher penalized for allowing advancement regardless of hit type

---

## Explicitly Deferred (Future Versions)
- Run expectancy weighting
- Differential base value weighting (e.g., 2B→3B > 1B→2B)
- Contextual leverage adjustments
- Individual LOB / ER attribution

---

This document freezes the v1.0 scoring model used by:
convert_BA_BAP_v022525_v5d_v1.0.Rmd
