#!/usr/bin/env bash

set -ex

ROS_DISTROS=(noetic)


CI_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$CI_DIR"


for ROS_DISTRO in "${ROS_DISTROS[@]}"; do
    docker build \
        --no-cache \
        --file ./docker/Dockerfile \
        --build-arg ROS_DISTRO=${ROS_DISTRO} \
        --tag adi-ros2:${ROS_DISTRO}-dev .
done