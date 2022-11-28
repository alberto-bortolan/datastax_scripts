#TODO: detection of the timestamp must be done properly! Perhaps I can impose an ISO date and put a special character sequence at the beginning like ~^
#this is a way to avoid changing all nodetool awk scripts to interpret the timestamp as printed out by "date" on the customer's box
$5=="UTC" {ts=sprintf("%s-%s-%s %s",$6,month[$3],$2,$4);next}
