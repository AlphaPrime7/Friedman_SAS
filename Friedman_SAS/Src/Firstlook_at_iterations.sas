data disney.fry_test/view=disney.fry_test;
set disney.fry;
array vars[*] crp_pre crp_mid crp_post;                  *array of your columns to transpose;
do _t = 1 to dim(vars);              *iterate over the array (dim(vars) gives # of elements);
  if not missing(vars[_t]) then do;  *if the current array element's value is nonmissing;
    crp_id=vname(vars[_t]);            *then store the variable name from that array element in a var;
    crp_level=vars[_t];                   *and store the value from that array element in another var;
    output;                          *and finally output that as a new row;
  end;
end;                
drop crp_pre crp_mid crp_post _t
run;


