BEGIN {
  ttop_detail=outfile "-detail.csv" 
  ttop_onlycore=outfile "-onlycore.csv"   
  ttop_summary=outfile "-summary.csv" 

  #internals
  state=0;   #decide what 1+ is
  OFS=",";
  ts="NO DATE";
  summary["proc_cpu"]=0; 
  summary["app_cpu"]=0;
  summary["app_cpu_user"]=0;  
  summary["app_cpu_sys"]=0;  
  summary["other_cpu"]=0;  
  summary["thread_count"]=0;
  summary["heap_allocation_rate"] =0  ;
}

function printsummary()
{  #ts,test_name,hostname,hostnum,proc_cpu,app_cpu,app_cpu_user,app_cpu_sys,other_cpu,thread_count,heap_allocation_rate
  print ts,
              hostname,
	      ip,
	      runid,
  summary["proc_cpu"],
  summary["app_cpu"],
  summary["app_cpu_user"],  
  summary["app_cpu_sys"],  
  summary["other_cpu"],  
  summary["thread_count"],
  summary["heap_allocation_rate"]  >>ttop_summary;
}

#may need a fix in the case b/s
function membytes(inm)
{ bb=substr(inm,1,length(inm)-3);   #no for b/s
  m=substr(bb,length(bb),1);
  switch(m)
  {  case "k":
          bb=substr(bb,1,length(bb)-1) * 1024;
          break;

        case "m":
           bb=substr(bb,1,length(bb)-1) *1024 *1024;
           break;
   }
   return bb;
}

function getnum(inm)
{  a=index(inm,"=");
   b=index(inm,"%");
   return substr(inm,a+1,b-a-1);
}

(NF<1) {if (state>0) printsummary(); state=0; next;} 
$NF=="summary" {state=1; ts=substr($1,0,index($1,"+")-1); next} 

$1=="process" {summary["proc_cpu"]=getnum($2); next;}
$1=="application" { 
    summary["app_cpu"]=getnum($2);
    summary["app_cpu_user"]=getnum($3);
    summary["app_cpu_sys"]=getnum($4);	
	next;
}

$1=="other:" { summary["other_cpu"]=getnum($2); next;}

$1=="thread" {summary["thread_count"]=$3; next;}  #done
$1=="heap" { summary["heap_allocation_rate"] = membytes($NF); next;}

/^\[/ {
   #in here detail
   gsub(/user=|sys=|alloc=|%/,"",$0);
   
   #ts,test_name,hostname,hostnum,tid,user,sys,alloc,name
   thname=substr($0,index($0," - ")+3);
   tid=substr($1,2,length($1)-2);
   us=$2;
   sy=$3;
   al=membytes($4);
   print ts,
              hostname,
	      ip,
	      runid,
     tid,us,sy,al,"\""thname"\"" >> ttop_detail;
	 
  #ts,test_name,hostname,hostnum,core,user,sys,alloc
  if ( substr(thname,1,10) == "CoreThread")
  { print ts,
              hostname,
	      ip,
	      runid,
	substr(thname,index(thname,"-")+1),us,sy,al >> ttop_onlycore;  
  
  }
}

END {if (state>0) printsummary()}