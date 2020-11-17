#!/bin/bash

# 测试环境变量
export DOCKERENV=$(pwd)
export DOCKERENV_ENTRYPOINT=$DOCKERENV/entrypoint
export DOCKERENV_CMD=$DOCKERENV/cmd

sh entrypoint_default_run.sh
sh cmd_default_run.sh