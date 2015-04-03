#!/bin/bash
# The cassandra service immediately starts, but does not immediately
# accept connections. Try one time a second for 30 seconds.
for second in {1..30}
do
    echo "Try $second"
    sleep 1
    cqlsh 192.168.50.11 -u cassandra -p cassandra -f /tmp/salt-ddl.cql
    RC=$?
    echo "RC=$RC"
    if test $RC -eq 0
    then
	exit $RC
    fi
done
echo "Failed to get a connection to Cassandra after approximately 15 seconds."
exit 1
