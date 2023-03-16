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
#    faenza-icon-theme-xfce4-appfinder \
#    faenza-icon-theme-xfce4-panel \
    firefox \
    mousepad \
    thunar \
    xfce4 \
    xfce4-terminal && \
  apt-get install -y --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
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
