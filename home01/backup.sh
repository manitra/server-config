#! /bin/bash

RC=1 
while [[ RC -ne 0 ]]
do
	ls ~/backup/photos | parallel -v -j10 -I '$' --line-buffer rsync -avx '/home/manitra/backup/photos/$' 'manitra@web01.manitra.net:backup/photos'
	RC=$?
	sleep 5
done
