BEGIN {
  tablehistograms_file=outfile ".csv"

  #internals
  state=0;   #1=RR  2=pool
  OFS=",";
  ts="NO DATE"
  m=split("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec", d," ");
  for(o=1;o<=m;o++){
      month[d[o]]=sprintf("%02d",o)
  }
  keyspace="NOTHING"
  tabname="NOTHING"
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

$2=="histograms" { state=0; split($1,names,"/"); keyspace=names[1]; tabname=names[2];next;}
$1=="Percentile" {next;}
$1=="(micros)" {state=1; next;}

{ 
  if ( state == 1) 
   { 
     #change name xx% to pxx
     if ( is_integer(substr($1,0,2)) )
        p1=sprintf("p%s",substr($1,0,2));
     else
        p1=tolower($1)
	  
   	 #ts,hostname,ip,runid,percentile,keyspace,tabname,sstables,w_latency,r_latency,part_size,cell_count
        print ts,
              hostname,
	      ip,
	      runid,
              keyspace,tabname,p1,$2,$3,$4,na($5),na($6)  >> tablehistograms_file
	}
}	


#SOLUTION 1 <-used this
#
#percentile,sstables,r_lat,w_lat,part_size,cell_count
#
#SOLUTION 2
#
#p50_sstables,p50_r_lat,p50_w_lat,p50_part_size,p50_cell_count
#p75_sstables,p75_r_lat,p75_w_lat,p75_part_size,p75_cell_count
#p95_sstables,p95_r_lat,p95_w_lat,p95_part_size,p95_cell_count
#p98_sstables,p98_r_lat,p98_w_lat,p98_part_size,p98_cell_count
#p99_sstables,p99_r_lat,p99_w_lat,p99_part_size,p99_cell_count
#min_sstables,min_r_lat,min_w_lat,min_part_size,min_cell_count
#max_sstables,max_r_lat,max_w_lat,max_part_size,max_cell_count
