#
# this script is HIGHLY dependent on the version of DSE generating the log, since most filtering is based 
# on source code lines which are good to effectively filter the lines but changes with each release!
# THIS IS FOR 6.0.12

function tobytes(inm)
{  bb=substr(inm,1,length(inm)-3);
  m=substr(inm,length(inm)-2,3);
  switch(m)
  {  
     case "KiB":
        bb=substr(bb,1,length(bb)-1) * 1024;
        break;
	
     case "MiB":
        bb=substr(bb,1,length(bb)-1) * 1024 *1024;
        break;

     case "GiB":
        bb=substr(bb,1,length(bb)-1) *1024 * 1024* 1024;
        break;

     case "TiB":
        bb=substr(bb,1,length(bb)-1) * 1024 *1024 * 1024 * 1024;
        break;
   }
   return bb;
}

BEGIN {
  #com
  gc_file=outfile "-gc.csv";   #DONE
  commitlog_unused_file =outfile "-comlog.csv"; #DONE
  delsst_file = outfile "-delsst.csv";
  asyncr_file = outfile "-asyncr.csv";
  
  #flushing operations
  fl_largest_file = outfile "-fl_largest.csv";
  fl_enqueue_file = outfile "-fl_enqueue.csv";
  fl_written_file = outfile "-fl_written.csv";
  fl_forcing_file = outfile "-fl_forcing.csv";
  slowq_file = outfile "-slowq.csv";  
  commitlog_time_secs="";  
  commitlog_unused=0;
  #internals
  were_slow=0;
  nslow=0;
  slow_found=0;
  OFS=",";
  OFMT="%.2f";
}

# single line events 

# gc_duration
$5 == "GCInspector.java:312" { gsub(/,/,".",$4);  print $3 " " $4,ip,substr($12,1,index($12,"ms.") - 1) >> gc_file ; next; } 

#for this too raw, I may do some post proc (maybe via SQL) to show the #deleted each second (no matter what table) or do it in awk as loosely-multiline
# keyspace,table
$5 == "SSTable.java:104" { gsub(/,/,".",$4); split($9,a,"/"); split(a[7],b,"-");  print $3 " " $4,ip,a[6],b[1] >> delsst_file; next}

#Flushing operations 

#DEBUG [NativePoolCleaner] 2022-09-12 17:33:14,268  ColumnFamilyStore.java:1435 - Flushing largest CFS(Keyspace='watched_content_excluder', ColumnFamily='bloom_filter_v1') 
#11 
#to free up room. Used total: 0.05/0.33, live: 0.05/0.33, flushing: 0.00/0.00, this: 0.01/0.16
#ks,tab
/Flushing largest CFS/ {gsub(/,/,".",$4); ks=substr($9,15,length($9)-1-15); tab=substr($10,15,length($10)-1-15); utotal=substr($17,1,length($17)-1); uthis=$NF; print  $3 " " $4,ip,ks,tab,utotal,uthis >> fl_largest_file; next }

#                                                                                                          10  
#DEBUG [COMMIT-LOG-ALLOCATOR] 2022-09-12 19:03:05,835  ColumnFamilyStore.java:997 - Enqueuing flush of watched_events_gb: 120.743MiB (2%) on-heap, 51.572MiB (1%) off-heap
/Enqueuing flush of/ { 
       gsub(/,/,".",$4); 
       tab=substr($10,1,length($10)-1); 
       on_heap=tobytes($11); 
       off_heap =tobytes($14);   
       print  $3 " " $4,ip, tab,on_heap,off_heap >>fl_enqueue_file; 
       next;
}

#DEBUG [MemtableFlushWriter:17139] 2022-09-12 19:02:57,081  ColumnFamilyStore.java:1332 - 
#       Flushed to [TrieIndexSSTableReader(path='/some_path/a_keyspace/a_table-618f817b005f3678b8a453f3930b8e86/ac-30831-bti-Data.db')] 
#10 
#(1 sstables, 9.794KiB), biggest 9.794KiB, smallest 9.794KiB (88ms)
# as here there is one data path it should always be 1 sstable. Only picking disk size.
$5 == "ColumnFamilyStore.java:1332" {
        gsub(/,/,".",$4);  
	split($9,a,"/"); 
	ks=a[6]; 
	tab=substr(a[7],1,index(a[7],"-")-1); 
	size_sst=tobytes($(NF-1)); 
	time_taken_ms=substr($NF,2,length($NF)-4); 
        print  $3 " " $4,ip,ks,tab,size_sst,time_taken_ms >>fl_written_file;next 

	next; 

}

#DEBUG [ValidationExecutor:1815] 2022-09-12 15:11:37,433  StorageService.java:3861 - Forcing flush on keyspace system_distributed, CF parent_repair_history
/Forcing flush on/ { gsub(/,/,".",$4);   print  $3 " " $4,ip, substr($11,1,length($11)-1), $NF >> fl_forcing_file; next;}

#WARN  [CoreThread-2] 2022-09-12 18:26:05,845  NoSpamLogger.java:97 - Timed out async read from org.apache.cassandra.io.sstable.format.AsyncPartitionReader for file /some_path/a_keyspace/a_table-b814a9c19adb11ec988b119655a5123b/ac-199613-bti-Data.db, more information on epoll state with FileDescriptor{fd=638} in the logs.
/Timed out async read from/   {gsub(/,/,".",$4); split($15,a,"/");  print  $3 " " $4,ip,a[6],substr(a[7],1,index(a[7],"-")-1)  >>asyncr_file;next; }


#loosely-multiline events

# n_unused_sec
$5 == "CommitLog.java:353" { 
     split($4,a,","); 
     ft=$3 " " a[1];
     if ( ft == commitlog_time_secs) 
     { commitlog_unused++; } 
     else 
     { 
       if ( length(commitlog_time_secs) >0) 
       { print commitlog_time_secs,ip,commitlog_unused >> commitlog_unused_file ;
         commitlog_time_secs=ft;
         commitlog_unused=1;
       }
     }
     next;
}     

#were slow (this would be multiline if I had to gather the queries but for now let's get it as simple time point).
#$5 == "MonitoringTask.java:173" {were_slow=1; nslow=$7; period_slow=$(NF-1);slow_found=0; next}
$5 == "MonitoringTask.java:173" {gsub(/,/,".",$4);   print  $3 " " $4,ip,$7,$(NF-1) >> slowq_file; next}


#/ERROR/ {print ip,$0;next}
#/WARN/  {print ip,$0;next}


END {
  if (length(commitlog_time_secs) >0) { print commitlog_time_secs,ip,commitlog_unused >> commitlog_unused_file ; }


}

