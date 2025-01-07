#!/usr/bin/sudo /bin/bash

# 嵌入日志
source core/log.sh

install() {
  APP=$1
  log DEBUG "检查应用是否已安装" "application=${APP}"
  if dpkg -l | grep -qw "${APP}"; then
    log DEBUG "系统已经安装，继续执行" "application=${APP}"
  else
    log INFO "开始安装应用" "application=${APP}"
    apt install -y "${APP}"
  fi
}
