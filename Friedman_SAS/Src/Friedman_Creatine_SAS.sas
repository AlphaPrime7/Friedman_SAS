* author: Tingwei Adeck
* date: 2022-11-13
* purpose: Friedman (Nonparametric paired or repeated measures Anova test)
* license: public domain
* Input: friedman.sav
* Output: Friedman_Creatine_SAS.pdf
* Description: Understand the impact of intervention on creatine protein levels
* Results: post intervention creatine levels differ statistically significantly from pre levels;

%let path=/home/u40967678/sasuser.v94;


libname disney
    "&path/sas_umkc/input";
    
filename fry
    "&path/sas_umkc/input/friedman.sav";   
    
ods pdf file=
    "&path/sas_umkc/output/Friedman_Creatine_SAS.pdf";
    
options papersize=(8in 4in) nonumber nodate;

proc import file= fry
	out=disney.fry
	dbms=sav
	replace;
run;

*create a unique id for use in transpose;
data disney.fry_uid;
set disney.fry;
new_id = _N_;
run;

title 'summary of Creatine Protein data';
proc print data =disney.fry_uid;
run;

*need a macro for this;
proc sql;
create table disney.fry_pre as 
	select crp_pre, new_id
from disney.fry_uid;
quit;

proc sql;
create table disney.fry_mid as 
	select crp_mid, new_id
from disney.fry_uid;

quit;

proc sql;
create table disney.fry_post as 
	select crp_post, new_id
from disney.fry_uid;
quit;

*need a macro for this;
proc sql;
	alter table disney.fry_pre add crp_id char (3);
quit;

proc sql;
	alter table disney.fry_mid add crp_id  char (3);
quit;

proc sql;
	alter table disney.fry_post add crp_id char (4);
quit;

*need a macro for this;
proc sql;
	update disney.fry_pre set 
		crp_id = 'pre';
quit;

proc sql;
	update disney.fry_mid set 
		crp_id = 'mid';
quit;

proc sql;
	update disney.fry_post set 
		crp_id = 'post';
quit;

*finally the union step in hard coding-ITERATION WILL BE NEEDED-Will work on an iterative macro for this;
proc sql;
create table disney.fry_transpose as 
	select crp_pre as crp_levels, crp_id, new_id as subject
from disney.fry_pre
union all
	select crp_mid, crp_id, new_id
from disney.fry_mid
union all
	select crp_post, crp_id, new_id
from disney.fry_post;
run;
quit;


title 'summary (first 10 obs) of Creatine Protein data';
proc print data=disney.fry_transpose (obs=10);


title 'Friedman Chi-sq Test';
proc freq data=disney.fry_transpose;
   tables subject*crp_id*crp_levels / 
      cmh2 scores=rank noprint;
run;

title 'Friedman Chi-sq Test';
proc freq data=disney.fry_transpose;
   tables crp_id*crp_levels /
       cmh2 scores=rank noprint;
run;


ods pdf close;
