#!/bin/bash
#
# TODO;
#  - empty files before execute (may be passing an extra flag on 1st loop, to awk

. ./script_include

#scripts place: scripts is related to the dir where this script is, outdir is relative to  $ABO_BASE_DIR
SCRIPTS_DIR=scripts
OUT_DIR=unload
export AWKPATH=.:$(pwd)/$SCRIPTS_DIR
echo $AWKPATH
#see if it needs to be made more generic
IP_START=10.

# in this case there is a single file so there should be a single awk file
#but I could put a list of thigns to extract. Also some are single line and others are multiline.
#

FSTATS=log

runid=evening 
   echo $runid
   cd $runid
   for node in $IP_START* ; do
      echo $node
      cd $node/logs
      fname=system-selected.log
      if [ -f $fname ]; then
         echo "EXISTS: " $fname
      
         #extract chostname and capture timestamp 
         #replace with table   
         file_hostname=$( echo $fname | awk '{ a=substr($1,1,index($1,".out")-1); n=split(a,b,"-"); if (n>3) {hname=b[2] "-"; for (i=3;i<n;i++) {hname=hname b[i]; if (i<n-1) hname=hname "-"; }} else hname=b[2]; print hname}' )
         echo
         awk --bignum -v hostname=$file_hostname \
    	     -v ip=$node \
             -v outfile=../../../$OUT_DIR/$FSTATS \
             -f ../../../$SCRIPTS_DIR/$FSTATS-to_unl_file.awk $fname 
      else
         echo "MISSING: "$i " " $FSTATS " file"
      fi 
      cd ../..
   done
   cd ..
