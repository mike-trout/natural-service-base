#!/bin/sh
# set -x
#########################################################################
#                                                                       #
# Copyright (C) 2018 Software AG, Darmstadt, Germany and/or             #
# Software AG USA Inc., Reston, VA, USA, and/or its subsidiaries        #
# and/or its affiliates and/or their licensors.                         #
#                                                                       #
# The name Software AG and all Software AG product names are either     #
# trademarks or registered trademarks of Software AG and/or             #
# Software AG USA Inc. and/or its subsidiaries and/or its affiliates    #
# and/or their licensors. Other company and product names mentioned     #
# herein may be trademarks of their respective owners.                  #
#                                                                       #
# Detailed information on trademarks and patents owned by Software AG   #
# and/or its subsidiaries is located at http://softwareag.com/licenses. #
#                                                                       #
#########################################################################



# Do a pre-check if a license file is at the right location 

function pre_check_license {

	echo ""
	echo "function pre_check_license ..."
	if [ -f ${SAG_HOME}/common/conf/nat91.xml ]; then
		echo "License file ${SAG_HOME}/common/conf/nat91.xml found"
	else
		echo "No license file ${SAG_HOME}/common/conf/nat91.xml found"
		echo "Exiting ..."
		exit 1
	fi
	
	if [ -f ${SAG_HOME}/common/conf/ndv91.xml ]; then
		echo "License file ${SAG_HOME}/common/conf/ndv91.xml found"
	else
		echo "No license file ${SAG_HOME}/common/conf/ndv91.xml found"
		echo "Exiting ..."
		exit 1
	fi
}


# Check if there are customer specific config files
# and copy them to the right locations
# The config files should be available
# in /configs that has been mounted into the container

function copy_config_file {
	if [ -f /configs/$1 ]; then
		echo "User specific $1 file found in /configs"
		echo "Copying /configs/$1 to $NAT_HOME/etc directory"
		cp /configs/$1 ${NAT_HOME}/etc
	else
		echo "No user specific "$1 " file found, using default"
	fi
}

function copy_profile {
	if [ -f /configs/$1 ]; then
		echo "User specific $1 file found in /configs"
		echo "Copying /configs/$1 to $NAT_HOME/prof directory"
		cp /configs/$1 ${NAT_HOME}/prof
	else
		echo "No user specific $1 file found, using default"
	fi
}

function copy_all_config_files {
	copy_config_file  NATURAL.INI
	copy_config_file  NATCONV.INI
	copy_config_file  NATCONF.CFG
	copy_config_file  SAGtermcap
	copy_profile      NATPARM.SAG
	copy_profile      NDVPARM.SAG
	copy_profile      NSCPARM.SAG
}
# Start Buffer Pool Server
function start_bp {
	echo " "
	echo "Starting up buffer pool at `date`"

	cd ${NAT_HOME}/bin/

options="BPID=natbp"
natbpsrv=${NAT_HOME}/bin/natbpsrv	
if [ -r ${natbpsrv} ]
then
  echo starting natural bufferpool server with the command
  echo ${natbpsrv} ${options}
       ${natbpsrv} ${options}
  if [ $? -ne 0 ]
  then
    echo "Error:NATURAL bufferpool server start failed"
  else
    echo NATURAL bufferpool server started
    exit_code=0
  fi
else
  echo "ERROR: ${natbpsrv}: not found or not executable"
  echo "ERROR: NATURAL bufferpool server not started"
fi

}

# Start NDV Server
function start_ndv {
	echo 
	echo "Starting up NaturalDevelopmentServer at internal port $NDVPORT"

	cd ${NAT_HOME}/bin/
	./natdvsrv -port=$NDVPORT parm=ndvparm | tee -a $NAT_HOME/tmp/ndv.out
	
	if [ $? = 0 ]
	then
		echo "NDV started correctly! "
	else
		echo "ERROR: Startup of NDV failed with " $? 
		exit $?
	fi
	
	return $?
}

# Clean up function shutdown of NaturalDevelopmentServer
function clean_up {
	echo
	echo "Shutting down NaturalDevelopmentServer"
	# Sending shutdown command
	${NAT_HOME}/bin/natdvsrv -terminate=
	exit 0
}

#
# Check if the EULA is accepted
#
function check_eula {
  if [ "$ACCEPT_EULA" == "Y" ]; then
    echo "You accepted the license agreement"
  else
    echo "You have not accepted the license agreement setting the environment variable ACCEPT_EULA=Y. Exiting..."
    exit 10
  fi
}


#
# Entrypoint
#

# Check EULA
check_eula

pre_check_license

copy_all_config_files

# source ACL environment
. /opt/softwareag/AdabasClient/INSTALL/aclenv

# Setting necessary environment variables
export PATH="${NAT_HOME}/bin:${ACLDIR}/bin:${PATH}"

# Starting buffer pool server
start_bp

# Start NDV server
start_ndv

# Start service
python service.py

# clean_up
