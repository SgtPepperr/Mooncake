# Find Python package
add_subdirectory(cachelib_memory_allocator)

set(MOONCAKE_STORE_SOURCES
    allocator.cpp
    master_service.cpp
    client.cpp
    types.cpp
    master_client.cpp
    utils.cpp
    master_metric_manager.cpp
    file_storage_backend.cpp
    local_file.cpp
    thread_pool.cpp
)

# The cache_allocator library
include_directories(${Python3_INCLUDE_DIRS})
add_library(mooncake_store ${MOONCAKE_STORE_SOURCES})
target_link_libraries(mooncake_store PUBLIC transfer_engine glog::glog gflags::gflags)


# Master binary
add_executable(mooncake_master master.cpp)
target_link_libraries(mooncake_master PRIVATE
    mooncake_store
    cachelib_memory_allocator
    pthread
)

install(TARGETS mooncake_master DESTINATION bin)
