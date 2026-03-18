#!/bin/bash

####################################
# Author: Soham Sarkar
# Date: 18-03-2026
# Version: v1
# Purpose: Outputs Node Health (CPU, Memory, Disk)
####################################

set -e # exit on error
set -o pipefail

echo "--- Printing Disk Space ---"
df -h

echo "--- Printing Memory ---"
free -g

echo "--- Printing CPU ---"
nproc

# Using grep and awk to find specific process IDs
echo "--- Finding Amazon Related Processes ---"
ps -ef | grep "amazon" | awk '{print $2}'
