FROM akemery/baseimage-rdesktop-web

# set version label
ARG BUILD_DATE
ARG VERSION
ARG XFCE_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"


RUN \
  echo "**** install packages ****" && \
  apt-get update && apt-get upgrade -y &&\
  DEBIAN_FRONTEND=noninteractive \
  apt-get install -y  \
    faenza-icon-theme \
    xfce4-appfinder \
    xfce4-panel \
    firefox \
    mousepad \
    thunar \
    xfce4 \
    xfce4-terminal && \
  DEBIAN_FRONTEND=noninteractive \
  apt-get install -y  \
    xfce4-pulseaudio-plugin && \
  echo "**** cleanup ****" && \
  rm -f /usr/share/xfce4/panel/plugins/power-manager-plugin.desktop && \
  rm -rf \
    /tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3000

VOLUME /config

## Build INGInious base

# DOCKER-VERSION 1.1.0
#FROM    rockylinux:8

ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

LABEL org.inginious.grading.agent_version=3

# Install python, needed for scripts used in INGInious + locale support
RUN      \
        apt-get  update  && \
        apt  upgrade -y && \
        apt-get install -y  language-pack-en language-pack-gnome-en language-pack-en-base language-pack-gnome-en-base && \
       # dnf -y install epel-release && \
        apt-get  install -y python38 python38-pip python38-devel zip unzip tar sed openssh-server openssl bind-utils iproute file jq procps-ng man curl net-tools screen nano bc  && \
        pip3.8 install msgpack pyzmq jinja2 PyYAML timeout-decorator ipython mypy
        # dnf clean all

# Allow to run commands
ADD     . /INGInious
RUN     chmod -R 755 /INGInious/bin && \
        chmod 700 /INGInious/bin/INGInious && \
        mv /INGInious/bin/* /bin

# Install everything needed to allow INGInious' python libs to be loaded
RUN     chmod -R 644 /INGInious/inginious_container_api && \
        mkdir -p /usr/lib/python3.8/site-packages/inginious_container_api && \
        cp -R /INGInious/inginious_container_api/*.py  /usr/lib/python3.8/site-packages/inginious_container_api && \
        echo "inginious_container_api" > /usr/lib/python3.8/site-packages/inginious_container_api.pth

# This maintains backward compatibility
RUN     mkdir -p /usr/lib/python3.8/site-packages/inginious && \
        cp -R /INGInious/inginious_container_api/*.py  /usr/lib/python3.8/site-packages/inginious && \
        echo "inginious" > /usr/lib/python3.8/site-packages/inginious.pth

# Delete unneeded folders
RUN     rm -R /INGInious

# Create worker user
RUN     groupadd --gid 4242 worker && \
        useradd --uid 4242 --gid 4242 worker --home-dir /task

# Set locale params for SSH debug
RUN     echo -e "LANG=en_US.UTF-8\nLANGUAGE=en_US:en\nLC_ALL=en_US.UTF-8" >> /etc/environment
RUN     sed -i.bak '/^AcceptEnv/ d' /etc/ssh/sshd_config

CMD ["INGInious"]
