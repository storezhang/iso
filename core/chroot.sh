#!/usr/bin/sudo /bin/bash

# 嵌入日志
source core/log.sh

customize() {
  DIRECTORY=$1
  NAME=$2
  COMMAND=${*:2+1}

  log DEBUG 开始执行定制命令 "name=${NAME}, command=${COMMAND}"
  sudo chroot "${DIRECTORY}" ${COMMAND} || exit 1
  log INFO 定制命令成功 "name=${NAME}, command=${COMMAND}"
}
