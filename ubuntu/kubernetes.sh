#!/usr/bin/sudo /bin/bash

# 嵌入日志
source core/log.sh
# 嵌入定制命令
source core/chroot.sh
# 嵌入安装应用
source ubuntu/install.sh

kubernetes() {
  log INFO 安装镜像定制软件
  install squashfs-tools
  install genisoimage
  install isolinux
  install xorriso
  install debootstrap

  VERSION=${1:-24.10}
  ARCH=${2:-amd64}
  WORKSPACE="${3:-kubernetes}"

  log INFO 检查工作区目录是否存在
  if [ ! -f "${WORKSPACE}" ]; then
    log INFO 创建工作区 "directory=${WORKSPACE}"
    mkdir -p "${WORKSPACE}"
  fi

  log INFO 进入工作区 "directory=${WORKSPACE}"
  cd "${WORKSPACE}" || exit 1


  ROOT="ubuntu-${VERSION}-${ARCH}"
  PACKAGES="bash"
  PACKAGES="${PACKAGES},locales"
  PACKAGES="${PACKAGES},openssh-server"

  log INFO 准备文件系统 "filepath=${ROOT}"
  sudo debootstrap --arch="${ARCH}" --include="${PACKAGES}" --variant=minbase jammy "${ROOT}" https://mirrors.ustc.edu.cn/ubuntu


  log INFO 开始定制系统 "root=${ROOT}"
  customize "${ROOT}" 更新系统 apt update
  customize "${ROOT}" 升级系统 apt upgrade
  customize "${ROOT}" 升级系统 apt upgrade
  customize "${ROOT}" 升级系统 apt upgrade
}
