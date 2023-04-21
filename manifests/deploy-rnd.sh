#!/bin/bash

source ../src/blobs-versions.env
source ../rel.env

deployment_name=minio-rnd

bosh -d ${deployment_name} deploy manifest-example.yml \
  -v deployment_name=${deployment_name} \
  -v minio_version="${REL_VERSION}" \
  -o ops/register-api-and-console.yml \
  --vars-file=vars/${deployment_name}-vars-file.yml \
  --vars-store=vars/${deployment_name}-vars-store.yml \
  --no-redact --fix

