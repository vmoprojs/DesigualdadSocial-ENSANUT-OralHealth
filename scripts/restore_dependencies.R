# Explicit dependency installation; run only when you want to restore packages.
stopifnot(file.exists('renv.lock'))
options(repos=c(CRAN='https://cloud.r-project.org'))
if(!requireNamespace('renv',quietly=TRUE))install.packages('renv')
lib<-file.path('renv','library');dir.create(lib,recursive=TRUE,showWarnings=FALSE)
renv::restore(project=getwd(),lockfile='renv.lock',library=lib,prompt=FALSE)
cat('Dependencies restored to the ignored local library. Run analyses from the repository root.\n')
