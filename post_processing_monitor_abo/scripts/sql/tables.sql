-- Csse <CASE_NUMBER> - <CUSTOMER_NAME> <SAMPLE_SET>
-- currently one set of tables on a mysql instance for a customer, case and set of runs (e.g. a name to identify a bunch of run IDs in different condition on a certain day)
-- TODO: this needs to be parametrized properly. 
--       If customer, case, and sample_set make it into table columns then there is no need to have a separate set for each case/sample set, but it can make the table
---      potentially very large if several runs are held in it.

DROP TABLE IF EXISTS <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_dse_netstats_messages;
CREATE TABLE <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_dse_netstats_messages
(
   ts                   datetime,
   hostname             varchar(64),
   ip                   varchar(18),
   runid                varchar(32),
   msgtype              varchar(32),
   pending              decimal(18,0),
   completed            decimal(18,0),
   dropped              decimal(18,0),
  PRIMARY KEY (runid,ip,msgtype,ts)
);
CREATE INDEX <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_dse_netstats_messages_i1 ON <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_dse_netstats_messages (ts,msgtype,ip,runid);

DROP TABLE IF EXISTS  <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_dse_netstats_rr;
CREATE TABLE <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_dse_netstats_rr
(
   ts                   datetime,
   hostname             varchar(64),
   ip                   varchar(18),
   runid                varchar(32),
   attempted            decimal(18,0),
   blocking             decimal(18,0),
   background           decimal(18,0),
  PRIMARY KEY (runid,ip,ts)
);
CREATE INDEX <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_dse_netstats_rr_i1 ON <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_dse_netstats_rr (ts,ip,runid);

DROP TABLE IF EXISTS <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_iostat_cpu;
CREATE TABLE <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_iostat_cpu
(
   ts                   datetime,
   hostname             varchar(64),
   ip                   varchar(18),
   runid                varchar(32),
   usr                  decimal(8,2),
   nice                 decimal(8,2),
   system               decimal(8,2),
   iowait               decimal(8,2),
   steal                decimal(8,2),
   idle                 decimal(8,2),
  PRIMARY KEY (runid,ip,ts)
);
CREATE INDEX <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_iostat_cpu_i1 ON <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_iostat_cpu (ts,ip,runid);

DROP TABLE IF EXISTS <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_iostat_disk;
CREATE TABLE <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_iostat_disk
(
   ts          datetime,
   hostname    varchar(64),
   ip          varchar(18),
   runid       varchar(32),
   disk_name   varchar(24),
   rrqm_s      decimal(12,2),
   wrqm_s      decimal(12,2),
   r_s         decimal(12,2),
   w_s         decimal(12,2),
   rkB_s       decimal(12,2),
   wkB_s       decimal(12,2),
   avgrq_sz    decimal(12,2),
   avgqu_sz    decimal(12,2),
   await       decimal(12,2),
   r_await     decimal(12,2),
   w_await     decimal(12,2),
   svctm       decimal(12,2),
   util        decimal(12,2),
  PRIMARY KEY (runid,ip,disk_name,ts)
);
CREATE INDEX <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_iostat_disk_i1 ON <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_iostat_disk (ts,disk_name,ip,runid);


--mpstat
DROP TABLE IF EXISTS <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_mpstat_cpu;
CREATE TABLE <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_mpstat_cpu (
  ts datetime NOT NULL,
  hostname    varchar(64),
  ip          varchar(18),
  runid       varchar(32),
  cpu_id varchar(5) NOT NULL,
  usr decimal(6,2) DEFAULT NULL,
  nice decimal(6,2) DEFAULT NULL,
  sys decimal(6,2) DEFAULT NULL,
  iowait decimal(6,2) DEFAULT NULL,
  irq decimal(6,2) DEFAULT NULL,
  soft decimal(6,2) DEFAULT NULL,
  steal decimal(6,2) DEFAULT NULL,
  guest decimal(6,2) DEFAULT NULL,
  gnice decimal(6,2) DEFAULT NULL,
  idle decimal(6,2) DEFAULT NULL,
  PRIMARY KEY (runid,ip,cpu_id,ts),
  KEY <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_mpstat_cpu_i1 (ts,cpu_id,ip,runid)
);

DROP TABLE IF EXISTS <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_mpstat_interrupt;
CREATE TABLE <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_mpstat_interrupt (
  ts datetime NOT NULL,
  hostname    varchar(64),
  ip          varchar(18),
  runid       varchar(32),
  cpu_id int(11) NOT NULL,
  hi decimal(10,2) DEFAULT NULL,
  timer decimal(10,2) DEFAULT NULL,
  net_tx decimal(10,2) DEFAULT NULL,
  net_rx decimal(10,2) DEFAULT NULL,
  block decimal(10,2) DEFAULT NULL,
  irq_poll decimal(10,2) DEFAULT NULL,
  tasklet decimal(10,2) DEFAULT NULL,
  sched decimal(10,2) DEFAULT NULL,
  hrtimer decimal(10,2) DEFAULT NULL,
  rcu decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (runid,ip,cpu_id,ts),
  KEY <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_mpstat_interrupt_i1 (ts,cpu_id,ip,runid)
)  ;

