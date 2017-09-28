FROM mintlab/ossec-base:latest
MAINTAINER Mintlab BV <ops@mintlab.nl>

# Add a default agent due to this bug
# https://groups.google.com/forum/#!topic/ossec-list/qeC_h3EZCxQ
ADD default_agent /var/ossec/default_agent

RUN service ossec restart &&\
  /var/ossec/bin/manage_agents -f /default_agent &&\
  rm /var/ossec/default_agent &&\
  service ossec stop &&\
  echo -n "" /var/ossec/logs/ossec.log

# Initialize the data volume configuration
ADD data_dirs.env /data_dirs.env
ADD init.bash /init.bash
# Sync calls are due to https://github.com/docker/docker/issues/9547
RUN chmod 755 /init.bash &&\
  sync && /init.bash &&\
  sync && rm /init.bash

# Add the bootstrap script
ADD run.bash /run.bash
RUN chmod 755 /run.bash

# Specify the data volume
VOLUME ["/var/ossec/data"]

# Expose ports for sharing
EXPOSE 1514/udp 1515/tcp

# Define default command.
ENTRYPOINT ["/run.bash"]
