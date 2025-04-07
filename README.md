# MinIO BOSH Release

This repository was recovered from my fork of the [MinIO Boshrelease](https://github.com/minio/minio-boshrelease) ([GNU AGPL V3](LICENSE))
and then simplified (also reduced in size by removing binaries from git history) and adapted to the latest MinIO releases with partial breaking of backward compatibility.

[BOSH](http://bosh.io/) allows users to easily version, package and deploy software in a reproducible manner. This repo provides BOSH release of [MinIO](https://github.com/minio/minio) Object Storage Server. You can use this release to
deploy MinIO in standalone, single-node mode as well as in distributed mode on multiple nodes.

## License

`MinIO BOSH Release` is licensed under [GNU AFFERO GENERAL PUBLIC LICENSE](https://www.gnu.org/licenses/agpl-3.0.en.html)
3.0 or later.

## Releases

You can find all the new releases [here](https://github.com/kinjelom/minio-boshrelease/releases).

Version numbers are created as a mix of [Semantic](https://semver.org/) and MinIO approaches, if an incompatibility is detected in the MinIO version, the major version number will be changed:

`MAJOR`.`MINOR`.`PATCH`+minio.`MinIO-Version`

For this reason, the older versions are treated as `1.*.*` and the new ones as `2.*.*`.

The latest release: https://github.com/kinjelom/minio-boshrelease/releases/latest 

> **Note**
> 
> Older official releases can be found [here on the bosh.io website](https://bosh.io/releases/github.com/minio/minio-boshrelease?all=1).


## Deployment

### Jobs

- [`minio-server` spec](jobs/minio-server/spec) - the main job that runs the MinIO Server
- [`mc` spec](jobs/mc/spec) - the MinIO Client `mc` with the pre-configured this MinIO Server host configuration called `THIS_MINIO`
- [`smoke-tests` spec](jobs/smoke-tests/spec) - tests checking operations on `THIS_MINIO` buckets and objects 

### Manifest

> **Warning**
> 
> The [new releases](https://github.com/kinjelom/minio-boshrelease/releases) are not fully compatible with previous [official releases](https://bosh.io/releases/github.com/minio/minio-boshrelease?all=1).

```yaml
name: ((deployment_name))

instance_groups:
  - name: minio
    instances: ((minio_instances))
    vm_type: ((minio_vm_type))
    persistent_disk_type: ((minio_disk_type))
    env: { persistent_disk_fs: xfs }
    jobs:
      - name: minio-server
        release: minio
        provides:
          minio-server: { as: minio-link }
        properties:
          credential:
            root_user: ((minio_root_user))
            root_password: ((minio_root_password))
          server_config:
            # console 
            MINIO_BROWSER_REDIRECT_URL: "https://((minio_console_uri))"
            # prometheus
            MINIO_PROMETHEUS_AUTH_TYPE: "public"
            MINIO_PROMETHEUS_URL: "http://q-s0.prometheus2.default.prometheus.bosh:9090"
            MINIO_PROMETHEUS_JOB_ID: "((deployment_name))"
            # storage-class https://min.io/docs/minio/linux/reference/minio-server/minio-server.html#storage-class
            MINIO_STORAGE_CLASS_STANDARD: "((minio_storage_class_standard))"
# ...
```
[Here is the full example](manifests/manifest-example.yml)

#### The variables:

1. `Standalone` mode:
   ```yaml
   minio_instances: 1
   minio_storage_class_standard: "EC:0" # ignored by MinIO
   ```
2. `Distributed` - HA mode:
   ```yaml
   minio_instances: 3 # or more, 2 instances causes readonly cluster if only one node is up
   minio_storage_class_standard: "EC:1" # if the disks are already redundant (e.g. CEPH EC) this is min. EC accepted by MinIO
   ```

**CAUTION!!!** MinIO does NOT support changing the number of nodes in the deployed cluster:
- https://github.com/minio/minio/issues/9228
- https://github.com/minio/minio/tree/master/docs/distributed#expanding-existing-distributed-setup

#### Ops:

- [register-api-and-console.yml](manifests/ops/register-api-and-console.yml) - API and console route registration
- [seeding.yml](manifests/ops/seeding.yml) - create default buckets after cluster deploy
- [smoke-tests.yml](manifests/ops/smoke-tests.yml) - some smoke tests after cluster deploy
- [minio-enc.yml](manifests/ops/minio-enc.yml) - TLS encryption

## Server-Side Encryption of Objects

Ths deployment supports encrypting IAM with a single key only. 
You can set the env. variable `MINIO_KMS_SECRET_KEY`, it expects the following format:

```bash
MINIO_KMS_SECRET_KEY=<key-name>:<base64-value>
```

For more details refer to [MinIO KMS Quick Start](https://github.com/minio/minio/blob/master/docs/kms/IAM.md#minio-kms-quick-start).

## Estimation of Deployment

- https://min.io/product/reference-hardware
- https://min.io/product/erasure-code-calculator
- https://en.wikipedia.org/wiki/Erasure_code

## Previous Releases

> **Warning**
> 
> As of RELEASE.2022-10-29T06-21-33Z, the MinIO **Gateway** and the related **filesystem** mode code have been **removed**.
>
> Deployments still using the standalone or filesystem MinIO modes that upgrade to MinIO Server
> RELEASE.2022-10-29T06-21-33Z or later receive an error when attempting to start MinIO.
> 
> [More info...](https://min.io/docs/minio/linux/operations/install-deploy-manage/migrate-fs-gateway.html)


The latest BOSH release of the MinIO with the **Gateway** and the related **filesystem** mode is [RELEASE.2022-10-24T18-35-07Z](https://bosh.io/releases/github.com/minio/minio-boshrelease?version=2022-10-24T18-35-07Z)

Other releases code:
- This repository was recovered up to the `RELEASE.2022-02-17T23-22-26Z`
- Changes up to the [RELEASE.2022-11-11T03-44-20Z are available here](https://github.com/kinjelom/minio-boshrelease/pull/1).

