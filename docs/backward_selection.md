# Frozen backward selection contract
The historical survey-design backward procedure tested entire candidate terms with global design-based Wald F tests, on locked complete-case samples. L3 selected the final term sets.
This release stores those already-selected formulas in R/frozen_specification.R and recalculates them using R/reproduction_functions.R. R/run_all.R executes the full frozen analysis and sensitivity workflow. It does not rerun backward selection or make new model choices.
There is deliberately no 05_backward_models.R selection runner. Splitting the validated three-file runtime into decorative numbered stages would not add a new reproducibility capability. Frozen scenarios include all 16 A/B duplicate combinations and UNIQUE18797.
