#!/bin/bash

# When proxying to DEFAULT_URL (both with or without INTERCEPT_MASK), must pass the original "Host" header.

yml="docker-compose.case9.yml"

function up() {
    docker-compose -f $yml up -d --build
}

function down() {
    docker-compose -f $yml down
}

up

file1=`curl -s localhost:3000/file1.txt -H "Host: host-protected.domain.com"`
if [[ $file1 != "backend1_file1" ]]; then
    echo "Wrong output: $file1"
    down
    exit 1
fi

status1=`curl -s -o /dev/null -w "%{response_code}" localhost:3000/file1.txt`
if [[ $status1 != "403" ]]; then
    echo "Wrong status: $status1. Must be 403"
    down
    exit 1
fi

index=`curl -sS localhost:3001/index.html`
if [[ $index == *"http://localhost:3001/backend2/file2.txt"* ]]; then true; else
    echo "Wrong output: $index"
    down
    exit 1
fi

file2=`curl -sS http://localhost:3001/backend2/file2.txt -H "Host: host-protected.domain.com"`
if [[ $file2 != "backend1_file2" ]]; then
    echo "Wrong output: $file2"
    down
    exit 1
fi

status2=`curl -s -o /dev/null -w "%{response_code}" http://localhost:3001/backend2/file2.txt`
if [[ $status2 != "403" ]]; then
    echo "Wrong status: $status2. Must be 403"
    down
    exit 1
fi



down