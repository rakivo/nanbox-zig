CACHE_DIR=build

set -xe

zig build-exe main.zig --cache-dir $CACHE_DIR
