#!/bin/sh
set -e

# Source ACL environment
. /opt/softwareag/AdabasClient/INSTALL/aclenv

# Setting necessary environment variables
export PATH="${NAT_HOME}/bin:${ACLDIR}/bin:${PATH}"

# Starting buffer pool server
echo "Starting up buffer pool at `date`"
cd ${NAT_HOME}/bin/
options="BPID=natbp"
natbpsrv=${NAT_HOME}/bin/natbpsrv	
if [ -r ${natbpsrv} ] then
	echo starting natural bufferpool server with the command
	echo ${natbpsrv} ${options}
	${natbpsrv} ${options}
	if [ $? -ne 0 ] then
   		echo "Error:NATURAL bufferpool server start failed"
	else
   		echo NATURAL bufferpool server started
	fi
else
	echo "ERROR: ${natbpsrv}: not found or not executable"
	echo "ERROR: NATURAL bufferpool server not started"
fi

# Start service
echo "Starting service"
nohup python /service/service.py &
echo "Command finished with " $?