#!/usr/bin/env bats
load './test_helper/bats-support/load'
load './test_helper/bats-assert/load'

DIR="$(dirname $BATS_TEST_FILENAME)"
SLURM_VERSION="$(echo -n ${SLURM_TAG}|awk -F- '{print $2"."$3"."$4}')"

setup() {
    docker-compose -f ${DIR}/../docker-compose.yml up -d
    sleep 60s
}

@test 'check slurm version matches SLURM_TAG' {
    run docker exec -i -t slurmctld slurmctld -V
    assert_output --regexp "^slurm ${SLURM_VERSION}.$"
}

@test 'two nodes are available' {
    run docker exec -i -t slurmctld sinfo -o '%D' --noheader
    assert_output --regexp "^2.$"
    
}

@test 'job can be submitted' {
    run docker exec -i -t slurmctld bash -c "cd /data; sbatch --wrap='echo L'"
    sleep 15s
    run docker exec -i -t slurmctld cat /data/slurm-2.out
    assert_output --regexp "^L.$"
}

teardown() {
    docker-compose -f ${DIR}/../docker-compose.yml down -v
}