#!/bin/bash

# Script to build and install 3fs
# Usage: ./scripts/3fs_initialize.sh 

# Color definitions
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

# Configuration
REPO_ROOT=`pwd`
GITHUB_PROXY=${GITHUB_PROXY:-"https://github.com"}
GOVER=1.23.8

# Function to print section headers
print_section() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

# Function to print success messages
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Function to print error messages and exit
print_error() {
    echo -e "${RED}✗ ERROR: $1${NC}"
    exit 1
}

# Function to check command success
check_success() {
    if [ $? -ne 0 ]; then
        print_error "$1"
    fi
}

# Install 3fs
print_section "Installing 3fs"

# Check if thirdparties directory exists
if [ ! -d "${REPO_ROOT}/thirdparties" ]; then
    mkdir -p "${REPO_ROOT}/thirdparties"
    check_success "Failed to create thirdparties directory"
fi

# Change to thirdparties directory
cd "${REPO_ROOT}/thirdparties"
check_success "Failed to change to thirdparties directory"

# Check if 3fs is already installed
if [ -d "3fs" ]; then
    echo -e "${YELLOW}3fs directory already exists. Removing for fresh install...${NC}"
    rm -rf 3fs
    check_success "Failed to remove existing 3fs directory"
fi

# Clone 3fs
echo "Cloning 3fs from ${GITHUB_PROXY}/deepseek-ai/3fs.git"
git clone ${GITHUB_PROXY}/deepseek-ai/3fs.git
check_success "Failed to clone 3fs"

# Build and install 3fs
cd 3fs
check_success "Failed to change to 3fs directory"

echo "installing dependencies for 3fs"

git submodule update --init --recursive
./patches/apply.sh

# for Ubuntu 22.04.
apt install cmake libuv1-dev liblz4-dev liblzma-dev libdouble-conversion-dev libdwarf-dev libunwind-dev \
  libaio-dev libgflags-dev libgoogle-glog-dev libgtest-dev libgmock-dev clang-format-14 clang-14 clang-tidy-14 lld-14 \
  libgoogle-perftools-dev google-perftools libssl-dev gcc-12 g++-12 libboost-all-dev build-essential

echo "install libfuse 3.16.1"
wget https://github.com/libfuse/libfuse/releases/download/fuse-3.16.1/fuse-3.16.1.tar.gz
tar vzxf fuse-3.16.1.tar.gz
cd fuse-3.16.1/
mkdir build; cd build
apt install meson meson setup .. ninja ; ninja install

echo "install rust"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

echo "install foundationdb"
wget https://github.com/apple/foundationdb/releases/download/7.3.63/foundationdb-clients_7.3.63-1_amd64.deb
wget https://github.com/apple/foundationdb/releases/download/7.3.63/foundationdb-server_7.3.63-1_amd64.deb
dpkg -i foundationdb-clients_7.3.63-1_amd64.deb
dpkg -i foundationdb-server_7.3.63-1_amd64.deb


echo "Configuring and Building 3fs..."
cmake -S . -B build -DCMAKE_CXX_COMPILER=clang++-14 -DCMAKE_C_COMPILER=clang-14 -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
check_success "Failed to configure and build 3fs"

echo "Building 3fs (using $(nproc) cores)..."
cmake --build build -j$(nproc)
check_success "Failed to build 3fs"

print_success "3fs installed successfully"

# echo "run 3fs single node test deploy"
# tests/fuse/run.sh <binary> <test-dir> <log-dir>