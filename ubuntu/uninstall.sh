#!/usr/bin/sudo /bin/bash

# 嵌入日志
source core/log.sh

uninstall() {
    message=$1
    applications=${*:2+1}

    uninstalls=()
    for application in ${applications}; do
        log DEBUG "检查应用是否已安装" "application=${application}"
        if dpkg -l | grep -qw "${application}"; then
            uninstalls+=("${application}")
        else
            log DEBUG "应用未安装" "application=${application}"
        fi
    done

    log DEBUG "开始移除应用" "message=${message}, applications=[${uninstalls[*]}]"
    sudo apt uninstall -y "$(for INSTALL in "${uninstalls[@]}"; do ${INSTALL}; done)" || exit 1
    log INFO "移除应用成功" "message=${message}, applications=[${uninstalls[*]}]"
}
