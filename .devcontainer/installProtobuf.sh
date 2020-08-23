#!/bin/bash

if [[ -f "/usr/local/lib/cmake/grpc/gRPCConfig.cmake" ]]
then
  exit 0
fi

mkdir -p /tmp/repos
cd /tmp/repos
git clone https://github.com/google/protobuf.git
cd protobuf

mkdir -p cmake/build
cd cmake/build

cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -Dprotobuf_BUILD_TESTS=OFF \
  -Dprotobuf_BUILD_CONFORMANCE=OFF \
  -Dprotobuf_BUILD_EXAMPLES=OFF \
  -Dprotobuf_BUILD_PROTOC_BINARIES=ON \
  ..

make -j8
make install