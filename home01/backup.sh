#! /bin/bash

RC=1 
while [[ RC -ne 0 ]]
do
	find /home/manitra/backup/photos -mindepth 2 -maxdepth 2 | parallel -v -j10 --line-buffer rsync -avx '{}' 'manitra@web01.manitra.net:{//}'
	RC=$?
	sleep 5
done
