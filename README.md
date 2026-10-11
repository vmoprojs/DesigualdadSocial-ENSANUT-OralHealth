# DesigualdadSocial-ENSANUT-OralHealth
Article: Socioeconomic inequalities in oral health-related behaviours in children and adolescents in Ecuador: a cross-sectional study
Manuscript: PONE-D-26-05990R1. Software version 1.0.0; planned release tag v1.0.0.
This R project reproduces the frozen complex-survey analyses of oral health-related behaviours in Ecuadorian children and adolescents. Source: ENSANUT 2018, Instituto Nacional de Estadística y Censos (INEC), [official catalog](https://anda.inec.gob.ec/anda5/index.php/catalog/891).
## Publication status
Prepared locally for a public GitHub repository and a persistent Zenodo archive of release v1.0.0. No remote repository, release, Zenodo deposit or DOI exists yet. Participant data are prepared for a separate restricted Zenodo record. INEC authorized redistribution of the de-identified analytical derivative; supporting authorization is archived at INEC.
## Requirements and installation
Use R 4.6.0. Direct runtime dependencies: survey 4.5, readr 2.2.0, dplyr 1.2.1 and ggplot2 4.0.3. Exact recursive versions are in renv.lock; dependency_versions.csv records the direct validated environment. See [reproducibility](docs/reproducibility.md).
From the repository root:
```sh
Rscript scripts/restore_dependencies.R
Rscript tests/test_public.R
Rscript R/run_all.R --help
```
The explicit restoration command installs dependencies; the analytical runner makes no network requests. Public tests require no participant data and a missing dataset is an expected state.
## Obtain data and reproduce
After the restricted Zenodo record is published, request access for a legitimate research, verification or replication purpose and accept its data-use conditions. See [data access](data/README.md). Place the approved intact CSV at the ignored data path, then run:
```sh
Rscript R/run_all.R --data data/PONE_D_26_05990_minimal_analytical.csv
```
The command requires no code edits. Outputs are written to reproduced_outputs by default; use --out to change this. It generates Tables 1–4, figure data/PNGs, model coefficients and global tests, OHP and duplicate sensitivities, design-impact comparisons and the 22/85 headline. Aggregate expected results are in [outputs_reference](outputs_reference).
## Design and historical cohort
Analyses preserve exact calibrated F4 weights, strata and nested PSU membership. Children and adolescents are survey domains. The primary historical frame has 18,805 rows representing 18,801 unique historical participants. Four duplicate pairs remain for comparability; all 16 A/B choices plus UNIQUE18797 are reproduced as sensitivity. Opaque PSU/stratum labels preserve the design but do not prevent linkage to source survey records/codes. Individual data therefore remain restricted.
Final formulas and complete-case locks are frozen. No backward selection is executed; see [selection contract](docs/backward_selection.md), [survey design](docs/survey_design.md) and [duplicate sensitivity](docs/duplicate_sensitivity.md).
## Project structure
- R/: validated three-file runtime: run_all.R, reproduction_functions.R and frozen_specification.R.
- data/: public dictionary and access instructions only.
- docs/: methodology, source provenance, design, selection, duplicate and reproduction notes.
- outputs_reference/: aggregate comparison results.
- scripts/ and tests/: dependency restoration and public-only checks.
- .github/workflows/reproduce.yml: public validation only, prepared for future GitHub Actions.
## Licence and citation
MIT covers the original code and original accompanying documentation. It does not apply to the restricted analytical dataset or original INEC microdata. The analytical dataset uses RESTRICTED DATA USE CONDITIONS, requiring secure purpose-limited use, attribution and compliance with applicable INEC conditions, and prohibiting re-identification, source-record linkage and redistribution.
Cite the software authors/version in [CITATION.cff](CITATION.cff), the related manuscript and the original survey; add the verified archived software DOI and data DOI after publication. repository-code, DOI and date-released are deliberately omitted from machine-readable CFF until real values exist.
## Data Availability
The analysis code, data dictionary and non-sensitive reproducibility materials have been prepared for public release through GitHub and archival in Zenodo. The de-identified analytical dataset will be deposited separately in Zenodo under restricted access because combinations of analytical variables permit linkage to source survey records and survey-design codes. The official source is INEC ENSANUT 2018; redistribution of the derivative was authorized by INEC. No online availability is claimed at this stage.
## Internal publication slots
These are unassigned editorial slots, not links or DOI identifiers:
- GITHUB_URL = {{GITHUB_URL}}
- CODE_ZENODO_DOI = {{CODE_ZENODO_DOI}}
- DATA_ZENODO_DOI = {{DATA_ZENODO_DOI}}
The author will replace them with verified values during publication. There is no DOI badge. [Draft Zenodo metadata](ZENODO_METADATA_DRAFT.md) specifies the archive relationship.
## Integrity
RELEASE_SHA256SUMS.txt covers the complete public payload except itself and .git. From the repository root use sha256sum -c RELEASE_SHA256SUMS.txt (Linux) or shasum -a 256 -c RELEASE_SHA256SUMS.txt (macOS). Its own digest is recorded in the separate review bundle. Recompute it after any L10 metadata edit before tagging a release.
