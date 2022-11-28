BEGIN {
  cpu_file=outfile "-cpu.csv"
  interrupt_file=outfile "-interrupt.csv"
  day="2022-09-12"
  #internals
  state=0;   #1=cpu section, 2=in between 3=interrupt
  OFS=",";
  print cpu_file
  print interrupt_file
}

function fullts(in_time,ampm)
{ 
  z=split(in_time,t,":");
  if ( ampm=="PM")
     {  if (t[1]!=12)
        t[1]+=12;
  }
  else
  { if (t[1] == "12") 
        t[1] = "00";
  }	
  return sprintf("%s %s:%s:%s",day,t[1],t[2],t[3]);	
}

(NF<1) {next;} 
#important: if the time has AM/PM it's all shifted!
$3=="%usr" {state=1; next;}
$3=="HI/s" {state=2; next;}

{ 
   if ( state == 1) 
   { # we are in CPU territory
     #ts,test_name,hostname,hostnum,cpu,usr,nice,sys,iowait,irq,soft,steal,guest,gnice,idle
     #print fullts($1,$2),
      print day " " $1,    
           hostname,
	   ip,
	   runid,
         $2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12 >> cpu_file   
   }
   else if ( state == 2)
   { # we are in INTERRUPT territory
     #ts,test_name,hostname,hostnum,cpu,hi,timer,net_tx,net_rx,block,irq_poll,tasklet,sched,hrtimer,rcu
     #print fullts($1,$2),  for AM PM check if it can be forced to be 24h! and ISO
     print day " " $1,
           hostname,
	   ip,
	   runid,
           $2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12 >> interrupt_file   
   
   }
}   
