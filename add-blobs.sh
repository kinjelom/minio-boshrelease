#!/bin/bash

set -eux

source ./src/blobs-versions.env
source ./rel.env

mkdir -p "$TMP_DIR"

down_add_blob() {
  FILE=$1
  URL=$2
  if [ ! -f "blobs/${FILE}" ];then
    echo "Downloads resource from the Internet ($URL -> $TMP_DIR/$FILE)"
    curl -L "$URL" --output "$TMP_DIR/$FILE"
    echo "Adds blob ($TMP_DIR/$FILE -> $FILE), starts tracking blob in config/blobs.yml for inclusion in packages"
    bosh add-blob "$TMP_DIR/$FILE" "$FILE"
  fi
}

down_add_blob "minio-${MINIO_VERSION}" "https://dl.minio.io/server/minio/release/linux-amd64/archive/minio.RELEASE.${MINIO_VERSION}"
down_add_blob "mc-${MC_VERSION}" "https://dl.minio.io/client/mc/release/linux-amd64/archive/mc.RELEASE.${MC_VERSION}"
down_add_blob "kes-${KES_VERSION}" "https://github.com/kinjelom/kes/releases/download/v${KES_VERSION}/kes-${KES_VERSION}-linux-amd64"
down_add_blob "jq-${JQ_VERSION}" "https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64"

echo "Download blobs into blobs/ based on config/blobs.yml"
bosh sync-blobs

echo "Upload previously added blobs that were not yet uploaded to the blobstore. Updates config/blobs.yml with returned blobstore IDs."
bosh upload-blobs

