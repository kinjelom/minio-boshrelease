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


## Estimation of Deployment

Read first:
- https://min.io/product/reference-hardware
- https://min.io/product/erasure-code-calculator
- https://en.wikipedia.org/wiki/Erasure_code

### The Read and Write Speed

The read and write speed in MinIO depends on multiple factors, such as the number of nodes, the value of
`MINIO_STORAGE_CLASS_STANDARD`, disk speed, network throughput, server performance, and system load. It is not possible
to provide exact values, but one can present general principles that affect read and write speed in MinIO.

1. Number of nodes: More nodes in the cluster can contribute to higher throughput, as data is distributed across
   different nodes. However, too many nodes may lead to increased latency in communication between nodes.

2. Value of `MINIO_STORAGE_CLASS_STANDARD`: The EC (Erasure Coding) value affects data redundancy, and consequently,
   read
   and write performance. The higher the EC value, the more parity parts are added to the data, which may impact write
   speed. However, higher EC values can also improve read performance, as data can be reconstructed from multiple
   shards.

3. Disk speed: Faster disks, such as SSDs, can significantly improve read and write performance in MinIO compared to
   slower disks, such as HDDs.

4. Network throughput: A fast network with low latency between nodes can improve read and write performance, especially
   in a distributed MinIO system.

5. Server performance: Fast servers with plenty of RAM and multiple CPU cores can process requests more quickly,
   resulting in better read and write performance.

Since read and write speed depends on many factors, it is recommended to monitor the performance of the MinIO cluster
under real conditions and adjust the configuration as needed to achieve optimal performance.

### Disk Space

To estimate the amount of space used in a MinIO cluster depending on the number of nodes and
`MINIO_STORAGE_CLASS_STANDARD`, you can follow these steps:

1. Determine the data and parity shards: Look at the `MINIO_STORAGE_CLASS_STANDARD` value, which is in the
   format `EC:N`. The `N` represents the number of parity shards. The remaining shards are data shards. For example, if
   you have a 4-node cluster and `MINIO_STORAGE_CLASS_STANDARD="EC:1"`, there are 1 parity shard and 3 data shards.

2. Calculate the size of data and parity shards: Divide the size of the file by the number of data shards to get the
   size of each data shard. The size of parity shards will be equal to the size of the data shards.

3. Calculate the total space used: Multiply the size of the data shards by the number of data shards, and add the
   product to the size of the parity shards multiplied by the number of parity shards. This will give you the total
   space used in the MinIO cluster for the given file.

Here's an example for a `4-node` cluster and `MINIO_STORAGE_CLASS_STANDARD="EC:1"`. You want to store a `1 GB` file:

1. Data and parity shards: There are `1` parity shard (`EC:1`) and 3 data shards (`4 nodes - 1`).
2. Size of data and parity shards: Divide `1 GB` by `3` data shards, which results in approximately `0.333 GB`
   per data shard. The parity shard size is also `0.333 GB`.
3. Total space used: `(0.333 GB * 3 data shards) + (0.333 GB * 1 parity shard) = 1.333 GB`
   In this example, a `1 GB` file would take up `1.333 GB` of space in the MinIO cluster.

Keep in mind that this is a simplified estimation and actual space usage might vary due to factors such as metadata
overhead, file fragmentation, and cluster configuration.

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


## TODO:

- [ ] `mc mirror` as an errand, now you can use [this errand](manifests/ops/mirroring-to-this-minio-errand.yml)
- [ ] Data at-rest encryption manifest example, now only [in-transit](manifests/ops/minio-enc.yml)
- [ ] Migration errand, now you can use [this errand](manifests/ops/mirroring-to-this-minio-errand.yml)
   - https://min.io/docs/minio/linux/operations/install-deploy-manage/expand-minio-deployment.html

## To Consider:

- [ ] Multiple disks support, does anyone need it?
   - https://www.starkandwayne.com/blog/bosh-multiple-disks/
   - https://github.com/BeckerMax/multidisk-bosh-release
- [ ] Loadbalancing, does anyone need it?
   - https://min.io/docs/minio/linux/operations/install-deploy-manage/expand-minio-deployment.html#networking-and-firewalls
- [ ] self-healing, does anyone need it?
   - https://min.io/docs/minio/linux/reference/minio-mc-admin/mc-admin-heal.html
   - `mc admin heal CLUSTER/bucket --scan deep --recursive --rewrite`
