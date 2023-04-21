#!/bin/bash

set -eux

source ./src/blobs-versions.env
source ./rel.env

mkdir -p "$TMP_DIR"

# shellcheck disable=SC2086
bosh create-release --version="$REL_VERSION" $REL_FLAGS --name="$REL_NAME" --tarball="$REL_TARBALL_PATH"

echo "Release created: ${REL_TARBALL_PATH}"

SHA1=($(sha1sum "$REL_TARBALL_PATH"))
TARBALL_URL="https://github.com/kinjelom/minio-boshrelease/releases/download/v$REL_VERSION/$REL_TARBALL"

set -

echo "### BOSH Release: $REL_NAME"
echo " "
echo 'You can reference this release in your deployment manifest from the `releases` section:'
echo '```yaml'
echo "- name: \"$REL_NAME\""
echo "  version: \"$REL_VERSION\""
echo "  url: \"$TARBALL_URL\""
echo "  sha1: \"$SHA1\""
echo '```'
echo 'Or upload it to your director with the `upload-release` command:'
echo '```'
echo "bosh upload-release --sha1 $SHA1 \ "
echo "  $TARBALL_URL"
echo '```'
echo " "

