#!/bin/bash

# Container must work fine with backends that gzip their response.

yml="docker-compose.case10.yml"

function up() {
    docker-compose -f $yml up -d --build
}

function down() {
    docker-compose -f $yml down
}

up

status=`curl -s -o /dev/null -w "%{response_code}" localhost:3000/index.html`
if [[ $status != "403" ]]; then
    echo "Wrong status: $status. Must be 403"
    down
    exit 1
fi

index=`curl -sS localhost:3000/index.html -H "Host: host-protected.domain.com"`
if [[ $index == *"http://host-protected.domain.com/backend2/file2.txt"* ]]; then true; else
    echo "Wrong output: $index"
    down
    exit 1
fi

file1=`curl -s localhost:3000/backend2/file2.txt -H "Host: host-protected.domain.com"`
if [[ $file1 != "backend1_file2" ]]; then
    echo "Wrong output: $file1"
    down
    exit 1
fi

down