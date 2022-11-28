#
# WRITTEN for A 6.7 output
# uses 2 out files! how to do with automation?
#
BEGIN {
       # print "hostname",hostname;
       # print "ip: ",ip;
       # print "runid: ",runid;       #this could be an ID so that if there are multiple collections, I discriminate
       # print "outfile: ",outfile;   #should be complete of path but no extenstion I'll then complete it

  #internals
  state=0;   #1=RR  2=pool
  OFS=",";
  ts="NO DATE"
  m=split("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec", d," ");
  for(o=1;o<=m;o++){
      month[d[o]]=sprintf("%02d",o)
  }
  rr["Attempted"]=0;
  rr["Blocking"]=0;
  #rr["ReconcileRead"]=0;   #this is not on 6.7  
  rr["Background"]=0;   

  rr_file=outfile "-rr.csv"
  messages_file=outfile "-messages.csv"           # <<<note this has 2 out files!
}

function is_integer(x) { return ( x ~ /^[0-9]+$/ ) }

(NF<1) {state=0;next;} 

#trick to avoid changing the different date interpretations. Position of include is IMPORTANT
@include "date-general.awk"

$1=="Read Repair Statistics:" {state=1; next;}
$1=="Attempted:" {rr["Attempted"]=$2; next;}
$1=="Mismatch" { rr[substr($2,2,length($2)-3)]=$3; next;}
$1=="Pool" { 
    state=2; 
	#ts,hostname,ip,run_id,attempted,blocking,reconcile,background
        print ts,
              hostname,
	      ip,
	      runid,
	      rr["Attempted"],
	      rr["Blocking"],
	      rr["Background"] >> rr_file ;
  next;
}  

{ 
   if ( state == 2) 
   {    
   	   #ts,hostname,ip,run_id,msgtype,pending,completed,dropped
        print ts,
              hostname,
	      ip,
	      runid,
              $1,$4,$5,$6 >> messages_file
	}
}	


#Example record (6.7)
# 
#Thu Aug 11 20:09:15 +03 2022                                 <! GMT+3
#==========
#Mode: NORMAL
#Not sending any streams.
#Read Repair Statistics:
#Attempted: 43683925
#Mismatch (Blocking): 2407160
#Mismatch (Background): 114645
#Pool Name                    Active   Pending      Completed   Dropped
#Large messages                  n/a         0          38110         0
#Small messages                  n/a         0     6136849251      3501
#Gossip messages                 n/a         0        2375402         0
#

#example record (DSE 6.8)
#
#Sat Apr 16 10:39:57 CEST 2022
#Mode: NORMAL
#Not sending any streams.
#Read Repair Statistics:
#Attempted: 0
#Mismatch (Blocking): 2606
#Mismatch (ReconcileRead): 0
#Mismatch (Background): 0
#Pool Name                    Active   Pending      Completed   Dropped
#Large messages                  n/a         0             30         0
#Small messages                  n/a         4        8443404         0
#Gossip messages                 n/a         0           6208         0
#

