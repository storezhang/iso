#!/usr/bin/sudo /bin/bash

version=22.10
arch=amd64
type=kubernetes

# 嵌入日志
source core/log.sh

shorts="v:a:t:w:u:p:r:"
longs="version:arch:type:workspace:username:password:root-password-password:rp:"
args=$(getopt --longoptions ${longs} --options ${shorts} --alternative -- "$@")
eval set -- "$args"
while true; do
  case "$1" in
    -v|--version)
      version=${2#*=}
      ;;
    -a|--arch)
      arch=${2#*=}
      ;;
    -w|--workspace)
      workspace=${2#*=}
      ;;
    -t|--type)
      type=${2#*=}
      ;;
    -u|--username)
      username=${2#*=}
      ;;
    -p|--password)
      password=${2#*=}
      ;;
    -r|--rp|--root-password-password)
      root_password=${2#*=}
      ;;
    -c|--cleanup)
      cleanup=${2#*=}
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
    kubernetes "${arch}" "${version}" "${workspace}" "${root_password}" "${username}" "${password}" "${cleanup}"
    ;;
  --)
    ;;
esac
