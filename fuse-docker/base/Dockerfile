#################################################################
# Creates a base CentOS 6 image with Fuse
#
#                    ##        .
#              ## ## ##       ==
#           ## ## ## ##      ===
#       /""""""""""""""""\___/ ===
#  ~~~ {~~ ~~~~ ~~~ ~~~~ ~~ ~ /  ===- ~~~
#       \______ o          __/
#         \    \        __/
#          \____\______/
#
# Author:    Paolo Antinori <paolo.antinori@gmail.com>
# License:   MIT
#################################################################


######
# HUGE NOTE: This is just for reference purposes...
# To see the real thing, go to: https://github.com/paoloantinori/dockerfiles/blob/master/centos/fuse/base/Dockerfile
#
######
FROM centos:centos6

MAINTAINER Paolo Antinori <paolo.antinori@gmail.com>

# telnet is required by some fabric command. without it you have silent failures
RUN yum install -y java-1.7.0-openjdk vi which telnet unzip openssh-server sudo openssh-clients wget
RUN yum clean all -y
# enable no pass and speed up authentication
RUN sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords yes/;s/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config

# enabling sudo group
RUN echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
# enabling sudo over ssh
RUN sed -i 's/.*requiretty$/Defaults !requiretty/' /etc/sudoers

ENV JAVA_HOME /usr/lib/jvm/jre

# add a user for the application, with sudo permissions
RUN useradd -m fuse ; echo fuse: | chpasswd ; usermod -a -G wheel fuse

# assigning higher default ulimits
# unluckily this is not very portable. these values work only if the user running docker daemon on the host has his own limits >= than values set here
# if they are not, the risk is that the "su fuse" operation will fail
RUN echo "fuse                -       nproc           4096" >> /etc/security/limits.conf
RUN echo "fuse                -       nofile           4096" >> /etc/security/limits.conf

# give total control to the main working folder
RUN mkdir -m 777 -p /opt/rh

# command line goodies
RUN echo "export JAVA_HOME=/usr/lib/jvm/jre" >> /etc/profile
RUN echo "export LANG=en_GB.utf8" >> /etc/profile
RUN echo "alias ll='ls -l --color=auto'" >> /etc/profile
RUN echo "alias grep='grep --color=auto'" >> /etc/profile

# onbuild instructions are invoked only while building another image that inherits from this one.
# jboss fuse specific interaction
ONBUILD ADD . /root/
ONBUILD RUN unzip -q -d /opt/rh /root/*.zip
ONBUILD RUN chown -R fuse:fuse /opt/rh
ONBUILD RUN rm /root/*
ONBUILD RUN sed -i "s/#admin/admin/" /opt/rh/*/etc/users.properties

WORKDIR /opt/rh

CMD echo "This is just an abstract image that provides java and ssh. You need to build your own JBoss Fuse image. See here: https://github.com/paoloantinori/dockerfiles/edit/master/centos/fuse/README.md"

# declaring exposed ports. helpful for non Linux hosts. add "-P" flag to your "docker run" command to automatically expose them and "docker ps" to discover them.
# SSH, Karaf-ssh, Web, rmiServerPort, rmiRegistry, ActiveMQ
EXPOSE 22 8101 8181 44444 1099 61616