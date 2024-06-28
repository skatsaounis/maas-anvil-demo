#!/bin/bash

set -xe

node_ips=$(terraform output -json | jq -r .ip_addresses.value[])
for ip in $node_ips; do
    ssh -o "StrictHostKeyChecking no" ubuntu@$ip bash -s < setup-via-ssh.sh
done
