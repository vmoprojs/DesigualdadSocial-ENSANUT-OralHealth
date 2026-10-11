# Public code record: requires separately authorized restricted data for full execution.
# No network requests, automatic installs, backward selection or scientific decisions.
args<-commandArgs(trailingOnly=TRUE)
usage<-function()cat("Usage: Rscript R/run_all.R --data FILE [--out DIRECTORY] [--descriptives-only]\nData are restricted. Obtain authorized access through the separate analytical data record after deposit. This public package contains no participant data.\n")
if("--help"%in%args){usage();quit(status=0)}
data_file<-NULL;output_arg<-NULL;descriptive_only<-FALSE;i<-1L
while(i<=length(args)){a<-args[i];if(a%in%c("--data","--out")){if(i==length(args)||startsWith(args[i+1L],"--"))stop("Option requires a value",call.=FALSE);if(a=="--data"){if(!is.null(data_file))stop("Repeated data option",call.=FALSE);data_file<-args[i+1L]}else{if(!is.null(output_arg))stop("Repeated output option",call.=FALSE);output_arg<-args[i+1L]};i<-i+2L}else if(a=="--descriptives-only"){descriptive_only<-TRUE;i<-i+1L}else stop("Unknown option; use --help",call.=FALSE)}
if(is.null(data_file)){usage();cat("STATUS: RESTRICTED_DATA_REQUIRED; no analysis was executed.\n");quit(status=0)}
if(!file.exists(data_file))stop("Restricted data file unavailable; verify the authorized local file supplied with --data",call.=FALSE)
script_arg<-grep('^--file=',commandArgs(),value=TRUE);code_dir<-if(length(script_arg))dirname(normalizePath(sub('^--file=','',script_arg[1])))else normalizePath('.')
root<-dirname(code_dir);outdir<-if(is.null(output_arg))file.path(root,'reproduced_outputs')else output_arg
for(p in c('survey','readr','dplyr','ggplot2'))stopifnot(requireNamespace(p,quietly=TRUE))
stopifnot(as.character(packageVersion('survey'))=='4.5')
spec<-dget(file.path(code_dir,'frozen_specification.R'));source(file.path(code_dir,'reproduction_functions.R'))
x<-read.csv(data_file,colClasses='character',check.names=FALSE,na.strings='NA',fileEncoding='UTF-8')
dir.create(outdir,recursive=TRUE,showWarnings=FALSE)
for(n in setdiff(names(x),c('ANON_STRATUM_ID','ANON_PSU_ID','DUPLICATE_SENSITIVITY_GROUP','DUPLICATE_ROW_VERSION')))x[[n]]<-as.numeric(x[[n]])
stopifnot(nrow(x)==spec$expected_rows,all(is.finite(x$FEXP_F4)),all(x$FEXP_F4>0),!anyDuplicated(names(x)))
options(survey.lonely.psu='adjust',survey.adjust.domain.lonely=TRUE)
writeout<-function(z,n)readr::write_csv(z,file.path(outdir,n),na='NA')
m<-as.matrix(x[spec$items$variable]);stopifnot(!anyNA(m),all(m%in%c(0,1)))
x$OHP_NO_SPEECH_SLEEP<-as.integer(rowSums(m[,c(1,2,4,6),drop=FALSE])>0);x$OHP_GE2<-as.integer(rowSums(m)>=2)
d<-design(x);domains<-list(children=subset(d,AGE_GROUP==1),adolescents=subset(d,AGE_GROUP==2));t1<-prev<-comp<-sprev<-list()
for(dn in names(domains)){
 dd<-domains[[dn]]
 for(v in spec$table1)for(code in sort(unique(dd$variables[[v]]))){p<-prop(dd,ifelse(is.na(dd$variables[[v]]),NA,dd$variables[[v]]==code));t1[[paste(dn,v,code)]]<-data.frame(domain=dn,historical_variable=v,category_code=code,unweighted_n=p$events,available_denominator_n=p$n,missing_n=p$missing,weighted_percent=100*p$weighted_prevalence,SE_percent=100*p$SE,CI_low_percent=100*p$CI_low,CI_high_percent=100*p$CI_high)}
 for(y in names(spec$outcomes)){p<-prop(dd,dd$variables[[spec$outcomes[y]]]);prev[[paste(dn,y)]]<-cbind(data.frame(domain=dn,outcome=y),p)}
 for(i in seq_len(nrow(spec$items))){p<-prop(dd,dd$variables[[spec$items$variable[i]]]);comp[[paste(dn,i)]]<-cbind(data.frame(domain=dn,component=spec$items$component[i]),p)}
 for(y in c('OHP_NO_SPEECH_SLEEP','OHP_GE2')){p<-prop(dd,dd$variables[[y]]);sprev[[paste(dn,y)]]<-cbind(data.frame(domain=dn,outcome=y),p)}
}
t1<-dplyr::bind_rows(t1);prev<-dplyr::bind_rows(prev);comp<-dplyr::bind_rows(comp);sprev<-dplyr::bind_rows(sprev)
writeout(t1,'Table1.csv');writeout(prev,'Figure1_data.csv');writeout(comp,'Figure2_data.csv');writeout(sprev,'OHP_sensitivity_prevalence.csv')
figure_plot(prev,c(OHP='Oral health-related impacts',BRUSHING='Brushing less than twice daily',DENTAL='Dental non-attendance')[prev$outcome],file.path(outdir,'Figure1.png'),3.9)
figure_plot(comp,c(pain='Dental pain',eating='Difficulty eating',speech='Difficulty speaking',smiling='Avoiding smiling or laughing',sleep='Sleep disturbance',school='School absenteeism')[comp$component],file.path(outdir,'Figure2.png'),4.7)
if(!descriptive_only){
 co<-gt<-list();add<-function(f){co[[length(co)+1]]<<-f$co;if(!is.null(f$tests))gt[[length(gt)+1]]<<-f$tests}
 for(dn in names(domains))for(y in names(spec$outcomes)){
  for(variant in c('WCS','U0')){
   for(p in spec$predictors)add(fit_fixed(domains[[dn]],y,p,dn,'CRUDE',variant=variant))
   add(fit_fixed(domains[[dn]],y,terms_for(y,dn),dn,'HISTORICAL_ADJUSTED',variant=variant))
   add(fit_fixed(domains[[dn]],y,spec$predictors,dn,'LEGACY_FULL_ADJUSTED',variant=variant))
  }
  add(fit_fixed(domains[[dn]],y,terms_for(y,dn,TRUE),dn,'FINAL',orientation='L3',locked=TRUE))
  cat('Validated specification',dn,y,'\n')
 }
 for(dn in names(domains))for(y in c('OHP_NO_SPEECH_SLEEP','OHP_GE2')){
  add(fit_fixed(domains[[dn]],y,terms_for('OHP',dn),dn,'OHP_SENSITIVITY_HISTORICAL'))
  add(fit_fixed(domains[[dn]],y,spec$predictors,dn,'OHP_SENSITIVITY_FULL'))
 }
 primary<-dplyr::bind_rows(co);writeout(primary,'Primary_model_coefficients.csv');writeout(dplyr::bind_rows(gt),'Primary_global_tests.csv')
 cr<-orient_crude(subset(primary,role=='CRUDE'&variant=='WCS'));adj<-subset(primary,role=='FINAL'&predictor!='(Intercept)')
 for(y in names(spec$outcomes)){a<-subset(cr,outcome==y);b<-subset(adj,outcome==y);writeout(dplyr::bind_rows(a,b),paste0('Table',match(y,names(spec$outcomes))+1,'.csv'))}
 exact<-merge(subset(primary,variant=='U0'&predictor!='(Intercept)'),subset(primary,variant=='WCS'&role%in%c('CRUDE','HISTORICAL_ADJUSTED','LEGACY_FULL_ADJUSTED')&predictor!='(Intercept)'),by=c('domain','outcome','role','predictor','term'),suffixes=c('_U0','_WCS'))
 exact$nominal_crossing<-(exact$p_value_U0<.05)!=(exact$p_value_WCS<.05);exact$SE_ratio<-exact$SE_WCS/exact$SE_U0;exact$OR_ratio<-exact$OR_WCS/exact$OR_U0;writeout(exact,'Exact_U0_WCS.csv')
 z<-subset(exact,role=='HISTORICAL_ADJUSTED');writeout(data.frame(contrasts=nrow(z),crossings=sum(z$nominal_crossing),median_SE_ratio=median(z$SE_ratio),median_OR_ratio=median(z$OR_ratio)),'Headline.csv')
 # No term-selection algorithm: recalculate only the six frozen final formulas
 # and the six old historical formulas in every predeclared duplicate scenario.
 sens<-tests<-list();scenarios<-c(sort(apply(expand.grid(rep(list(c('A','B')),4),stringsAsFactors=FALSE),1,paste0,collapse='')),'UNIQUE18797')
 for(sc in scenarios){
  keep<-x$DUPLICATE_SENSITIVITY_GROUP=='0'
  if(sc!='UNIQUE18797'){v<-strsplit(sc,'')[[1]];j<-match(x$DUPLICATE_SENSITIVITY_GROUP,sprintf('D%02d',1:4));q<-x$DUPLICATE_ROW_VERSION==v[j];q[is.na(q)]<-FALSE;keep<-keep|q}
  sd<-design(x[keep,],full=TRUE);ds<-list(children=subset(sd,AGE_GROUP==1),adolescents=subset(sd,AGE_GROUP==2))
  for(dn in names(ds))for(y in names(spec$outcomes))for(role in c('HISTORICAL_ADJUSTED','FINAL')){
   f<-fit_fixed(ds[[dn]],y,terms_for(y,dn,role=='FINAL'),dn,role,scenario=sc,orientation=if(role=='FINAL')'L3'else'L2',locked=role=='FINAL');sens[[length(sens)+1]]<-f$co;if(!is.null(f$tests))tests[[length(tests)+1]]<-f$tests
  }
  cat('Duplicate scenario',sc,'complete\n')
 }
 writeout(dplyr::bind_rows(sens),'Duplicate_sensitivity_coefficients.csv');writeout(dplyr::bind_rows(tests),'Duplicate_sensitivity_global_tests.csv')
 options(survey.adjust.domain.lonely=FALSE);vv<-list()
 for(dn in names(domains))for(y in names(spec$outcomes)){f<-fit_fixed(domains[[dn]],y,terms_for(y,dn,TRUE),dn,'FINAL',variant='WCS_NO_DOMAIN_ADJUST',orientation='L3',locked=TRUE);vv[[length(vv)+1]]<-f$co}
 writeout(dplyr::bind_rows(vv),'Variance_sensitivity_coefficients.csv');options(survey.adjust.domain.lonely=TRUE)
}
writeLines(capture.output(sessionInfo()),file.path(outdir,'sessionInfo.txt'))
writeout(data.frame(mode=if(descriptive_only)'DESCRIPTIVES_ONLY'else'FROZEN_SPECIFICATION_REPRODUCTION',rows=nrow(x),backward_executed=FALSE,private_inputs_used=FALSE),'execution_status.csv')
cat('Reproduction finished:',if(descriptive_only)'descriptives only'else'frozen specifications','\n')
