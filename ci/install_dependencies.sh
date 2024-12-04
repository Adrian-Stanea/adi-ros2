#!/usr/bin/env bash

CMAKE_VERSION=${CMAKE_VERSION:-3.20.0}
GLOG_VERSION=${GLOG_VERSION:-0.6.0}
LIBWEBSOCKETS_VERSION=${LIBWEBSOCKETS_VERSION:-3.1}
PROTOBUF_VERSION=${PROTOBUF_VERSION:-3.9.0}
ToF_VERSION=${ToF_VERSION:-5.0.0}
LIBIIO_VERSION=${LIBIIO_VERSION:-0.26} 

BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)


install_packages() {
    echo "Installing packages"
    apt-get update -y
    source "${BASE_DIR}"/apt-packages.sh
    apt-get install --no-install-recommends -y "${apt_packages[@]}"
}

install_glog() {
    echo "Building glog v${GLOG_VERSION}"
    pushd .
    git clone --branch v${GLOG_VERSION} --depth 1 https://github.com/google/glog
    cd glog
    mkdir -p build_"${GLOG_VERSION}" && cd build_"${GLOG_VERSION}"
    cmake .. \
        -DCMAKE_C_COMPILER=gcc-9 \
        -DCMAKE_CXX_COMPILER=g++-9 \
        -DWITH_GFLAGS=off \
        -DCMAKE_INSTALL_PREFIX=/opt/glog
    cmake --build . --target install
    popd || exit
}

install_libwebsockets() {
    echo "Building libwebsockets v${LIBWEBSOCKETS_VERSION}"
    pushd .
    git clone --branch v${LIBWEBSOCKETS_VERSION}-stable --depth 1 https://github.com/warmcat/libwebsockets
    cd libwebsockets
    mkdir -p build_"${LIBWEBSOCKETS_VERSION}" && cd build_"${LIBWEBSOCKETS_VERSION}"
    cmake .. \
        -DCMAKE_C_COMPILER=gcc-9 \
        -DCMAKE_CXX_COMPILER=g++-9 \
        -DLWS_STATIC_PIC=ON \
        -DLWS_WITH_SSL=OFF \
        -DCMAKE_INSTALL_PREFIX=/opt/websockets
    cmake --build . --target install
    popd || exit
}

install_protobuff() {
    echo "Building protobuf v${PROTOBUF_VERSION}"
    pushd .
    git clone --branch v"${PROTOBUF_VERSION}" --depth 1 https://github.com/protocolbuffers/protobuf
    cd protobuf
    mkdir -p build_"${PROTOBUF_VERSION}" && cd build_"${PROTOBUF_VERSION}"
    cmake ../cmake \
        -DCMAKE_C_COMPILER=gcc-9 \
        -DCMAKE_CXX_COMPILER=g++-9 \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
        -Dprotobuf_BUILD_TESTS=OFF \
        -DCMAKE_INSTALL_PREFIX=/opt/protobuf
    cmake --build . --target install
    popd || exit
}

install_ToF_SDK() {
    echo "Building ToF v${ToF_VERSION}"
    pushd .
    git clone --depth 1 --recurse-submodules --branch v"${ToF_VERSION}" https://github.com/analogdevicesinc/ToF
    cd ToF
    mkdir build_"${PROTOBUF_VERSION}" && cd build_"${PROTOBUF_VERSION}"
    cmake .. \
        -DCMAKE_C_COMPILER=gcc-9 \
        -DCMAKE_CXX_COMPILER=g++-9 \
        -DWITH_EXAMPLES=on \
        -DWITH_DOC=off \
        -DWITH_PYTHON=off \
        -DWITH_OPENCV=off \
        -DWITH_OPEN3D=off \
        -DWITH_ROS2=off \
        -DWITH_NETWORK=on \
        -DWITH_OFFLINE=off \
        -DWITH_GLOG_DEPENDENCY=on \
        -DWITH_COMMAND_LINE_TOOLS=on \
        -DWITH_PROTOBUF_DEPENDENCY=on \
        -DCMAKE_PREFIX_PATH="/opt/glog;/opt/protobuf;/opt/websockets"
        # -DCMAKE_INSTALL_PREFIX=/opt/aditof
    cmake --build . --target install
    popd || exit
}

install_libiio() {
    echo "Building libiio v${LIBIIO_VERSION}"
    pushd .
    git clone --depth 1 --branch  v"${LIBIIO_VERSION}" https://github.com/analogdevicesinc/libiio.git
    cd libiio
    mkdir build_"${LIBIIO_VERSION}" && cd build_"${LIBIIO_VERSION}"
    cmake .. \
        -DCMAKE_C_COMPILER=gcc-9 \
        -DCMAKE_CXX_COMPILER=g++-9 \
        -DCPP_BINDINGS=ON
    cmake --build . --target install
    popd
}

install_all() {
    ## Dependencies: tof_ros2
    install_packages
    install_glog
    install_libwebsockets
    install_protobuff
    install_ToF_SDK
    ## Dependencies: imu_ros2
    install_libiio
}

# Call the functions passed as arguments
for func in "$@"; do
    if declare -f "$func" >/dev/null; then
        "$func"
    else
        echo "Function $func not found in the script."
        exit 1
    fi
done
