#!/usr/bin/sudo /bin/bash

# 嵌入日志
source core/log.sh

install() {
    NAME=$1
    APPLICATIONS=${*:2+1}

    INSTALLS=()
    for APPLICATION in ${APPLICATIONS}; do
        log DEBUG "检查应用是否已安装" "application=${APPLICATION}"
        if dpkg -l | grep -qw "${APPLICATION}"; then
            log DEBUG "系统已经安装，继续执行" "application=${APPLICATION}"
        else
            INSTALLS+=("${APPLICATION}")
        fi
    done

    log DEBUG "开始安装应用" "name=${NAME}, applications=[${INSTALLS[*]}]"
    sudo apt install -y "$(for INSTALL in "${INSTALLS[@]}"; do ${INSTALL}; done)" || exit 1
    log INFO "开始安装成功" "name=${NAME}, applications=[${INSTALLS[*]}]"
}
