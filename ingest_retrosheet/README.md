# Retrosheet ingestion (parsed plays -> EIC-v1)

This pipeline downloads Retrosheet parsed play-by-play season files (`YYYYplays.zip`) and converts them into EIC-v1 per-game CSVs.

## Run ingestion
```bash
Rscript ingest_retrosheet/R/ingest_retrosheet_plays_cli.R --year 2022 --out data/ingested_retrosheet/2022