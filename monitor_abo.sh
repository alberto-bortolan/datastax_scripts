#!/bin/bash
#
# IMPORTANT: adapt the variable NODETOOL_AUTH by adding the authentication options for nodetool in your environment
# and other options that may be needed ! Empty var -> no authentication parameters
NODETOOL_AUTH=""

#set USE_JSTACK to 1 if using jstack. Otherwise set to 0
#Also put the absolute path for jstack in  JSTACK_CMD *if* not already in $PATH (e.g. /tmp/jvm/java-11-openjdk-amd64/bin/jstack )
USE_JSTACK=1
JSTACK_CMD=jstack

#the script will end itself after this amount of seconds if no Ctrl-C received
MAX_SECONDS=900

#---- End of normal user customization ----
RUN_ID=`date +%s`

#presumes only ONE DSE process is running,
PS_LINE=$(ps -e -o pid,user:20,cmd| grep com.datastax.bdp.DseModule| grep -v grep)
DSE_OWNER=$(echo $PS_LINE| awk '{print $2}' -)
DSE_PID=$(echo $PS_LINE| awk '{print $1}' -)
WHOAMI=`whoami`
JSTACK_USES_SUDO=0

trap ctrl_c INT
function ctrl_c() {
   echo "CTRL-C pressed. Terminating background activity"
   #kill $(jobs -p)
    kill -TERM -- -$$
   do_end
}

do_tpstats() {
   while [ 1 ];do echo; date; echo '=========='; nodetool $NODETOOL_AUTH tpstats ; sleep 5; done >> tpstats-`hostname`-$RUN_ID.out
}

do_proxyhistograms() {
   sleep 2;while [ 1 ];do echo; date; echo '=========='; nodetool $NODETOOL_AUTH proxyhistograms; sleep 30; done >> proxyhistograms-`hostname`-$RUN_ID.out
}

do_tablehistograms() {
   sleep 1;while [ 1 ];do echo; date; echo '=========='; nodetool $NODETOOL_AUTH tablehistograms; sleep 30; done >> tablehistograms-`hostname`-$RUN_ID.out  2> /dev/null
}

do_tablestats() {
   sleep 5;while [ 1 ];do  echo; date; echo '=========='; nodetool $NODETOOL_AUTH tablestats; sleep 30; done >> tablestats-`hostname`-$RUN_ID.out
}

do_dse_netstats() {
   sleep 3;while [ 1 ];do echo; date; echo '=========='; nodetool $NODETOOL_AUTH netstats; sleep 10; done >> dse_netstats-`hostname`-$RUN_ID.out
}

do_top_cpu_procs () {
    while [ 1 ]; do  echo; date; echo '=========='; top -b | head -n 20 ; sleep 1;echo; echo '=========='; done >> os_top_cpu-`hostname`-$RUN_ID.out
}

#these are more frequent
do_ttop() {
   nodetool $NODETOOL_AUTH sjk ttop -o CPU -ri 1000ms >> ttop-`hostname`-$RUN_ID.out
}

do_stcap() {
   echo "INFO   - stcap used to gather stack. Give it an extra 40-50s after the end of the monitoring period before doing Ctrl-C"
   nodetool $NODETOOL_AUTH sjk stcap -o stcap-`hostname`-$RUN_ID.out -t 1800s -i 1000ms  > /dev/null
}

do_jstack() {
  JSTACK_OUTFILE=jstack-`hostname`-$RUN_ID.out
  MYSELF=`whoami`
  if [ $MYSELF != $DSE_OWNER ]; then
     echo "WARNING - Current user '$USER' is not the owner of the DSE process '$DSE_OWNER', jstack may not work properly"
  fi
  while [ 1 ]; do
     if [ $JSTACK_USES_SUDO -eq 1 ]; then
        sudo -u $DSE_OWNER $JSTACK_CMD -l $DSE_PID >> $JSTACK_OUTFILE
     else
        $JSTACK_CMD -l $DSE_PID >> $JSTACK_OUTFILE
     fi	
     sleep 1
  done
}

do_begin()
{
   echo "hostname ---"
   hostname
   echo "IP ---"
   hostname -i
   echo "CPUs ---"
   lscpu
   echo "Memory ----"
   free
   echo "processes"
   ps -efl
   echo "mountpoints ---"
   df -h
   echo "..."
   lsblk --output NAME,KNAME,TYPE,MAJ:MIN,FSTYPE,SIZE,RA,MOUNTPOINT,LABEL
   #these go in their own file
   nodetool $NODETOOL_AUTH status > nodetool-status-`hostname`-$RUN_ID.out
   nodetool $NODETOOL_AUTH describecluster  > nodetool-describecluster-`hostname`-$RUN_ID.out
   nodetool $NODETOOL_AUTH compactionstats  > nodetool-compactionstats-`hostname`-$RUN_ID.out
   nodetool $NODETOOL_AUTH compactionhistory > nodetool-compactionhistory-`hostname`-$RUN_ID.out
   nodetool $NODETOOL_AUTH gossipinfo  > nodetool-gossipinfo-`hostname`-$RUN_ID.out
   nodetool $NODETOOL_AUTH info  > nodetool-info-`hostname`-$RUN_ID.out
}

# the "main" code -----
#check if jstack exists
if [ $USE_JSTACK -eq 1 ]; then
   if [ $JSTACK_CMD == "jstack" ] ; then
      X=$(which $JSTACK_CMD)
      if [ $? -ne 0 ]; then
         echo "ERROR - the path for the command >" $AA "< is not in PATH"
	 echo "        either set JSTACK_CMD to the absolute path for jstack or set USE_JSTACK=0"
	 exit 1
      fi
   else  #if relative/absolute path
      if [ -x $JSTACK_CMD ]; then
         echo "INFO - file $JSTACK_CMD exist and executable"
      else
         echo "ERROR - file $JSTACK_CMD does not exist or is non executable"
	 echo "        either set JSTACK_CMD to the absolute path for jstack or set USE_JSTACK=0"
	 exit 1	 
      fi
   fi
   #check if sudo is needed and if it works
   if [ $WHOAMI != $DSE_OWNER ] ; then
      echo "jstack will need sudo as current user $WHOAMI is not the same as the DSE process owner $DSE_OWNER"
      JSTACK_USES_SUDO=1
   fi     
fi 


echo "gather-begin"
do_begin >> common-`hostname`-$RUN_ID.out
echo "gather loop actions"
do_tpstats &
do_proxyhistograms &
do_tablehistograms &
do_tablestats &
do_dse_netstats &
do_top_cpu_procs &
if [ $USE_JSTACK -eq 1 ] ; then
  do_jstack &
else
   do_stcap &
fi   
iostat -x -c -d -t 1 >> iostat-`hostname`.out &
do_ttop &


echo "launched commands, press Ctrl-C to exit, or wait " $MAX_SECONDS " seconds for the script to complete automatically"
echo "children list "
jobs
#wait 75s to have the lot
for ((n=$MAX_SECONDS;n>0;n--)); do
   echo -e -n $n \\r
   sleep 1
done
echo "end of script"
ctrl_c
