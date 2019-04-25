# Use the Natural CE image as a parent image
FROM store/softwareag/natural-ce:9.1.1

# Change user to root
USER root

# Add Tini
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

# Copy ./service to /service
COPY ./service /service

# Copy the customised docker-entrypoint.sh
COPY ./docker-entrypoint.sh /bin/docker-entrypoint.sh
RUN chmod +x /bin/docker-entrypoint.sh

# Copy NATCONF.CFG into the container with custom fuser definition
COPY ./NATCONF.CFG /opt/softwareag/Natural/etc/NATCONF.CFG

# Update and install pip and Flask
RUN yum -q -y update \
    && yum -q -y install epel-release \
    && yum -q -y install python-pip \
    && pip install --quiet --trusted-host pypi.python.org Flask

# Make port 80 available
EXPOSE 80

# Run the customised entrypoint.sh that also starts the python service
ENTRYPOINT [ "/tini", "-v", "--", "/bin/docker-entrypoint.sh" ]
