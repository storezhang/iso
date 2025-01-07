#!/usr/bin/sudo /bin/bash

# 嵌入日志
source core/log.sh

install() {
  APPLICATION=$1
  log DEBUG "检查应用是否已安装" "application=${APPLICATION}"
  if dpkg -l | grep -qw "${APPLICATION}"; then
    log DEBUG "系统已经安装，继续执行" "application=${APPLICATION}"
  else
    log INFO "开始安装应用" "application=${APPLICATION}"
    sudo apt install -y "${APPLICATION}"
  fi
}
