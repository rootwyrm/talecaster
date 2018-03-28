#!/usr/local/bin/bash
#
# Copyright (c) 2017-* Phillip R. Jaenke <talecaster@rootwyrm.com>
# All rights reserved.
#
# LICENSE PLACEHOLDER - DO NOT COPY OR REDISTRIBUTE
#

## $1 = operation
## $2 = set
## $3 = options

export CONFDIR=/opt/talecaster/etc/poudriere

function log()
{
	case $2 in
		[Ee])
			echo "$(date) [ERROR] ${1}"
			exit ${3}
			;;
		[Ww])
			echo "$(date) [WARNING] ${1}"
			;;
		Nn)
			echo "$(date) [NOTICE] ${1}"
			;;
	esac
}

function lock_test()
{
	if [ -f /var/run/poudriere.lock ]; then
		## Is it really?
		ps -p `cat /var/run/poudriere.lock` > /dev/null
		if [ $? -eq 0 ]; then
			log "An existing process is holding the lock." e 1
		else
			log "Removing stale lock." n
			lock_clear
		fi
	fi
}
function lock_clear()
{
	if [ -f /var/run/poudriere.lock ]; then
		rm -f /var/run/poudriere.lock
	fi
}
function lock_place()
{
	echo $$ > /var/run/poudriere.lock
}

function pkg_list_build()
{
	if [ ! -d ${CONFDIR}/${1} ]; then
		log "${CONFDIR}/${1} does not exist!" e 10
	fi
	if [ -f /tmp/${1}.pkg ]; then
		rm /tmp/${1}.pkg
	fi
	
	for pl in `ls ${CONFDIR}/${1}/*.pkg`; do
		cat $pl | grep -v ^# | sort | uniq >> /tmp/${1}.pkg
	done
}

function check_set_jails()
{
	if [ ! -f ${CONFDIR}/${1}/jails ]; then
		log "${CONFDIR}/${1}/jails does not exist!" e 10
	fi
	## First make sure the jails actually exist.
	poudriere jail -q -l > /tmp/avail.jail
	for jl in `cat ${CONFDIR}/${1}/jails | grep -v ^#`; do
		grep ${jl} /tmp/avail.jail > /dev/null
		if [ $? -ne 0 ]; then
			log "${CONFDIR}/${1}/jails has invalid jail" e 20
		fi
	done
	## Tidy up
	rm -f /tmp/avail.jail
}

function test_set_jails()
{
	for js in `cat ${CONFDIR}/${1}/jails | grep -v ^#`; do
		if [ ! -z $(poudriere jail -i -j $js | grep Status | cut -d : -f 2) ]; then
			## Handle stopped jails correctly.
			if [ -z $(poudriere jail -i -j $js | grep Status | cut -d : -f 2 | grep stopped) ] ;then
				log "Jail $js is running or hung." e 2
			else
				## No real problem found.
				log "Jail $js was found in stopped state." n
			fi
		fi
	done
}

function set_build_pkgs()
{
	## Now do real work.
	case $1 in
		[Cc][Ll][Ee][Aa][Nn]*)
			export PKGCLEAN=1
			;;
		[Nn][Oo][Cc][Ll][Ee][Aa][Nn]*)
			export PKGCLEAN=0
			;;
		*)
			log "Entered set_build_pkgs() with invalid command $1" e 255
			;;
	esac

	export pdrbin=$(which poudriere)
	if [ ${PKGCLEAN} -eq 1 ]; then
		export pdrarg="bulk -ctr"
	elif [ ${PKGCLEAN} -eq 0 ]; then
		export pdrarg="bulk -tr"
	else
		log "Unknown setting $1 passed to PKGCLEAN var?" e 255
	fi

	## Handle different port sets
	if [ ! -z $3 ]; then
		export pdrarg="${pdrarg} -p $3"
	fi

	## Actually start our work.
	if [[ ${QUEUE} != "yes" ]]; then
		for jl in `cat ${CONFDIR}/${2}/jails | grep -v ^#`; do
			export logfile=/var/log/poudriere/$2.$(date +%m%d%Y.%H%M)
			${pdrbin} ${pdrarg} -j $jl -z $2 -f /tmp/$2.pkg | tee -a ${logfile} > /dev/null 2>&1
		done
	elif [[ ${QUEUE} == "yes" ]]; then
		for jl in `cat ${CONFDIR}/${2}/jails | grep -v ^#`; do
			export logfile=/var/log/poudriere/${2}.$(date +%m%d%Y.%H%M)
			$pdrbin queue $pdrarg -j $jl -z $2 -f /tmp/$2.pkg | tee -a ${logfile} > /dev/null 2>&1
		done
	fi
}

function ports_update()
{
	pdrbin=$(which poudriere)
	case $1 in
		[Uu][Pp][Dd][Aa][Tt][Ee]*)
			if [ -z $2 ]; then
				$pdrbin ports -u -p default
			else
				$pdrbin ports -u -p $2
			fi
			;;
		[Dd][Ee][Ll][Ee][Tt][Ee]*)
			if [ -z $2 ]; then
				$pdrbin ports -d -p $2
			else
				log "Will not delete default ports tree this way." e 50
			fi
			;;
		*)
			log "Invalid argument $1 passed to ports_update()" e 255
			;;
	esac
}

function print_help()
{
	echo "Not Yet Implemented."
}

## Main loop.
case $1 in
	[Cc][Ll][Ee][Aa][Nn]*)
		if [ -f ${CONFDIR}/${1}/poudriere.env ]; then
			. ${CONFDIR}/${1}/poudriere.env
		fi
		lock_test
		lock_place
		pkg_list_build $2
		check_set_jails $2
		test_set_jails $2
		set_build_pkgs $1 $2 $3
		lock_clear
		;;
	[Nn][Oo][Cc][Ll][Ee][Aa][Nn]*)
		if [ -f ${CONFDIR}/${1}/poudriere.env ]; then
			. ${CONFDIR}/${1}/poudriere.env
		fi
		lock_test
		lock_place
		pkg_list_build $2
		check_set_jails $2
		test_set_jails $2
		set_build_pkgs $1 $2 $3
		lock_clear
		;;
	[Uu][Pp][Dd][Aa][Tt][Ee]*)
		lock_test
		lock_place
		ports_update $1 $2 $3
		lock_clear
		;;
	*)
		echo "Command not understood: $1"
		print_help
		exit 1
		;;
esac
