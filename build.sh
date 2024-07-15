CACHE_DIR=build

set -xe

zig build-exe test.zig --cache-dir $CACHE_DIR
