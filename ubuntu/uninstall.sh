#!/usr/bin/sudo /bin/bash

# 嵌入日志
source core/log.sh

uninstall() {
  APPLICATION=$1
  log DEBUG "检查应用是否已安装" "application=${APPLICATION}"
  if dpkg -l | grep -qw "${APPLICATION}"; then
    log DEBUG "系统已经安装，卸载" "application=${APPLICATION}"
  fi
}
