#!/usr/bin/env bash

OVERLAY_WS=${OVERLAY_WS:-/opt/ros/overlay_ws}

BASE_REPO=$(git rev-parse --show-toplevel)
BRANCH_NAME=${BRANCH_NAME:-main}

if [ ! -d "$OVERLAY_WS" ]; then
    echo "Directory $OVERLAY_WS does not exist."
    exit 1
fi

# TODO: review the build process
#  TBD: docker image prepares the ros2_ws and the CI just does a checkout
#       - try to build the package with colcon
#       - run tests if possible
#       - investigate if another CI can create a local .deb that could be used as an artifact
# 
#  A release will publish the .deb or a Docker image wrapper using the .deb form the ros2.org index

# A function that gets the URL and HASH of the submodules and stores them in variables

pushd "$BASE_REPO"

mkdir -p "$OVERLAY_WS"/src

setup_workspace() {
    for submodule in $(git submodule | awk '{ print $2 }' | xargs)
    do
        SUBMODULE_URL=$(git config --file=.gitmodules submodule."${submodule}".url)
        SUBMODULE_HASH=$(git ls-tree HEAD "$submodule" | awk '{ print $3 }')
        
        pushd $OVERLAY_WS/src
        git clone $SUBMODULE_URL
        cd "$(basename "$SUBMODULE_URL" .git)"
        git checkout "$SUBMODULE_HASH"
        popd

    done
}


build_from_source() {
    cd "${OVERLAY_WS}" || exit

    # source /opt/ros/"$ROS_DISTRO"/setup.sh

    # Install dependencies using rosdep
    apt-get update -y
    rosdep update
    rosdep install --from-paths src --ignore-src -r -y


    # NOTE: export from below is required to build imu-ros2 (it creates a per device package)
    # export DEVICE_ID=adis16505-2

    colcon build \
        --cmake-args \
        -DCMAKE_C_COMPILER=gcc-9 \
        -DCMAKE_CXX_COMPILER=g++-9

    # Create .deb packages locally
    rosdep install --from-paths src -y --ignore-src

    cd src/tof-ros2
    bloom-generate rosdebian \
        --ros-distro $ROS_DISTRO

    fakeroot debian/rules binary
}


setup_workspace


popd