#!/bin/bash

set -xe

sudo snap install maas-anvil --channel=latest/edge/pgbouncer
maas-anvil prepare-node-script | bash -x
