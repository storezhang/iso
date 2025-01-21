#!/usr/bin/sudo /bin/bash

version="22.04.5 LTS"
arch=amd64
type=kubernetes
cleanup=false

# 嵌入日志
source core/log.sh

shorts="v:a:t:w:u:p:r:m:"
longs="version:arch:type:workspace:username:password:root-password-password:rp:mirror:"
args=$(getopt --longoptions ${longs} --options ${shorts} --alternative -- "$@")
eval set -- "$args"
while true; do
    value=${2#*=}
    case "$1" in
        -v|--version)
            version=${value}
            ;;
        -a|--arch)
            arch=${value}
            ;;
        -w|--workspace)
            workspace=${value}
            ;;
        -t|--type)
            type=${value}
            ;;
        -u|--username)
            username=${value}
            ;;
        -p|--password)
            password=${value}
            ;;
        -r|--rp|--root-password-password)
            root_password=${value}
            ;;
        -m|--mirror)
            mirror=${value}
            ;;
        -c|--cleanup)
            cleanup=${value}
            ;;
        --)
            shift
            break;;
    esac
    shift
done

log INFO "开始镜像定制"
case "${type}" in
    kubernetes)
        log INFO "开始定制Kubernetes镜像"
        source ubuntu/kubernetes.sh
        kubernetes "${arch}" "${version}" "${workspace}" "${root_password}" "${username}" "${password}" "${mirror}" "${cleanup}"
        ;;
    --)
        ;;
esac
