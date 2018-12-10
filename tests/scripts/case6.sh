#!/bin/bash

# Container must pass whichever HOST value it received to both DEFAULT_URL and ALTERNATE_URL

yml="docker-compose.case6.yml"

function up() {
    docker-compose -f $yml up -d --build
}

function down() {
    docker-compose -f $yml down
}

up

# Make sure that test container returns dynamic hostname
custom_host1=`curl -sS localhost:3050/host.html`
if [[ $custom_host1 != "localhost:3050" ]]; then
    echo "Wrong hostname: $custom_host1. Must be localhost:3050"
    down
    exit 1
fi

custom_host2=`curl -sS localhost:3050/host.html -H "Host: custom.com"`
if [[ $custom_host2 != "custom.com" ]]; then
    echo "Wrong hostname: $custom_host2. Must be custom.com"
    down
    exit 1
fi

# Test traffic splitter
default_host=`curl -sS localhost:3000/host.html`
if [[ $default_host != "localhost:3000" ]]; then
    echo "Wrong hostname: $default_host. Must be localhost:3000"
    down
    exit 1
fi

alternate_host=`curl -sS localhost:3000/sub/host.html`
if [[ $alternate_host != "localhost:3000" ]]; then
    echo "Wrong hostname: $alternate_host. Must be localhost:3000"
    down
    exit 1
fi

down