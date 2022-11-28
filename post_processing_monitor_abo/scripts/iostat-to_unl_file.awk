

#from netcracker
       # print "hostname",hostname;
       # print "ip: ",ip;
       # print "runid: ",runid;       #this could be an ID so that if there are multiple collections, I discriminate
       # print "outfile: ",outfile;   #should be complete of path but no extenstion I'll then complete it
       
       
#FORMAT
#08/11/2022 08:09:11 PM
#avg-cpu:  %user   %nice %system %iowait  %steal   %idle
#          20.24    0.00    6.18    0.05    0.00   73.54
#
#Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await r_await w_await  svctm  %util
#fd0               0.00     0.00    0.00    0.00     0.00     0.00     8.00     0.00   42.43   42.43    0.00  42.43   0.00
       
function dumpit() {
   OFS=","                        #should not call them csv if I use | as separator
   print point,
              hostname,
              ip,
              runid,
         cpu["user"],
         cpu["nice"],
         cpu["system"],
         cpu["iowait"],
         cpu["steal"],
         cpu["idle"]   >> cpu_file

   for (dname in ddisk)
   { #print dname   #debug
     print point,
           hostname,
           ip,
           runid,
           dname,
           ddisk[dname]["rrqm_s"],
           ddisk[dname]["wrqm_s"],
           ddisk[dname]["r_s"],
           ddisk[dname]["w_s"],
           ddisk[dname]["rkB_s"],
           ddisk[dname]["wkB_s"],
           ddisk[dname]["avgrq_sz"],
           ddisk[dname]["avgqu_sz"],
           ddisk[dname]["await"],
           ddisk[dname]["r_await"],
           ddisk[dname]["w_await"],
           ddisk[dname]["svctm"],
           ddisk[dname]["util"] >> disk_file
    }
    state=0;
}

BEGIN {
  cpu_file=outfile "-cpu.csv"
  disk_file=outfile "-disk.csv"
  #internals
#  split("", cpu);
#  split("", ddisk);
  state=0;
  c=0;
}

#this is messy and ambiguous (month/day day/month)! TODO: enforce S_TIME_FORMAT=ISO before running iostat to get ISO dates!
/^12\/09\/22/ { if (state >0) 
                { dumpit() } 
		c++; 
		if ( (c % 100) == 0) 
		     print c;
	        # do the following anyway 
		state=1;
		z=split($1,d,"/");
		z=split($2,t,":");
		if ( $3=="PM")
                {  if (t[1]!=12)
		     t[1]+=12;
		}
		else if ($3=="AM")
		{ if (t[1] == "12") 
		      t[1] = "00";
		}
                if (length(d[3])<4)
                   d[3]="20" d[3];
		point=sprintf("%s-%s-%s %s:%s:%s",d[3],d[2],d[1],t[1],t[2],t[3]);	
                next;
	     }  
$1=="avg-cpu:" { state=2; next;}
$1=="Device:"  { state=5; next;}
/^$/ { if (state==3) {state=4;} next}   #I used to dump here but it may not be ok

{ #applies to every non empty row. Use as last
  sstate=state;
  switch (sstate)
  {
     case 2:
        state=3;
	break;

     case 5:
        state=6;
        break;
   }

   switch(state)	    
   {
     case 3:  #time to gather CPU
	cpu["user"]=$1;
        cpu["nice"]=$2;
        cpu["system"]=$3; 
        cpu["iowait"]=$4; 
        cpu["steal"]=$5; 
        cpu["idle"]=$6; 
	break;
		 
     case 6:  #we are in disk territory. Multiple disk in general. How do I create the data?
        #print point,$1
        x=$1 
        ddisk[x]["rrqm_s"]=$2;	 
        ddisk[x]["wrqm_s"]=$3;	 
        ddisk[x]["r_s"]=$4;
        ddisk[x]["w_s"]=$5;
        ddisk[x]["rkB_s"]=$6;
        ddisk[x]["wkB_s"]=$7;
        ddisk[x]["avgrq_sz"]=$8;
        ddisk[x]["avgqu_sz"]=$9;
        ddisk[x]["await"]=$10;
        ddisk[x]["r_await"]=$11;
        ddisk[x]["w_await"]=$12;
        ddisk[x]["svctm"]=$13;
        ddisk[x]["util"]=$14;
	break;
   }
}

END { dumpit() }	
