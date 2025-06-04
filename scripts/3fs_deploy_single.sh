#!/bin/bash

MOONCAKE_STORAGE_ROOT_DIR="/tmp/3fs_store"
MOONCAKE_STORAGE_LOG_DIR="/tmp/3fs_log"

mkdir -p "${MOONCAKE_STORAGE_ROOT_DIR}"
mkdir -p "${MOONCAKE_STORAGE_LOG_DIR}"
# ./thirdparties/3fs/tests/fuse/run.sh <path to 3fs binary> <path to test directory>
./thirdparties/3fs/tests/fuse/run.sh ./thirdparties/3fs/build/bin ${MOONCAKE_STORAGE_ROOT_DIR} ${MOONCAKE_STORAGE_LOG_DIR}

while ((1))
do
        date
        sleep 1
done