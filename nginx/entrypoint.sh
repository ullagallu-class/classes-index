#!/bin/sh
hostname -i > /usr/share/nginx/html/ip.txt
exec "$@"