DROP TABLE IF EXISTS  <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_proxyhistograms;
CREATE TABLE <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_proxyhistograms
(
   ts                   datetime,
   hostname             varchar(64),
   ip                   varchar(18),
   runid                varchar(32),
   percentile           varchar(10),
   write_latency        decimal(12,2),
   read_latency         decimal(12,2),
   range_latency        decimal(12,2),
   cas_r_latency        decimal(12,2),
   cas_w_latency        decimal(12,2),
   view_write_latency   decimal(12,2),
  PRIMARY KEY (runid,ip,percentile,ts)
);
CREATE INDEX <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_proxyhistograms_i1 ON <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_proxyhistograms (ts,percentile,ip,runid);

DROP TABLE IF EXISTS <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_tablehistograms ;
CREATE TABLE <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_tablehistograms
(
   ts                   datetime,
   hostname             varchar(64),
   ip                   varchar(18),
   runid                varchar(32),
   keyspace             varchar(64),
   tabname              varchar(64),
   percentile           varchar(8),
   sstables             decimal(8,2),
   w_latency            decimal(12,2),
   r_latency            decimal(12,2),
   part_size            decimal(18,0),
   cell_count            decimal(18,0),
  PRIMARY KEY (runid,ip,keyspace,tabname,percentile,ts)
);
CREATE INDEX <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_tablehistograms_i1 ON <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_tablehistograms (ts,percentile,tabname,keyspace,ip,runid);

DROP TABLE IF EXISTS <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_tablestats;
CREATE TABLE <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_tablestats
(
   ts                   datetime,
   hostname             varchar(64),
   ip                   varchar(18),
   runid                varchar(32),
   keyspace             varchar(64),
   tabname              varchar(64),
   sst_num              int,
   spc_used_live        decimal(16,0),   
   spc_used_total       decimal(16,0),
   spc_used_snap        decimal(16,0),
   off_heap_memory      decimal(16,0),
   compression          decimal(16,6),
   npartitions_estimate    decimal(16,0),
   memtable_cell_num       decimal(16,0),
   memtable_data_size      decimal(16,0),
   memtable_offheap_used   decimal(16,0),
   memtable_switch_count   decimal(16,0),
   read_count           decimal(16,0),
   read_latency         decimal(16,4),
   write_count          decimal(16,0),
   write_latency        decimal(16,4),
   pending_flushes         int,
   percent_repaired     decimal(9,4), 
   kb_repaired          decimal(18,3),
   kb_unrepaired        decimal(18,3),
   kb_pending_repair    decimal(18,3),
   bloom_false_positive   decimal(16,0),
   bloom_false_ratio      decimal(16,4),
   bloom_space_used       decimal(16,0),
   bloom_offheap_used     decimal(16,0),   
   idx_offheap_used       decimal(16,0),
   compression_metadata_offheap_used  decimal(16,0),
   partition_min_bytes          decimal(14,0),
   partition_max_bytes          decimal(14,0),
   partition_mean_bytes         decimal(14,0),
   avg_live_cells_slice         decimal(16,6),
   max_live_cells_slice         decimal(12,0),
   avg_tombstones_slice         decimal(16,6),
   max_tombstones_slice         decimal(12,0),
   dropped_mutations            decimal(12,0),
   failed_repl_count                 int  ,
   PRIMARY KEY (runid,ip,keyspace,tabname,ts)   
);  

CREATE INDEX <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_tablestats_i1 ON <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_tablestats (ts,tabname,keyspace,ip,runid);

DROP TABLE IF EXISTS <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_tpstats_messages;
CREATE TABLE <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_tpstats_messages
(
   ts                   datetime,
   hostname             varchar(64),
   ip                   varchar(18),
   runid                varchar(32),
   messages             varchar(64),
   dropped              DECIMAL(16,0),
   p50                  decimal(10,2),
   p95                  decimal(10,2),
   p99                  decimal(10,2),
   pmax                 decimal(10,2),
   -- delta
   d_dropped            DECIMAL(16,0),
   PRIMARY KEY (runid,ip,messages,ts)
);
CREATE INDEX <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_tpstats_messages_i1 ON <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_tpstats_messages (ts,messages,ip,runid);

DROP TABLE IF EXISTS <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_tpstats_pools;
CREATE TABLE <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_tpstats_pools
(
   ts                   datetime,
   hostname             varchar(64),
   ip                   varchar(18),
   runid                varchar(32),
   pool                 varchar(64),
   active               int,
   pending              int,
   completed            DECIMAL(16,0),
   blocked              DECIMAL(16,0),
   all_blocked          DECIMAL(16,0),
   -- delta
   d_completed          DECIMAL(16,0) DEFAULT 0,
   PRIMARY KEY (runid,ip,pool,ts)
);
CREATE INDEX <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_tpstats_pools_i1 ON <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_tpstats_pools (ts,pool,ip,runid);

