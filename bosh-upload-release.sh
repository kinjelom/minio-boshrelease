#!/bin/bash

set -eux

source ./src/blobs-versions.env
source ./rel.env

chmod a+r "$REL_TARBALL_PATH"
bosh upload-release "$REL_TARBALL_PATH"
