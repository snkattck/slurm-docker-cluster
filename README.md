# Slurm Docker Cluster

This is a multi-container Slurm cluster using docker-compose.  The compose file
creates named volumes for persistent storage of MySQL data files as well as
Slurm state and log directories.

This is a fork of <https://github.com/giovtorres/slurm-docker-cluster,> including the latest
slurm as default, basic BATS <https://github.com/bats-core/bats-core,> testing which
determines whether the correct version of Slurm is installed, two nodes are available,
and a job can be submitted.

## Testing

Typically,

```make test```

On OS X, you must install a newer version of GNU Make by running:

```brew install remake```

Then run ```remake test```

## Containers and Volumes

The compose file will run the following containers:

* mysql
* slurmdbd
* slurmctld
* c1 (slurmd)
* c2 (slurmd)

The compose file will create the following named volumes:

* etc_munge         ( -> /etc/munge     )
* etc_slurm         ( -> /etc/slurm     )
* slurm_jobdir      ( -> /data          )
* var_lib_mysql     ( -> /var/lib/mysql )
* var_log_slurm     ( -> /var/log/slurm )

## Building the Docker Image

Build the image locally:

```console
make build
```

Build a different version of Slurm using Docker build args and the Slurm Git
tag. Slurm tags available on https://github.com/SchedMD/slurm/releases.

```console
make build -s SLURM_TAG="slurm-19-05-2-1"
```

## Starting the Cluster

Run `docker-compose` to instantiate the cluster. ```SLURM_TAG``` is required.
Latest supported SLURM_TAG is ```slurm-20-02-1-1```.

```console
env SLURM_TAG=slurm-20-02-1-1 docker-compose up -d
```

## Register the Cluster with SlurmDBD

To register the cluster to the slurmdbd daemon, run the `register_cluster.sh`
script:

```console
./register_cluster.sh
```

> Note: You may have to wait a few seconds for the cluster daemons to become
> ready before registering the cluster.  Otherwise, you may get an error such
> as **sacctmgr: error: Problem talking to the database: Connection refused**.
>
> You can check the status of the cluster by viewing the logs: `docker-compose
> logs -f`

## Accessing the Cluster

Use `docker exec` to run a bash shell on the controller container:

```console
docker exec -it slurmctld bash
```

From the shell, execute slurm commands, for example:

```console
[root@slurmctld /]# sinfo
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
normal*      up 5-00:00:00      2   idle c[1-2]
```

## Submitting Jobs

The `slurm_jobdir` named volume is mounted on each Slurm container as `/data`.
Therefore, in order to see job output files while on the controller, change to
the `/data` directory when on the **slurmctld** container and then submit a job:

```console
[root@slurmctld /]# cd /data/
[root@slurmctld data]# sbatch --wrap="uptime"
Submitted batch job 2
[root@slurmctld data]# ls
slurm-2.out
```

## Stopping and Restarting the Cluster

```console
docker-compose stop
docker-compose start
```

## Deleting the Cluster

To remove all containers and volumes, run:

```console
docker-compose down -v
```

If you want to keep your configuration and metadata as docker volumes,
just omit ```-v``` and run

```console
docker-compose down
```
