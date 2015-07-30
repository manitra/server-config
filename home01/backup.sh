#! /bin/bash

RC=1 
while [[ RC -ne 0 ]]
do
	rsync -avx ~/backup/photos manitra@web01.manitra.net:backup
	RC=$?
	sleep 5
done
