BEGIN {
  proxyhistograms_file=outfile ".csv"

  #internals
  state=0;   #1=RR  2=pool
  OFS=",";
  ts="NO DATE"
  m=split("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec", d," ");
  for(o=1;o<=m;o++){
      month[d[o]]=sprintf("%02d",o)
  }
}

function is_integer(x) { return ( x ~ /^[0-9]+$/ ) }

function na(id)
{ if (id =="NaN")
     return 0;
  return id;
}

(NF<1) {state=0;next;} 

#trick to avoid changing the different date interpretations. Position of include is IMPORTANT
@include "date-general.awk"

#$2=="histograms" { state=0; split($1,names,"/"); keyspace=names[1]; tabname=names[2];next;}
#$0=="proxy histograms" {next;}
$1=="(micros)" {state=1; next;}

{ 
  if ( state == 1) 
   { 
     #change name xx% to pxx
     if ( is_integer(substr($1,0,2)) )
        p1=sprintf("p%s",substr($1,0,2));
     else
        p1=tolower($1)
	  
   	 #ts,test_name,hostname,hostnum,percentile,write_latency,read_latency,range_latency,cas_r_latency,cas_w_latency,view_write_latency
        print ts,
              hostname,
	      ip,
	      runid,
              p1,$2,$3,$4,$5,$6,$7  >> proxyhistograms_file
	}
}	

