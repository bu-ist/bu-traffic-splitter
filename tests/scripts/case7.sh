#!/bin/bash

# Container must respect DNS_RESOLVER_TIMEOUT and send requests to the new IP

yml="docker-compose.case7.yml"

function up() {
    docker-compose -f $yml up -d --build
}

function down() {
    docker-compose -f $yml down
}

up

file1=`curl -sS localhost:3000/file1.txt`
if [[ $file1 != "backend1_file1" ]]; then
    echo "Wrong output: $file1. Must be backend1_file1"
    down
    exit 1
fi

docker-compose -f $yml exec dns change-ip.sh backend1 backend2
sleep 2

file2=`curl -sS localhost:3000/file1.txt`
if [[ $file2 != "backend2_file1" ]]; then
    echo "Wrong output: $file2. Must be backend2_file1"
    down
    exit 1
fi

down