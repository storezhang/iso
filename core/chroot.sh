#!/usr/bin/sudo /bin/bash

# 嵌入日志
source core/log.sh

customize() {
    name=$1
    directory=$2
    commands=${*:2+1}

    log DEBUG 开始执行定制命令 "name=${name}, commands=${commands}"
    sudo chroot "${directory}" sh -c "$(for command in "${commands[@]}"; do ${command}; done)" || exit 1
    log INFO 定制命令成功 "name=${name}, commands=${commands}"
}
