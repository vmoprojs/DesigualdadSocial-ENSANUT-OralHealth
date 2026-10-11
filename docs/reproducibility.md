# Reproducibility contract
Full reproduction requires (1) this GitHub code package and (2) an authorized unchanged analytical CSV from the separate restricted Zenodo record. The public package alone contains no participant rows.
Install the R version and package versions below, then run from the repository root:
```sh
Rscript scripts/restore_dependencies.R
Rscript tests/test_public.R
Rscript R/run_all.R --data data/PONE_D_26_05990_minimal_analytical.csv
```
Use --out DIRECTORY for another output location. --help and invocation without --data exit successfully without analysis. An explicitly supplied unavailable file produces a controlled error. --descriptives-only is optional and does not certify full reproduction.
Expected aggregate outputs: Table1.csv through Table4.csv; Figure1_data.csv and Figure2_data.csv and their PNGs; primary coefficients/global tests, OHP sensitivity, duplicate sensitivity, exact design-impact contrasts, Headline.csv, variance sensitivity, execution status and sessionInfo.txt. Generated outputs are ignored by Git.
The frozen validation target is 39,099 numeric comparisons against the L2/L3/L4 authority used in L6-L8. Counts and degrees of freedom are exact; other comparisons use 1e-10 + 1e-8 * abs(reference), with matching missingness. The headline is 22/85 and median SE ratio 1.670164469229248, subject only to floating-point tolerance.
The included outputs_reference files are aggregate L8 reference results. The detailed private authority alignment harness is retained in the project review, outside the public runtime. The clean-room test uses only public files plus the restricted CSV; it does not ingest source microdata or private mapping files.
Validated environment: R 4.6.0, survey 4.5, readr 2.2.0, dplyr 1.2.1, ggplot2 4.0.3. renv.lock records those packages and recursive runtime dependencies from the installed validated library. Package restoration downloads from CRAN and needs network access and, where relevant, system build dependencies. No source data are downloaded.
haven, tidyr, officer and flextable are not required by the public runtime; forensic, authoring and source-ingestion dependencies are excluded. No .Rprofile activation downloads anything: it only adds an existing ignored renv/library directory.
GitHub Actions runs public-only checks, never participant analyses or data retrieval. Full reproduction is a local authorized operation. The repository workflow is prepared but has not been run remotely.
