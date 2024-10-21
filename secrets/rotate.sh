#!/usr/bin/env bash

echo Updating vmess uuid...
cat /proc/sys/kernel/random/uuid | EDITOR=cat agenix -e vmess-uuid.age
