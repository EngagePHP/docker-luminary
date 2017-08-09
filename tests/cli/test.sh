#!/usr/bin/env bash

dgoss run -e "CACHE_DRIVER=array" -e "SESSION_DRIVER=cookie" -e "QUEUE_DRIVER=array" --entrypoint /entrypoint/cli engageops/docker-luminary:test