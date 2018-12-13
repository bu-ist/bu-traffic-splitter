#!/bin/bash

# Container must work fine when DEFAULT_URL, ALTERNATE_MASK, ALTERNATE_URL and ALTERNATE_HOST are set

yml="docker-compose.case8.yml"

function up() {
    docker-compose -f $yml up -d --build
}

function down() {
    docker-compose -f $yml down
}

up

file2=`curl -sS http://localhost:3000/file1.txt`
if [[ $file2 != "backend2_file1" ]]; then
    echo "Wrong output: $file2"
    down
    exit 1
fi

status=`curl -s -o /dev/null -w "%{response_code}" localhost:3050/file1.txt`
if [[ $status != "403" ]]; then
    echo "Wrong status: $status. Must be 403"
    down
    exit 1
fi

down