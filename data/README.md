# Individual data access
The participant-level CSV is not included in GitHub. It is deposited separately under [restricted access in Zenodo](https://doi.org/10.5281/zenodo.23298197).
Request access from the depositant through the Zenodo record, giving your identity/contact and research, verification or replication purpose, and accepting all data-use conditions. These prohibit re-identification, linkage to source survey records/codes and redistribution, and require secure storage, agreed-purpose use, citation and compliance with applicable INEC conditions.
After approval, store the unchanged authorized file locally as `data/PONE_D_26_05990_minimal_analytical.csv`, or supply another secure path with --data. The exact expected filename is PONE_D_26_05990_minimal_analytical.csv. This path is ignored by Git. Never force-add it or place it in a public issue or workflow.
Run from the repository root:
```sh
Rscript R/run_all.R --data data/PONE_D_26_05990_minimal_analytical.csv
```
The separate public data_dictionary.csv describes the 29 fields. FEXP_F4 uses C99 hexadecimal floating-point text, decoded exactly by the R loader. Do not convert, round or resave it in spreadsheet software. Opaque design labels preserve membership; they do not prevent linkage.
