#!/bin/bash

# Container must work fine when DEFAULT_URL, ALTERNATE_REF and INTERCEPT_MASK are set

yml="docker-compose.case5.yml"

function up() {
    docker-compose -f $yml up -d --build
}

function down() {
    docker-compose -f $yml down
}

up

file1=`curl -sS localhost:3000/index.html`
if [[ $file1 == *"http://localhost:3000/ref-protected.domain.com/file1.txt"* ]]; then true; else
    echo "Wrong output: $file1"
    down
    exit 1
fi

file2=`curl -sS http://localhost:3000/ref-protected.domain.com/file1.txt`
if [[ $file2 != "backend2_file1" ]]; then
    echo "Wrong output: $file2"
    down
    exit 1
fi

protected_file=`curl -s -o /dev/null -w "%{response_code}" localhost:3050/file1.txt`
if [[ $protected_file != "403" ]]; then
    echo "Wrong status: $protected_file. Must be 403"
    down
    exit 1
fi



down