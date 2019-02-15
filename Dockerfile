# Use the Natural CE image as a parent image
FROM store/softwareag/natural-ce:9.1.1

# Change user to root
USER root

# Install Python
# RUN yum -y update && yum -y install python

# Update yum and install pip and Flask
RUN yum -y update \
    && yum -y install epel-release \
    && yum -y install python-pip \
    && pip install --trusted-host pypi.python.org Flask

# Copy NATCONF.CFG into the container with custom fuser definition
COPY --chown=sagadmin ./NATCONF.CFG /opt/softwareag/Natural/etc/NATCONF.CFG

# Copy the Natural source code into the custom fuser
COPY --chown=sagadmin ./Natural-Libraries/MAIN /fuser/MAIN

# Copy service.py and service.cmd to /service
COPY --chown=sagadmin ./service.py /service/service.py
COPY --chown=sagadmin ./service.cmd /service/service.cmd

# Copy the customised entrypoint.sh
COPY --chown=sagadmin ./entrypoint.sh /opt/softwareag/Natural/bin/entrypoint.sh

# Set the user to sagadmin
USER sagadmin

# Start the buffer pool
# and then run the ftouch utility to build a new FILEDIR.SAG
# and then set up a command file to CATALL library MAIN
# and then start Natural in batch mode and run the command file
# and then remove the command file
# and the check the output of catall and remove the temporary file
RUN natbpsrv bpid=natbp \
    && ftouch parm=natparm lib=main sm -s -d \
    && printf "logon main\ncatall ** all catalog\nfin\n" > /tmp/cmd \
    && natural parm=natparm batchmode cmsynin=/tmp/cmd cmobjin=/tmp/cmd cmprint=/tmp/out natlog=err \
    && rm /tmp/cmd \
    && cat /tmp/out && rm /tmp/out

# Make port 80 available
EXPOSE 80

# Accept the licence agreement
ENV ACCEPT_EULA Y

# Change user to root
USER root

# Start the buffer pool service
# and run service.py when the container starts
# ENTRYPOINT entrypoint.sh && python /service/service.py
ENTRYPOINT [ "entrypoint.sh" ]
