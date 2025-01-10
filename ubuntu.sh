#!/usr/bin/sudo /bin/bash

VERSION=24.10
ARCH=amd64
TYPE=kubernetes

# 嵌入日志
source core/log.sh

SHORTS="v:a:t:w:u:p:r:"
LONGS="version:arch:type:workspace:username:password:root-password:rp:"
ARGS=$(getopt --longoptions ${LONGS} --options ${SHORTS} --alternative -- "$@")
eval set -- "$ARGS"
while true; do
  case "$1" in
    -v|--version)
      VERSION=${2#*=}
      ;;
    -a|--arch)
      ARCH=${2#*=}
      ;;
    -w|--workspace)
      WORKSPACE=${2#*=}
      ;;
    -t|--type)
      TYPE=${2#*=}
      ;;
    -u|--username)
      USERNAME=${2#*=}
      ;;
    -p|--password)
      PASSWORD=${2#*=}
      ;;
    -r|--rp|--root-password)
      ROOT_PASSWORD=${2#*=}
      ;;
    -c|--cleanup)
      CLEANUP=${2#*=}
      ;;
    --)
      shift
      break;;
  esac
shift
done

log INFO "开始镜像定制"
case "${TYPE}" in
  kubernetes)
    log INFO "开始定制Kubernetes镜像"
    source ubuntu/kubernetes.sh
    kubernetes "${VERSION}" "${ARCH}" "${WORKSPACE}" "${ROOT_PASSWORD}" "${USERNAME}" "${PASSWORD}" "${CLEANUP}"
    ;;
  --)
    ;;
esac
