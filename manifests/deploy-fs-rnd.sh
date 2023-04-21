#!/bin/bash

deployment_name=minio-fs-rnd

bosh -d ${deployment_name} deploy manifest-fs-example.yml \
  -v deployment_name=${deployment_name} \
  -o ops/register-api-and-console.yml \
  --vars-file=vars/${deployment_name}-vars-file.yml \
  --vars-store=vars/${deployment_name}-vars-store.yml \
  --no-redact --fix

