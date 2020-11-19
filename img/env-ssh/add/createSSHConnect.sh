#!/bin/bash
# createSSHConnect.sh "targetServerName"
# createSSHConnect.sh "targetServerIP"

sshpass -p '1234' ssh-copy-id -o StrictHostKeyChecking=no $1 > /dev/null 2>&1