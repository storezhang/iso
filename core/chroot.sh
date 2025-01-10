#!/usr/bin/sudo /bin/bash

# 嵌入日志
source core/log.sh

customize() {
    DIRECTORY=$1
    NAME=$2
    COMMANDS=${*:2+1}

    log DEBUG 开始执行定制命令 "name=${NAME}, commands=${COMMANDS}"
    sudo chroot "${DIRECTORY}" "$(for COMMAND in "${COMMANDS[@]}"; do ${COMMAND}; done)" || exit 1
    log INFO 定制命令成功 "name=${NAME}, commands=${COMMANDS}"
}
