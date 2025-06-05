#!/bin/bash

# Script to test the mooncake client SSD functionality
# Usage: ./scripts/test_client_ssd.sh [storage_path]
# Example: ./scripts/build_wheel.sh /tmp/mooncake_store
# USE_CLIENT_PERSISTENCE should be set to True in the config file before cmake
# This script assumes that the mooncake master service and etcd are already built and available in the specified paths.

# This script running in a local environment ,if running in 3fs, we can't delete the storage directory at the end.

set -e  # Exit immediately if a command exits with a non-zero status

MOONCAKE_STORAGE_ROOT_DIR=${MOONCAKE_STORAGE_ROOT_DIR:-${1:-"/tmp/3fs_store/mnt"}}
echo "Testing mooncake client SSD with storage path: ${MOONCAKE_STORAGE_ROOT_DIR}"

export MOONCAKE_STORAGE_ROOT_DIR="${MOONCAKE_STORAGE_ROOT_DIR}"


echo "Starting mooncake metadata server..."
etcd --listen-client-urls http://0.0.0.0:2379 --advertise-client-urls http://localhost:2379 &
METADATA_pid=$!
sleep 1  # Wait for etcd to start

echo "starting mooncake master service..."
./build/mooncake-store/src/mooncake_master &
MASTER_pid=$!
sleep 1  # Wait for master to start

echo "Running mooncake client SSD tests..."
ROLE=prefill python3 ./mooncake-store/tests/stress_cluster_benchmark.py
sleep 1  # Wait for prefill to complete
ROLE=decode python3 ./mooncake-store/tests/stress_cluster_benchmark.py
sleep 1  # Wait for decode to complete

kill $MASTER_pid || true
kill $METADATA_pid || true

echo "All tests completed successfully!"