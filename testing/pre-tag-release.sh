#! /bin/bash

set -e
root=$(git rev-parse --show-toplevel)

cd $root

bindir="$PWD/build-and-test"
function cleanup()
{
  rm -r $bindir
}
trap cleanup EXIT

mkdir $bindir
cd $bindir
cmake .. -DCMAKE_INSTALL_PREFIX=$bindir/install
cmake --build .
cmake --build . --target test

# test install
cmake --build . --target install

mkdir app
cd app

cat << EOF > main.cpp
#include <iostream>
#include <Interp.hpp>

int main()
{
  std::cout << "VERSION: " << libInterp_VERSION << std::endl;
  std::cout << "FULL VERSION: " << libInterp_VERSION_FULL << std::endl;

  _1D::LinearInterpolator<double> i1;

  return 0;
}
EOF

cat << EOF > CMakeLists.txt
cmake_minimum_required(VERSION 3.1)
add_executable( main main.cpp )
find_package( libInterp REQUIRED PATHS ${bindir}/install )
target_link_libraries(main libInterp::Interp )
set_target_properties(main PROPERTIES CXX_STANDARD 11)
EOF

mkdir build1
cd build1
cmake .. -DlibInterp_DIR=${bindir}/install/cmake/libInegrate
cmake --build .
./main

cd ..

mkdir build2
cd build2
cmake ..
cmake --build .
./main

echo "PASSED"

exit 0
