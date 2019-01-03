#!/bin/bash

# Container must pass the value of the X-Forwarded-Proto header if one present.

yml="docker-compose.case11.yml"

function up() {
    docker-compose -f $yml up -d --build
}

function down() {
    docker-compose -f $yml down
}

up

output=`curl -s http://localhost:3000`
if [[ $output != "http" ]]; then
    echo "Wrong output: $output"
    down
    exit 1
fi

output=`curl -s http://localhost:3000 -H "X-Forwarded-Proto: http"`
if [[ $output != "http" ]]; then
    echo "Wrong output: $output"
    down
    exit 1
fi

output=`curl -s http://localhost:3000 -H "X-Forwarded-Proto: https"`
if [[ $output != "https" ]]; then
    echo "Wrong output: $output"
    down
    exit 1
fi

down