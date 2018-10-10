#!/bin/bash
export ROLE=##ROLE##
export DB_IP=##DB_IP##
env | grep "ROLE\|DB_IP" > /tmp/init_envvars
sudo apt-get update
sudo apt-get install -y git
git clone https://github.com/bzcnsh/fast_deploy.git
pushd fast_deploy
bash deploy.sh
popd

