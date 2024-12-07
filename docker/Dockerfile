###################### BUILDER ######################
FROM ubuntu:latest AS builder

SHELL ["/bin/bash", "-c"]

WORKDIR /root

ARG lang="C"
ARG dir="backup"

ENV DEBIAN_FRONTEND = noninter active
ENV TERM xterm
ENV DISPLAY host.docker.internal:0.0

#~~~~~~~~~~~~~~~~~~~~~~ EDIT ~~~~~~~~~~~~~~~~~~~~~~~#

RUN apt -y update && apt -y upgrade &&\
    apt -y install tzdata \
    locales \
    <packages name> \
    <packages name> \
    <packages name> &&\
    mkdir /root/${dir} &&\
    locale-gen ${lang}

#~~~~~~~~~~~~~~~~~~~~~~ EDIT ~~~~~~~~~~~~~~~~~~~~~~~#

ENV LANG ${lang}
ENV LANGUAGE ${lang}
ENV LC_ALL ${lang}
ENV TZ=Asia/Tokyo
ENV TZ JST-9

EXPOSE 22