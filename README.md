# datastax_scripts

## monitor_abo.sh
Before copying the script edit it and revise the value of the variables at the top `NODETOOL_AUTH`, `JSTACK_CMD` and `USE_JSTACK`

- adapt the variable `NODETOOL_AUTH` by adding the authentication options for `nodetool` in your environment
  and other options that may be needed.  Empty var -> no authentication parameters

- have `jstack` installed (i.e a full JDK installed) and in the `$PATH` on each node.
  if it's installed but you cannot add the corresponding dir in `$PATH` then set the absolute path for the command in `JSTACK_CMD`
  
- If the user that will run the script is not the same that runs the DSE process, `jstack` will need to be run with `sudo`.
  in this case make sure the user running the script can `sudo` without password (as it's a script)

- If there is no way to have `jstack` installed set  `USE_JSTACK=0`

- The script runs up to `MAX_SECONDS` seconds (normally set ot 900 == 15mins). If your test runs for longer (or much less time) adapt the value accordingly
  make sure it cover enough time for running it before the test starts, and the test completes (or errors) before the script ends
  

On each node 
- create a directory and place the script inside. Set the script as executable
- when ready to run your test program, start the script on all nodes of the DSE cluster
- wait for the scripts to start counting down, then start your test program and note down the time it started (including timezone)
- once the program reproduces the issue 
   - if you use jstack , wait 10s then hit Ctrl-C on the terminals
   - if you don't use jstack, wait 1 minute and then hit Ctrl-C on the terminals
   
After the test, on each node
- create a compressed tarball with  
   - the content of the script dir
   - the complete DSE logs 
 
   for example if your script directory is `/tmp/datastax_script` and your DSE logs are under `/var/log/cassandra`

       tar zcvf out-`hostname -i`-`date +%s`.tar.gz   /tmp/datastax_script  /var/log/cassandra
