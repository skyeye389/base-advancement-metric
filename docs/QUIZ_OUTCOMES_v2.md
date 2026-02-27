<!-- Updated: 2026-02-24 15:51 local -->
# QUIZ_OUTCOMES.md
## BA/BAP v1.0 Quiz Outcomes (Formalized)

This document captures the quiz scenarios we agreed on, using BA/BAP v1.0 concepts:
- BA credits base-steps advanced by **pre-existing runners** (batter’s own advancement excluded).
- BAP is the mirror: **BAP = −BA** (plate-appearance mirror).
- Independent events (SB/CS, balk, wild pitch, pickoff, etc.) are out-of-scope in v1.0.

---

## A. Batter-side scenarios (BA)

### 1) Runners on 1st & 2nd; single; both runners advance 1 base
**BA = +2**  
Rationale: 2nd→3rd (+1), 1st→2nd (+1).

### 2) Runners on 1st & 2nd; force out at 2B (fielder’s choice)
Assume: 1st erased at 2B, 2nd→3rd.  
**BA = 0**  
Rationale: +1 (2nd→3rd) −1 (1st erased).

### 3) Runners on 1st & 2nd; force out at 3B
Assume: 2nd erased at 3B, 1st→2nd.  
**BA = −1**  
Rationale: +1 (1st→2nd) −2 (2nd erased).

### 4) Runners on 1st & 2nd; deep fly; runner on 2nd→3rd
**BA = +1**  
Rationale: +1 (2nd→3rd).

### 5) Runners on 2nd & 3rd; deep fly; runner from 3rd thrown out at home (DP); runner from 2nd→3rd
**BA = −3**  
Rationale: +1 (2nd→3rd) −3 (3rd erased at home) −1 (double play penalty).

### 6) Runner on 1st; during PA runner caught stealing 2nd
**BA = 0**  
Rationale: independent baserunning event; not batter-caused.

### 7) Runner on 1st; wild pitch advances runner to 2B during PA
**BA = 0**  
Rationale: independent pitching event; not batter-caused.

### 8) Runners on 1st & 2nd; perfect bunt; runners advance to 2nd & 3rd
**BA = +2**  
Rationale: +1 (1st→2nd) +1 (2nd→3rd).

### 9) Runners on 1st & 3rd; batter hits into DP; runner from 3rd scores
Assume: 3rd→home and 1st erased; DP occurs.  
**BA = −1**  
Rationale: +1 (3rd→home) −1 (1st erased) −1 (DP penalty).

### 10) Runner on 1st; single; runner advances to 3B on throwing error
**BA = +1** (agreed refinement)  
Rationale: credit “guaranteed” 1st→2nd (+1); do **not** credit error-driven extra base (2nd→3rd).

> Deferred / not locked: single with runner thrown out attempting 3B (attribution between batter vs runner).

---

## B. Pitcher-side scenarios (BAP)

BAP is computed by mirroring the batter BA result for the plate appearance:
**BAP = −BA**

### 1) Runners on 1st & 2nd; force out at 2B
Batter BA = 0 → **BAP = 0**

### 2) Runners on 1st & 2nd; force out at 3B
Batter BA = −1 → **BAP = +1**

### 3) Bases loaded; force out at home; runners shift 1B→2B and 2B→3B; batter to 1B (bases remain loaded)
Batter BA = −1 → **BAP = +1**  
Rationale: +1 (1B→2B) +1 (2B→3B) −3 (3B erased at home) = −1.

### 4) Runners on 1st & 2nd; groundout to 1B; runners advance to 2B & 3B
Batter BA = +2 → **BAP = −2**

---

## C. Out-of-scope events (v1.0: BA=0, BAP=0)
These are independent of batter PA responsibility and are excluded in v1.0:
- Balk
- Wild pitch (as a stand-alone advancement event)
- Pickoffs and failed pickoffs
- Stolen bases / caught stealing (as stand-alone baserunning events)

In v2.0+, these may be incorporated as a separate pitcher-only ledger (e.g., BAP_misc) without changing BAP = −BA for plate appearances.
---

## Appendix: How to validate Game 1 by hand (quick checklist)

Use this checklist to hand-score a single game (Game 1) and compare against the converter output. The goal is to confirm that **BA/BAP logic and attribution** match `SCORING.md v1.0` before scaling to more games.

1. **Pick 10–20 plate appearances** spanning different base states (bases empty, 1 on, 2 on, 3 on, 2 runners, bases loaded).
2. For each PA, write down the **start base state** (which bases occupied) and compute **MaxOpp** using the table in `SCORING.md`.
3. For each PA, identify **pre-existing runners only** (ignore batter’s own eventual base).
4. Compute **positive BA** as the sum of **successful base-steps by pre-existing runners**:
   - 1 step for 1B→2B, 2B→3B, 3B→Home
   - 2 steps for 1B→3B or 2B→Home, etc.
   - **No “run bonus”**
5. For BB/HBP, credit only **forced** movement:
   - Bases loaded walk = **+3**
   - If not forced, do not credit.
6. Apply **negative BA** for erasures of pre-existing runners:
   - Erased from 1st = −1, from 2nd = −2, from 3rd/home = −3.
7. Apply **double play penalty**:
   - −1 for any DP
   - additional −1 for lined-into DP (total −2).
8. Confirm **neutral cases** score 0:
   - strikeout with no runner movement
   - fly/ground out with no runner movement
   - independent events (SB/CS, WP, balk, pickoff) = **0 BA / 0 BAP** in v1.0.
9. For each PA, compute pitcher mirror:
   - **BAP = −BA**
10. Game-level invariants:
   - **Sum(BA over all PAs) + Sum(BAP over all PAs) = 0**
   - Spot-check that `BA/MaxOpp` is computed only when MaxOpp > 0 (otherwise treat as 0 or NA per your reporting convention).

Tip: start with a few “easy” PAs (walk with bases loaded, simple advancement out, obvious forceouts) to confirm the converter’s interpretation of narrative text matches your hand ledger.
