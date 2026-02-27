Measuring What Happens Between the Bases

Introducing the Base Advancement (BA) and Base Advancement Prevention (BAP) Metrics

Modern baseball analytics has become very good at measuring outcomes—runs, wins, expected runs, leverage, and value. But one part of the game remains surprisingly under-measured: what actually happens to baserunners during a plate appearance, independent of whether those movements immediately lead to runs or wins.

The Base Advancement (BA) and Base Advancement Prevention (BAP) metrics were developed to address this gap.

The Core Idea

At its core, baseball is a game of advancing runners.

A batter can:

advance runners with a hit

advance runners with a walk

advance runners with productive outs

erase runners through double plays or baserunning mistakes

A pitcher can:

suppress advancement

induce force-outs

allow runners to advance without giving up hits

prevent or enable productive contact

BA and BAP measure only these effects.

They deliberately ignore:

the batter’s own advancement

run expectancy

win probability

leverage or inning context

This is not a flaw—it is the point.

Why Not Just Use WPA or RE24?

Metrics like WPA and RE24 answer important questions:

How much did this play matter?

How many runs did it produce?

How did it change the game outcome?

BA/BAP answer a different question:

What did the batter or pitcher actually do to the baserunners available to them?

By removing run and win context, BA/BAP isolate process over consequence.

A productive groundout that moves runners but produces no RBI still matters.
A walk that forces three runners forward matters more than a walk with the bases empty.
A pitcher who repeatedly prevents advancement may be effective even before runs appear on the scoreboard.

How BA/BAP Work (High Level)

Each plate appearance begins with a known base–out state

Each baserunner has a maximum possible advancement opportunity

Credit (or debit) is assigned based on actual runner movement caused by batter or pitcher agency

The metrics are normalized by opportunity to allow fair comparison

The scoring logic is fully documented and frozen at v1.0 for transparency.

What BA/BAP Reveal

Early results (validated on a limited 2022 Baltimore Orioles sample) suggest that BA/BAP:

highlight contact-oriented contributors often undervalued by slash-line stats

differentiate pitchers who suppress advancement without relying solely on strikeouts

correlate meaningfully—but not redundantly—with runs scored and allowed

offer a stable framework for derived metrics (e.g., BA + run expectancy)

These findings are illustrative, not conclusive, and are shared openly to invite scrutiny.

What Comes Next

The current release uses manually exported Baseball-Reference play-by-play data for validation only.

Future work will focus on:

Retrosheet ingestion for league-scale analysis

Secondary metrics built on BA/BAP

Team- and era-level comparisons

Longitudinal player evaluation

An Invitation

BA/BAP are not proposed as definitive answers—but as well-defined questions.

If you are interested in:

process-based baseball metrics

baserunning value

separating agency from context

or simply testing a new way to think about offense and pitching

—you are invited to explore, critique, and extend the work.