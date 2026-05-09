#!/bin/bash
#crontab example
#30 2 * * * ~/om-ct/bin/download-docs.sh
function updatedoc(){
cd ~/om-ct/conf/docs/$1
./gitlab-down.sh
}
while read line; do
  updatedoc $line
done < ~/om-ct/conf/docs/list.txt

