BEGIN {
  pools_file=outfile "-pools.csv"
  tpcpools_file=outfile "-tpcpools.csv"
  meter_file=outfile "-meter.csv"
  messages_file=outfile "-messages.csv"

  #internals
  state=0;   #1=pools,2=meter,3=pre-msg,4=messages 
  OFS=",";
  ts="NO DATE"
  m=split("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec", d," ");
  for(o=1;o<=m;o++){
      month[d[o]]=sprintf("%02d",o)
  }
}

function na(id)
{ if (id =="N/A")
     return 0;
  return id;
}

(NF<1) {state=0;next;} 

#trick to avoid changing the different date interpretations. Position of include is IMPORTANT
@include "date-general.awk"

$1=="Pool" {state=1; next;}            #6.7, 6.8 may be different
$1=="Meters" {state=2; next;}          #does not exist in 6.7
$1=="Message" {state=3; next;}
$1=="50%" {if (state==3) state=4;next;}

{ 
   if ( state == 1) 
   { # we are in pools territory
     #two types: non-tpc and tpc
	 # converted N/A to 0 to make things easier
	 
     if (substr($1,0,3)=="TPC")
     {  #TPC/group/pool  (if no pool use TOTAL)
        #ts,hostname,ip,runid,group,pool,active,pending,completed,blocked,all_blocked 
        
	nn=split($1,tpc,"/");
        if (nn==2)
           tpc[3]="TOTAL";
        print ts,
              hostname,
	      ip,
	      runid,
			  tpc[2],
			  tpc[3],
           #   $2,na($3),na($4),na($5),$6,$7,$8,na($9),na($10) >> tpcpools_file         #6.8
	       $2,na($3),$6,na($7),na($8) >> tpcpools_file         #6.7 no stolen/completed skipped w/backpressure and delayed as all N/A
	 }
	 else
	 { 	 #NON TPC removed "backpressure,delayed,shared,stolen,"
         #ts,hostname,ip,runid,pool,active,pending,completed,blocked,all_blocked  
         print ts,
              hostname,
	      ip,
	      runid,
               $1,$2,na($3),$6,$7,$8 >> pools_file
     }			   
   }
   else if ( state == 2) 
   { # we are in METERS territory
     #ts,hostname,ip,rounid,group,meter,one_min_rate,five_min_rate,fifteen_min_rate,mean_rate,count,connections
	 nn=split($1,tpc,"/");
     print ts,
              hostname,
	      ip,
	      runid,
		 tpc[2],
		 tpc[3],
         $2,$3,$4,$5,$6,$7 >> meter_file  
   }
   else if ( state == 4)
   {  # we are in MESSAGES territory
      #ts,test_name,hostname,hostnum,messages,dropped,p50,p95,p99,pmax
     print ts,
              hostname,
	      ip,
	      runid,
		 $1,$2,na($3),na($4),na($5),na($6) >> messages_file
		 
   }   
}   
