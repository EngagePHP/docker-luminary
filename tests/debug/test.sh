#!/usr/bin/env bash

dgoss run -p 80:80 -e "CACHE_DRIVER=array" -e "SESSION_DRIVER=cookie" -e "QUEUE_DRIVER=array" mcuyar/docker-luminary:debug