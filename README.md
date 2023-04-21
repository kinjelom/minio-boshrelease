# MinIO BOSH Release

This repository was recovered from my fork of the [MinIO Boshrelease](https://github.com/minio/minio-boshrelease) version [`2022-02-17T23-22-26Z`](https://github.com/kinjelom/minio-boshrelease/tree/2022-02-17T23-22-26Z) ([GNU AGPL V3](LICENSE)).

Please check:
- [official releases](https://bosh.io/releases/github.com/minio/minio-boshrelease?all=1)
- [unofficial releases based on this repository](https://github.com/kinjelom/minio-boshrelease/releases)
- [example manifests](manifests)

## Bosh

[BOSH](http://bosh.io/) allows users to easily version, package and deploy software in a reproducible manner. This repo provides BOSH release of [MinIO](https://github.com/minio/minio) Object Storage Server. You can use this release to deploy MinIO in standalone, single-node mode as well as in distributed mode on multiple nodes.

## Deploy

### Standalone Minio deployment

``` shell
$ bosh deploy -d minio manifests/manifest-fs-example.yml \
    -v deployment_name=minio \
    -v minio_accesskey=admin \
    -v minio_secretkey=CHANGEME!
```

### Distributed MinIO deployment

For deploying a distributed version, set the number of desired instances in the manifest file.

``` shell
$ bosh deploy -d minio manifests/manifest-dist-example.yml \
    -v deployment_name=minio \
    -v minio_accesskey=admin \
    -v minio_secretkey=CHANGEME!
```

### NAS MinIO deployment

For deploying a minio backed by a NAS mounted directory.  In this example using NFS with the nfs_mounter job from the [CAPI Release](https://github.com/cloudfoundry/capi-release).

``` shell
$ bosh deploy -d minio manifests/manifest-nas-example.yml \
    -v deployment_name=minio \
    -v minio_accesskey=admin \
    -v minio_secretkey=CHANGEME!
```

### MinIO Console UI

For deploying a minio with registered routing for API & Console UI use ops:

``` shell
$ bosh deploy -d minio manifests/manifest-[fs|dist|nas]-example.yml \
    -v deployment_name=minio \
    -v minio_accesskey=admin \
    -v minio_secretkey=CHANGEME! \
    -o manifests/ops/register-api-and-console.yml \
    -v minio_api_uri=my-minio-api.example.org \
    -v minio_console_uri=my-minio-console.example.org
```

### License
MinIO BOSH release is licensed under [GNU AFFERO GENERAL PUBLIC LICENSE](https://www.gnu.org/licenses/agpl-3.0.en.html) 3.0 or later.

---

This repository isn't supported by Pivotal, if you are interested in the support [read this doc](PIVOTAL.md).
