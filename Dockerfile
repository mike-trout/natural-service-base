# Use the Natural CE image as a parent image
FROM store/softwareag/natural-ce:9.1.1

# Change user to root
USER root

# Copy the Natural source code into the custom fuser
COPY --chown=sagadmin ./Natural-Libraries/MAIN /fuser/MAIN

# Copy ./service to /service
COPY --chown=sagadmin ./service /service

# Copy the customised entrypoint.sh
COPY --chown=sagadmin ./entrypoint.sh /opt/softwareag/Natural/bin/entrypoint.sh

# Copy NATCONF.CFG into the container with custom fuser definition
COPY --chown=sagadmin ./NATCONF.CFG /opt/softwareag/Natural/etc/NATCONF.CFG

# Update yum and install python
# RUN yum -y update && yum -y install python

# Install pip and Flask
RUN yum -y install epel-release \
    && yum -y install python-pip \
    && pip install --trusted-host pypi.python.org Flask

# Set the user to sagadmin
USER sagadmin

# Start the buffer pool
# and then run the ftouch utility to build a new FILEDIR.SAG
# and then set up a command file to CATALL library MAIN
# and then start Natural in batch mode and run the command file
# and then remove the command file
# and the check the output of catall and remove the temporary file
RUN natbpsrv bpid=natbp \
    && ftouch lib=main sm -s -d \
    && printf "LOGON MAIN\nCATALL ** ALL CATALOG\nFIN\n" > /tmp/cmd \
    && natural batchmode cmsynin=/tmp/cmd cmobjin=/tmp/cmd cmprint=/tmp/out natlog=err \
    && rm /tmp/cmd \
    && cat /tmp/out && rm /tmp/out

# Accept the licence agreement
ENV ACCEPT_EULA Y

# Make port 80 available
EXPOSE 80

# Change user to root
USER root

# Run the customised entrypoint.sh that also starts the python service
ENTRYPOINT [ "entrypoint.sh" ]
