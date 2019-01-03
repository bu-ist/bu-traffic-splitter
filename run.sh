#!/bin/bash

# Set default value for DNS_RESOLVER to the first nameserver value found in /etc/resolv.conf
if [ "$DNS_RESOLVER" = 'auto' ]; then
  export DNS_RESOLVER=$(sed -n -e 's/^.*nameserver //p' < /etc/resolv.conf | head -n 1)
fi

if [ -z "$ALTERNATE_MASK" ]
then
  ALTERNATE_CONFIG=""
else
  if [ -z "$ALTERNATE_HOST" ]
  then
    ALTERNATE_CONFIG='  location ~ (ALTERNATE_MASK) {
    proxy_pass ALTERNATE_URL$request_uri;
  }'
  else
    ALTERNATE_CONFIG='  location ~ (ALTERNATE_MASK) {
    proxy_set_header    Host ALTERNATE_HOST;
    proxy_pass ALTERNATE_URL$request_uri;
  }'
    ALTERNATE_CONFIG=${ALTERNATE_CONFIG/ALTERNATE_HOST/$ALTERNATE_HOST}
  fi
  ALTERNATE_CONFIG=${ALTERNATE_CONFIG/ALTERNATE_MASK/$ALTERNATE_MASK}
  ALTERNATE_CONFIG=${ALTERNATE_CONFIG/ALTERNATE_URL/$ALTERNATE_URL}
fi
export ALTERNATE_CONFIG

if [ -z "$DEFAULT_URL" ]
then
  DEFAULT_CONFIG=""
  INTERCEPT_CONFIG=""
else
  if [ -z "$INTERCEPT_MASK" ]
  then
    INTERCEPT_CONFIG=""
    DEFAULT_CONFIG='  location / {
    proxy_pass DEFAULT_URL$request_uri;
  }'
    DEFAULT_CONFIG=${DEFAULT_CONFIG/DEFAULT_URL/$DEFAULT_URL}

  else
    DEFAULT_CONFIG='  location / {
    proxy_pass DEFAULT_URL$request_uri;
    sub_filter_once off;
    # sub_filter_types text/html;
    sub_filter "INTERCEPT_MASK" "$http_host/INTERCEPT_MASK";
  }'
    DEFAULT_CONFIG=${DEFAULT_CONFIG/DEFAULT_URL/$DEFAULT_URL}
    DEFAULT_CONFIG=${DEFAULT_CONFIG/INTERCEPT_MASK/$INTERCEPT_MASK}
    DEFAULT_CONFIG=${DEFAULT_CONFIG/INTERCEPT_MASK/$INTERCEPT_MASK}
    
    if [ -z "$ALTERNATE_REF" ]
    then
      INTERCEPT_CONFIG='  location ~ INTERCEPT_MASK(.*)$ {
    proxy_pass ALTERNATE_URL$1;
  }'
      INTERCEPT_CONFIG=${INTERCEPT_CONFIG/INTERCEPT_MASK/$INTERCEPT_MASK}
      INTERCEPT_CONFIG=${INTERCEPT_CONFIG/ALTERNATE_URL/$ALTERNATE_URL}
    else
      INTERCEPT_CONFIG='  location ~ INTERCEPT_MASK(.*)$ {
    proxy_pass $scheme://INTERCEPT_MASK$1;
    proxy_set_header Referer "http://ALTERNATE_REF";
  }'
      INTERCEPT_CONFIG=${INTERCEPT_CONFIG/INTERCEPT_MASK/$INTERCEPT_MASK}
      INTERCEPT_CONFIG=${INTERCEPT_CONFIG/INTERCEPT_MASK/$INTERCEPT_MASK}
      INTERCEPT_CONFIG=${INTERCEPT_CONFIG/ALTERNATE_REF/$ALTERNATE_REF}
    fi
  fi
fi
export INTERCEPT_CONFIG
export DEFAULT_CONFIG

# Specify which environment variables to substitute
vars_to_sub='$DNS_RESOLVER:$DNS_RESOLVER_TIMEOUT:$ALTERNATE_CONFIG:$DEFAULT_CONFIG:$INTERCEPT_CONFIG'

# Substitute environment variables
envsubst "$vars_to_sub" < /template/nginx-default.conf > /etc/nginx/conf.d/default.conf

if [ -z "$DEBUG" ]; then true; else
  cat /etc/nginx/conf.d/default.conf
fi

exec nginx -g "daemon off;"