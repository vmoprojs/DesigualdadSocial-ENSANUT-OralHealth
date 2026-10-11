# Public-only contract: no participant data, no network and no model fits.
stopifnot(file.exists('R/run_all.R'),file.exists('renv.lock'),file.exists('.gitignore'))
files<-list.files('.',recursive=TRUE,all.files=TRUE,no..=TRUE)
files<-files[!grepl('(^|/)([.]git|renv)(/|$)',files)]
stopifnot(!file.exists('data/PONE_D_26_05990_minimal_analytical.csv'))
stopifnot(!any(grepl('[.](sav|dta|rds|rda|rdata|zip|pem|key)$',files,ignore.case=TRUE)))
csvs<-files[endsWith(files,'.csv')]
for(f in csvs){
 x<-read.csv(f,check.names=FALSE)
 stopifnot(nrow(x)!=18805L)
 if(f!='data/data_dictionary.csv')stopifnot(!any(c('ANON_PSU_ID','ANON_STRATUM_ID','FEXP_F4')%in%names(x)))
}
dict<-read.csv('data/data_dictionary.csv',check.names=FALSE)
stopifnot(nrow(dict)==29L,all(c('ANON_PSU_ID','ANON_STRATUM_ID','DUPLICATE_SENSITIVITY_GROUP','DUPLICATE_ROW_VERSION')%in%dict$variable))
ig<-readLines('.gitignore',warn=FALSE)
stopifnot(all(c('data/PONE_D_26_05990_minimal_analytical.csv','*.sav','*.dta','*.rds','*.RData','.env','.Rhistory','.Rproj.user/','credentials*','token*','secret*','private/','governance/')%in%ig))
for(f in list.files('R',pattern='[.]R$',full.names=TRUE))parse(f)
r<-file.path(R.home('bin'),'Rscript')
call<-function(a)suppressWarnings(system2(r,c('R/run_all.R',a),stdout=TRUE,stderr=TRUE))
had_output<-dir.exists('reproduced_outputs')
a<-call(character());stopifnot(is.null(attr(a,'status')),any(grepl('RESTRICTED_DATA_REQUIRED',a,fixed=TRUE)))
a<-call('--help');stopifnot(is.null(attr(a,'status')),any(grepl('Usage:',a,fixed=TRUE)))
a<-call(c('--data','__absent_public_qa_file__.csv'));stopifnot(identical(attr(a,'status'),1L),any(grepl('Restricted data file unavailable',a,fixed=TRUE)))
a<-call('--unknown-public-qa-option');stopifnot(identical(attr(a,'status'),1L))
stopifnot(identical(dir.exists('reproduced_outputs'),had_output))
cat('PASS: public payload, dictionary, ignore rules, R syntax, help, no-data, missing-file and invalid-option contracts. No analysis or network access executed.\n')
