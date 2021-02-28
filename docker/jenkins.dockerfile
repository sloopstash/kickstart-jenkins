# Docker image to use.
FROM sloopstash/amazonlinux:v1

# Install OpenSSH server and Git.
RUN yum install -y openssh-server passwd git

# Configure OpenSSH server.
RUN set -x \
  && mkdir /var/run/sshd \
  && ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' \
  && sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Configure OpenSSH user.
RUN set -x \
  && mkdir /root/.ssh \
  && touch /root/.ssh/authorized_keys \
  && touch /root/.ssh/config \
  && echo -e "Host *\n\tStrictHostKeyChecking no\n\tUserKnownHostsFile=/dev/null" >> /root/.ssh/config \
  && chmod 400 /root/.ssh/config
ADD secret/node.pub /root/.ssh/authorized_keys

# Switch work directory.
WORKDIR /tmp

# Install Oracle JDK.
COPY jdk-8u131-linux-x64.rpm ./
RUN set -x \
  && rpm -Uvh jdk-8u131-linux-x64.rpm \
  && rm -rf jdk-8u131-linux-x64.rpm

# Create system user for Jenkins.
RUN set -x \
  && useradd -m -s /bin/bash -d /usr/local/lib/jenkins jenkins

# Install Jenkins.
COPY jenkins.war ./
RUN set -x \
  && cp jenkins.war /usr/local/lib/jenkins/ \
  && chown -R jenkins:jenkins /usr/local/lib/jenkins \
  && rm jenkins.war
RUN set -x \
  && mkdir /opt/jenkins \
  && mkdir /opt/jenkins/data \
  && mkdir /opt/jenkins/log \
  && mkdir /opt/jenkins/system \
  && touch /opt/jenkins/system/process.pid \
  && chown -R jenkins:jenkins /opt/jenkins

# Switch work directory.
WORKDIR /

# Cleanup history.
RUN history -c
