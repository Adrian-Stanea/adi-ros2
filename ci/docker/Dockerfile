# Use the ROS2 base image
ARG ROS_DISTRO=humble
ARG FROM_IMAGE=ros:${ROS_DISTRO}-ros-base
ARG OVERLAY_WS

FROM ${FROM_IMAGE}

LABEL maintainer="Bogdan Stanea, <Adrian.Stanea@analog.com>"

# Disable apt user dialogs when installing packages
ENV DEBIAN_FRONTEND=noninteractive

ENV OVERLAY_WS=${OVERLAY_WS:-/opt/ros/overlay_ws}
ENV WORKSPACE=/workspace

# Setup the ROS2 workspace
WORKDIR $OVERLAY_WS/src

# Install dependencies
WORKDIR /dependencies

COPY . .

RUN chmod +x *.sh \
    && ./install_dependencies.sh install_all \
    && rm -rf /dependencies \
    && rm -rf /var/lib/apt/lists/*

# Enable apt user dialogs again
ARG DEBIAN_FRONTEND=dialog

# Setup the CI workspace
WORKDIR ${WORKSPACE}