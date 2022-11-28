function reset_it() {skip=1; compaction=0; core=0; narr=0;}

function dumpit(out_file)
{ for (i=1;i<=narr;i++)
    print th[i] >> out_file;
  print " " >> out_file;
}

BEGIN {reset_it();
       core_file=outfile "-" ip "-core.out"  
       compaction_file=outfile "-" ip "-compaction.out"  
}

$1 == "Thread" { if ($7 ~ /^CoreThread-/) {skip=0;core=1; th[++narr]=$0;}
                 else if ($7 ~ /^CompactionExecutor/) {skip=0;compaction=1;th[++narr]=$0;}
		 else {reset_it()}
		 next;
	       }
	       
/^$/ { if (skip==0)
       { if (core == 1) dumpit(core_file);
         else if (compaction == 1) dumpit(compaction_file);
         reset_it();
	 next;
       }
  
     }
       
{ if (skip ==1) next;

  if (core == 1)
  { if ( narr <=7 && ( $0 == "io.netty.channel.epoll.Native.epollWait0(Native Method)" || $0 == "org.apache.cassandra.concurrent.EpollTPCEventLoopGroup$SingleCoreEventLoop.waitForWork(EpollTPCEventLoopGroup.java:566)" || $0 == "org.apache.cassandra.concurrent.EpollTPCEventLoopGroup$SingleCoreEventLoop.waitForWork(EpollTPCEventLoopGroup.java:566)"))
       { reset_it(); }
    else 
       th[++narr]=$0; 
  }    
  else if ( compaction == 1) th[++narr]=$0;

}