DROP TABLE  IF EXISTS  <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_tpstats_tpcpools;
CREATE TABLE <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_tpstats_tpcpools
(
   ts                   datetime,
   hostname             varchar(64),
   ip                   varchar(18),
   runid                varchar(32),
   group_name           varchar(10),
   pool                 varchar(64),
   active               int,
   pending              int,
--   backpressure         DECIMAL(16,0),
--   delayed_n            DECIMAL(16,0),  
--   shared               DECIMAL(16,0),
--   stolen               DECIMAL(16,0),
   completed            DECIMAL(16,0),
   blocked              DECIMAL(16,0),
   all_blocked          DECIMAL(16,0), 
-- ADDED delta cols ( I need to normalize with the #seconds so that I get the per second value.
--   d_backpressure         DECIMAL(16,0),
--   d_shared               DECIMAL(16,0),
--   d_stolen               DECIMAL(16,0),
   d_completed            DECIMAL(16,0),

   PRIMARY KEY (runid,ip,group_name,pool,ts)
);
CREATE INDEX <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_tpstats_tpcpools_i1 ON <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_tpstats_tpcpools (ts,pool,group_name,ip,runid);

DROP TABLE  IF EXISTS  <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_ttop_onlycore;
CREATE TABLE <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_ttop_onlycore
(
   ts                   datetime(3),
   hostname             varchar(64),
   ip                   varchar(18),
   runid                varchar(32),
   core                 varchar(5),
   cpu_user             decimal(8,2),
   cpu_sys              decimal(8,2),
   heap_allocation_rate decimal(12,2),
   PRIMARY KEY (runid,ip,core,ts)
);
--CREATE INDEX <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_ttop_onlycore_i1 ON <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_ttop_onlycore (runid,ip,core,ts);

DROP TABLE  IF EXISTS <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_ttop_summary; 
CREATE TABLE <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_ttop_summary
(
   ts                   datetime(3),
   hostname             varchar(64),
   ip                   varchar(18),
   runid                varchar(32),
   proc_cpu             decimal(8,2),
   app_cpu              decimal(8,2),
   app_cpu_user         decimal(8,2),
   app_cpu_sys          decimal(8,2),
   other_cpu            decimal(8,2),
   thread_count         smallint,
   heap_allocation_rate decimal(12,2),
   PRIMARY KEY (runid,ip,ts)
) ;
--CREATE INDEX <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_ttop_summary_i1 ON <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_ttop_summary (runid,ip,ts);
DROP TABLE  IF EXISTS <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_ttop_detail;
CREATE TABLE <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_ttop_detail (
  ts datetime(3) NOT NULL,
  hostname varchar(64) DEFAULT NULL,
  ip varchar(18) NOT NULL,
  runid varchar(32) NOT NULL,
  tid varchar(15) NOT NULL,
  cpu_user decimal(8,2) DEFAULT NULL,
  cpu_sys decimal(8,2) DEFAULT NULL,
  heap_allocation_rate decimal(12,2) DEFAULT NULL,
  thread_name varchar(128) DEFAULT NULL,
  PRIMARY KEY (runid,ip,tid,ts)
);  
  
-- log events tables

-- this may need modification: second resolution and # events of same time for that second.
DROP TABLE  IF EXISTS  <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_async;
CREATE TABLE <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_async 
(  
   ts         datetime(3),
   ip         varchar(18),
   keyspace   varchar(64),
   tname      varchar(100),   
   PRIMARY KEY (ts,ip,keyspace,tname)
);

DROP TABLE  IF EXISTS  <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_slow;
CREATE TABLE <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_slow
(
   ts                   datetime(3),
   ip                   varchar(18),
   nslow                int,
   ptime_ms             int,
   PRIMARY KEY (ts,ip)
);


DROP TABLE  IF EXISTS  <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_gc;
CREATE TABLE <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_gc
(
   ts                   datetime(3), 
   ip                   varchar(18),
   duration             int,
   PRIMARY KEY (ts,ip)
);

DROP TABLE  IF EXISTS  <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_fl_largest;
CREATE TABLE <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_fl_largest
(
   ts                   datetime(3), 
   ip                   varchar(18),
   keyspace   varchar(64),
   tname      varchar(100),
   ptotal     varchar(20),
   ptable     varchar(20),
   PRIMARY KEY (ip,ts)
);

DROP TABLE  IF EXISTS  <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_fl_forcing;
CREATE TABLE <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_fl_forcing
(
   ts                   datetime(3), 
   ip                   varchar(18),
   keyspace   varchar(64),
   tname      varchar(100),
   PRIMARY KEY (ip,ts)
);

DROP TABLE  IF EXISTS  <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_delsst;
CREATE TABLE <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_delsst
(
   ts                   datetime(3), 
   ip                   varchar(18),
   keyspace   varchar(64),
   tname      varchar(100),
   PRIMARY KEY (ip,ts)
);

DROP TABLE  IF EXISTS  <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_fl_enqueue;
CREATE TABLE <CUSTOMER_NAME>_<CASE_NUMBER>_<SAMPLE_SET>_fl_enqueue
(
   ts                   datetime(3), 
   ip                   varchar(18),
   tname      varchar(100),
   sonheap     decimal(20,2),
   soffheap     decimal(20,2),
   PRIMARY KEY (ip,ts,tname)
);
