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

#TODO: make it a parameter. COmmon part of the IPs for the nodes. Or remove it altogether and be cleverer in picking only the name of node directories, or impose there can be only node dirs.
IP_START=10.

#FSTATS should be a parameter. One name per capture. For now uncomment what is needed.
#FSTATS=dse_netstats          #  
#FSTATS=iostat                # TODO:For some reason bignum seems to mess with the ddisk array!! removed --bignum to run this (TODO: automate, and also find out why it happened. Is it a bug in awk?)
#FSTATS=tpstats               #
#FSTATS=ttop                  #
#FSTATS=tablehistograms       #
#FSTATS=proxyhistograms       #
#FSTATS=tablestats            #
#FSTATS=mpstat                # 

for runid in ${ABO_CAPTURE[@]}; do
   echo $runid
   cd $runid
   for node in $IP_START* ; do
      echo $node
      cd $node/diag
      fname=$FSTATS*.out
      if [ -f $fname ]; then
         echo "EXISTS: " $fname
      
         #extract chostname and capture timestamp 
         # TODO: use a better divider than - 
         file_hostname=$( echo $fname | awk '{ a=substr($1,1,index($1,".out")-1); n=split(a,b,"-"); if (n>3) {hname=b[2] "-"; for (i=3;i<n;i++) {hname=hname b[i]; if (i<n-1) hname=hname "-"; }} else hname=b[2]; print hname}' )
         file_runts=$( echo $fname | awk '{ a=substr($1,1,index($1,".out")-1); split(a,b,"-"); print b[3]}' )  #missing on some files. also how do you use it?
         #echo "HOST: " $file_hostname
         #echo "runID: " $file_runid
         echo
         awk --bignum -v hostname=$file_hostname \
    	     -v ip=$node \
	     -v runid=$runid \
             -v outfile=../../../$OUT_DIR/$FSTATS \
             -f ../../../$SCRIPTS_DIR/$FSTATS-to_unl_file.awk $fname 
      else
         echo "MISSING: "$i " " $FSTATS " file"
      fi 
      cd ../..
   done
   cd ..
done
