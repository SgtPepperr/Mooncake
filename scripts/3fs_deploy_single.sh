#!/bin/bash

MOONCAKE_STORAGE_ROOT_DIR="/tmp/3fs_store"
MOONCAKE_STORAGE_LOG_DIR="/tmp/3fs_log"


# 清理函数
cleanup() {
    echo "Cleaning up..."
    rm -rf "$MOONCAKE_STORAGE_ROOT_DIR"
    rm -rf "$MOONCAKE_STORAGE_LOG_DIR"
    exit 1
}

mkdir -p "${MOONCAKE_STORAGE_ROOT_DIR}"
mkdir -p "${MOONCAKE_STORAGE_LOG_DIR}"
# ./thirdparties/3fs/tests/fuse/run.sh <path to 3fs binary> <path to test directory>
chmod +x ./thirdparties/3fs/tests/fuse/run.sh
ulimit -n 65535
./thirdparties/3fs/tests/fuse/run.sh ./thirdparties/3fs/build/bin ${MOONCAKE_STORAGE_ROOT_DIR} ${MOONCAKE_STORAGE_LOG_DIR}

while ((1))
do
        date
        sleep 1
done