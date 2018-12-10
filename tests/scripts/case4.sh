#!/bin/bash

# Container must work fine when DEFAULT_URL, ALTERNATE_URL and INTERCEPT_MASK are set

yml="docker-compose.case4.yml"

function up() {
    docker-compose -f $yml up -d --build
}

function down() {
    docker-compose -f $yml down
}

up

file1=`curl -sS localhost:3000/index.html`
if [[ $file1 == *"http://localhost:3000/backend2/file2.txt"* ]]; then true; else
    echo "Wrong output: $file1"
    down
    exit 1
fi

file2=`curl -sS http://localhost:3000/backend2/file2.txt`
if [[ $file2 != "backend1_file2" ]]; then
    echo "Wrong output: $file2"
    down
    exit 1
fi

down