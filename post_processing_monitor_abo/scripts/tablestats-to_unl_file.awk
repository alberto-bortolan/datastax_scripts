BEGIN {
  tablestats_file=outfile ".csv"
  keyspace=""; 
  tablename = "";
  tab_section=0;
  OFS=",";
  ts=""
  m=split("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec", d," ");
  for(o=1;o<=m;o++){
      month[d[o]]=sprintf("%02d",o)
  }
 }

function dump_it()
{
   print t["ts"],
      hostname,
      ip,
      runid,
      t["keyspace"],
      t["tablename"],    
      t["SSTable count"],
      t["Space used (live)"],
      t["Space used (total)"],
      t["Space used by snapshots (total)"],
      t["Off heap memory used (total)"],
      t["SSTable Compression Ratio"],
      t["Number of partitions (estimate)"],
      t["Memtable cell count"],
      t["Memtable data size"],
      t["Memtable off heap memory used"],
      t["Memtable switch count"],
      t["Local read count"],
      t["Local read latency"],
      t["Local write count"],
      t["Local write latency"],
      t["Pending flushes"],
      t["Percent repaired"],
      t["Bytes repaired"],
      t["Bytes unrepaired"],
      t["Bytes pending repair"],
      t["Bloom filter false positives"],
      t["Bloom filter false ratio"],
      t["Bloom filter space used"],
      t["Bloom filter off heap memory used"],
      t["Index summary off heap memory used"],
      t["Compression metadata off heap memory used"],
      t["Compacted partition minimum bytes"],
      t["Compacted partition maximum bytes"],
      t["Compacted partition mean bytes"],
      t["Average live cells per slice (last five minutes)"],
      t["Maximum live cells per slice (last five minutes)"],
      t["Average tombstones per slice (last five minutes)"],
      t["Maximum tombstones per slice (last five minutes)"],
      t["Dropped Mutations"],
      t["Failed Replication Count"] >> tablestats_file;

   split("", t)  #should clean it up
}

function is_integer(x) { return ( x ~ /^[0-9]+$/ ) }

function na(id)
{ if (id =="NaN" || id=="null")
     return 0;
  return id;
}

function tokb(inm)
{ bb=substr(inm,1,length(inm)-4);
  m=substr(inm,length(inm)-3,3);
  switch(m)
  {  case "MiB":
        bb=substr(bb,1,length(bb)-1) * 1024;
        break;

     case "GiB":
        bb=substr(bb,1,length(bb)-1) *1024 *1024;
        break;
	   
     case "TiB":
	bb=substr(bb,1,length(bb)-1) * 1024 *1024 * 1024;
        break;
   }
   return bb;
}

#trick to avoid changing the different date interpretations. Position of include is IMPORTANT
@include "date-general.awk"

$1=="Keyspace" { keyspace=$3;next; }

$1=="Table:" { if ( length(tablename)>0 ) dump_it(); tablename=$2; tab_section=1; t["ts"]=ts; t["tablename"]=tablename; t["keyspace"]=keyspace; next;}

/^$/ { tab_section=0;next;}

{ if (tab_section!= 1)
     next;
  
  a=index($0,$1); 
  b=index($0,":"); 
  label=substr($0,a,b-a);
  
  #most are numbers on $NF but there are some ms and some with KiB MiB
  if ( $1 == "Local"  && $3 =="latency:")
     t[label] = na($(NF-1));   #$NF is "ms"
  else if ($1 == "Bytes")
     t[label] = tokb($NF); 
  else
     t[label]=na($(NF));;
}

END {dump_it()};
