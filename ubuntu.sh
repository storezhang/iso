#!/usr/bin/sudo /bin/bash

VERSION=24.10
ARCH=amd64
WORKSPACE=
TYPE=kubernetes

# 嵌入日志
source core/log.sh

options=$(getopt -l "version:arch:type:workspace" -o "v:a:t:w:" -a -- "$@")
eval set -- "$options"

while true; do
  case "$1" in
    -v|--version)
      VERSION=$OPTARG
      ;;
    -a|--arch)
      ARCH=$OPTARG
      ;;
    -w|--workspace)
      WORKSPACE=$OPTARG
      ;;
    -t|--type)
      TYPE=$OPTARG
      ;;
    --)
      shift
      break;;
  esac
shift
done

log INFO "安装镜像定制软件"
case "${TYPE}" in
  kubernetes)
    log INFO "开始定制Kubernetes镜像"
    source ubuntu/kubernetes.sh
    kubernetes "${VERSION}" "${ARCH}" "${WORKSPACE}"
    ;;
  --)
    ;;
esac
