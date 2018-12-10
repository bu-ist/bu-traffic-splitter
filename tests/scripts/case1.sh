#!/bin/bash

# Container must work fine when DEFAULT_URL, ALTERNATE_URL and ALTERNATE_MASK are set

yml="docker-compose.case1.yml"

function up() {
    docker-compose -f $yml up -d --build
}

function down() {
    docker-compose -f $yml down
}

up

file1=`curl -sS localhost:3000/file1.txt`
if [[ $file1 != "backend1_file1" ]]; then
    echo "Wrong output: $file1"
    down
    exit 1
fi

file2=`curl -sS localhost:3000/file2.txt`
if [[ $file2 != "backend2_file2" ]]; then
    echo "Wrong output: $file2"
    down
    exit 1
fi

down