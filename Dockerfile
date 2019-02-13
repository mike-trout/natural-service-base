# Use the Natural CE image as a parent image
FROM store/softwareag/natural-ce:9.1.1

# Install Python
# RUN yum update && yum install python

# Install Flask
RUN pip install --trusted-host pypi.python.org Flask

# Set the working directory
# WORKDIR .

# Copy NATCONF.CFG into the container with custom fuser definition
COPY --chown=sagadmin ./NATCONF.CFG /opt/softwareag/Natural/etc/NATCONF.CFG

# Copy the Natural source code into the custom fuser
COPY --chown=sagadmin ./Natural-Libraries/MAIN /fuser/MAIN

# Copy service.py to /service
COPY --chown=sagadmin ./service.py /service/service.py

# Set the user to sagadmin
USER sagadmin

# Start the buffer pool
# Run the ftouch utility to build a new FILEDIR.SAG
# Set up a command file to CATALL library MAIN
# Start Natural in batch mode and run the command file
# Remove the command file
RUN /opt/softwareag/Natural/bin/natbpsrv BPID=natbp \
    && ftouch parm=natparm lib=main sm -s -d \
    && printf "logon main\ncatall ** all catalog\nfin\n" > /tmp/cmd \
    && natural parm=natparm batchmode cmsynin=/tmp/cmd cmobjin=/tmp/cmd cmprint=/tmp/out natlog=err \
    && rm /tmp/cmd

# Check output of catall
RUN cat /tmp/out

# Make port 80 available
EXPOSE 80

# Accept the licence agreement
ENV ACCEPT_EULA Y

# Run service.py when the container starts
ENTRYPOINT [ "python", "/service/service.py" ]
