#!/usr/bin/sudo /bin/bash

# 嵌入日志
source core/log.sh

install() {
    message=$1
    applications=${*:2+1}

    installs=()
    for application in ${applications}; do
        log DEBUG "检查应用是否已安装" "application=${application}"
        if dpkg -l | grep -qw "${application}"; then
            log DEBUG "系统已经安装" "application=${application}"
        else
            installs+=("${application}")
        fi
    done

    log DEBUG "开始安装应用" "message=${message}, applications=[${installs[*]}]"
    sudo apt install -y "$(for INSTALL in "${installs[@]}"; do ${INSTALL}; done)" || exit 1
    log INFO "开始安装成功" "message=${message}, applications=[${installs[*]}]"
}
