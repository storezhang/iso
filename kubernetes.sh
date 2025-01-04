#!/bin/bash

VERSION=24.10
ARCH=amd64
WORKSAPCE=kubernetes

options=$(getopt -l "version:arch:workspace:" -o "v:a:w:" -a -- "$@")
eval set -- "$options"

while true; do
    case "$1" in
        -v|--version)
            VERSION=$OPTARG
            ;;
        -a|--arch)
            DNS=$OPTARG
            ;;
        -w|--workspace)
            WORKSAPCE=$OPTARG
            ;;
        --)
            shift
            break;;
    esac
shift
done

FILENAME="ubuntu-${VERSION}-live-server-${ARCH}.iso"
# 检查本地文件是否存在
if [ ! -f "${FILENAME}" ]; then
    URL="https://mirror.nyist.edu.cn/ubuntu-releases/${VERSION}/${NAME}"
    # 下载文件
    wget --output-document="${FILENAME}" "${URL}"
fi

# 解压文件


