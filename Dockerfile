FROM ubuntu:20.04

LABEL maintainer="James Cai"

# update the index of available packages
RUN apt-get -y update

# install the requires packages
RUN apt-get install -y openssh-server python3 sudo curl wget bash-completion openssl \
    && apt-get clean

# setting the sshd
RUN mkdir /var/run/sshd
RUN echo "root:root" | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# Create a new user.
# - username: docker
# - password: docker
RUN useradd --create-home --shell /bin/bash \
      --password $(openssl passwd -1 docker) docker

# Add sudo permission.
RUN echo 'docker ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Expose ssh port.
EXPOSE 22

# Run ssh server daemon.
CMD ["/usr/sbin/sshd", "-D"]