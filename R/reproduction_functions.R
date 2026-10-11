# Portable reproduction from the minimal candidate. No private-source access.
quiet<-function(expr)withCallingHandlers(expr,warning=function(w)invokeRestart('muffleWarning'))
prepare<-function(d,y,orientation='L2'){
 v<-d$variables;base_y<-if(y%in%names(spec$outcomes))y else'OHP'
 for(p in names(spec$maps)){
  m<-spec$maps[[p]];v[[p]]<-factor(v[[spec$source[p]]],levels=m[[1]],labels=m[[2]])
  if(orientation=='L3'){ref<-spec$references$reference[spec$references$outcome==base_y&spec$references$predictor==p];stopifnot(length(ref)==1);v[[p]]<-relevel(v[[p]],ref)}else{
   if(base_y=='DENTAL'&&p=='AREA')v[[p]]<-relevel(v[[p]],'Rural')
   if(base_y%in%c('BRUSHING','DENTAL')&&p=='SEX')v[[p]]<-relevel(v[[p]],'Female')
  }
  contrasts(v[[p]])<-contr.treatment(levels(v[[p]]),base=1)
 }
 for(p in spec$continuous)v[[p]]<-v[[spec$source[p]]]
 v$.Y<-v[[if(y%in%names(spec$outcomes))spec$outcomes[y]else y]];d$variables<-v;d
}
design<-function(x,full=FALSE){
 x$.member<-TRUE
 if(full){
  # One zero-contribution synthetic record for each missing sampled PSU.
  # This retains full-frame first-stage nPSU without releasing other persons.
  g<-unique(x[c('ANON_STRATUM_ID','ANON_PSU_ID')]);ns<-table(g$ANON_STRATUM_ID);pad<-list()
  for(st in names(spec$full_psu_counts)){
   present<-if(st%in%names(ns))as.integer(ns[st])else 0L
   missing<-spec$full_psu_counts[st]-present;stopifnot(missing>=0)
   if(missing){z<-x[rep(NA_integer_,missing),,drop=FALSE];z$ANON_STRATUM_ID<-st;z$ANON_PSU_ID<-paste0('EMPTY_',st,'_',seq_len(missing));z$FEXP_F4<-1;z$.member<-FALSE;pad[[st]]<-z}
  }
  x<-dplyr::bind_rows(c(list(x),pad))
 }
 d<-survey::svydesign(ids=~ANON_PSU_ID,strata=~ANON_STRATUM_ID,weights=~FEXP_F4,nest=TRUE,data=x)
 if(full)d<-subset(d,.member);d
}
prop<-function(d,v){
 keep<-!is.na(v);dd<-d[keep,];dd$variables$.PROP<-as.numeric(v[keep]);e<-quiet(survey::svyciprop(~.PROP,dd,method='logit',df=survey::degf(dd)));ci<-confint(e)
 data.frame(n=sum(keep),missing=sum(!keep),events=sum(v[keep]),unweighted=mean(v[keep]),weighted_prevalence=as.numeric(e),SE=as.numeric(survey::SE(e)),CI_low=ci[1],CI_high=ci[2])
}
fit_fixed<-function(d,y,pred,domain,role,scenario='RAW18805',variant='WCS',orientation='L2',locked=FALSE){
 d<-prepare(d,y,orientation);cc<-complete.cases(d$variables[,c('.Y',if(locked)spec$predictors else pred),drop=FALSE]);dd<-d[cc,]
 f<-reformulate(pred,response='.Y');ordinary<-variant=='U0'
 m<-quiet(if(ordinary)stats::glm(f,data=dd$variables,family=binomial(),na.action=na.fail)else survey::svyglm(f,design=dd,family=quasibinomial(),na.action=na.fail))
 b<-coef(m);se<-sqrt(diag(vcov(m)));rdf<-df.residual(m);crit<-if(ordinary)qnorm(.975)else qt(.975,rdf)
 parent<-c('(Intercept)',attr(terms(m),'term.labels'))[attr(model.matrix(m),'assign')+1L]
 cmp<-vapply(seq_along(b),function(i){p<-parent[i];if(p=='(Intercept)')'Intercept'else if(p%in%spec$continuous)if(p=='HH_SIZE')'+1 household member'else'+1 year'else paste(substring(names(b)[i],nchar(p)+1),'vs',levels(dd$variables[[p]])[1])},'')
 out<-data.frame(scenario=scenario,domain=domain,outcome=y,role=role,variant=variant,predictor=parent,term=names(b),comparison=cmp,beta=unname(b),SE=unname(se),OR=exp(unname(b)),CI_low=exp(unname(b-crit*se)),CI_high=exp(unname(b+crit*se)),p_value=unname(if(ordinary)2*pnorm(-abs(b/se))else 2*pt(-abs(b/se),rdf)),residual_df=rdf,design_df=survey::degf(dd),model_n=sum(cc))
 stopifnot(m$converged,all(is.finite(out$beta)),all(is.finite(out$SE)),all(out$SE>0))
 tests<-NULL
 if(orientation=='L3'){
  tests<-dplyr::bind_rows(lapply(pred,function(p){q<-quiet(survey::regTermTest(m,reformulate(p),method='Wald',df=rdf));data.frame(scenario=scenario,domain=domain,outcome=y,role=role,variant=variant,predictor=p,numerator_df=as.numeric(q$df),denominator_df=as.numeric(q$ddf),F_statistic=as.numeric(q$Ftest),global_p=as.numeric(q$p))}))
  out$global_term_p<-tests$global_p[match(out$predictor,tests$predictor)]
 }
 list(co=out,tests=tests)
}
terms_for<-function(y,dn,final=FALSE){a<-if(final)spec$final else spec$historical;f<-if(final)'survey_backward_final_terms'else'terms';strsplit(a[[f]][a$outcome==y&a$domain==dn],' + ',fixed=TRUE)[[1]]}
orient_crude<-function(z){
 z<-z[z$predictor!='(Intercept)',]
 for(i in seq_len(nrow(z))){p<-z$predictor[i];if(p%in%spec$continuous)next;ref<-spec$references$reference[spec$references$outcome==z$outcome[i]&spec$references$predictor==p];cmp<-strsplit(z$comparison[i],' vs ',fixed=TRUE)[[1]]
  if(cmp[2]!=ref){stopifnot(length(spec$maps[[p]][[1]])==2,cmp[1]==ref);z$beta[i]<- -z$beta[i];z$OR[i]<-1/z$OR[i];lo<-z$CI_low[i];z$CI_low[i]<-1/z$CI_high[i];z$CI_high[i]<-1/lo;z$term[i]<-paste0(p,cmp[2]);z$comparison[i]<-paste(cmp[2],'vs',cmp[1])}
 };z
}
figure_plot<-function(dat,labels,file,height){
 dat$group<-factor(dat$domain,levels=c('children','adolescents'),labels=c('Children','Adolescents'));dat$label<-factor(labels,levels=rev(unique(labels)))
 p<-ggplot2::ggplot(dat,ggplot2::aes(x=100*weighted_prevalence,y=label,color=group,shape=group))+ggplot2::geom_errorbar(ggplot2::aes(xmin=100*CI_low,xmax=100*CI_high),position=ggplot2::position_dodge(width=.55),width=.16,orientation='y')+ggplot2::geom_point(position=ggplot2::position_dodge(width=.55),size=2.6)+ggplot2::scale_color_manual(values=c('#146B77','#B24D28'))+ggplot2::scale_shape_manual(values=c(16,17))+ggplot2::labs(x='Survey-weighted prevalence (95% CI)',y=NULL,color=NULL,shape=NULL)+ggplot2::theme_classic(base_size=11)+ggplot2::theme(legend.position='top')
 ggplot2::ggsave(file,p,width=7,height=height,dpi=300)
}
