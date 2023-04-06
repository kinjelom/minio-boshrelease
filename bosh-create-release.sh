#!/bin/bash

set -eux

source ./rel.env

mkdir -p $TMP_DIR

bosh create-release --version=$REL_VERSION $REL_FLAGS --name=$REL_NAME  --tarball=$REL_TARBALL_PATH

echo "Release created: ${REL_TARBALL_PATH}"
SHA1=($(sha1sum $REL_TARBALL_PATH))
echo "Release $REL_NAME/$REL_VERSION - $REL_TARBALL_PATH sha1: $SHA1 "