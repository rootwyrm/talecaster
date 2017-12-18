#!/bin/sh
/usr/local/bin/transmission-remote -l | egrep '[0-9][*] ' | grep Stopped | awk '{print $1}' | sed -e 's/\*//g' | xargs -n 1 -I \% /usr/local/bin/transmission-remote -t \% -r
