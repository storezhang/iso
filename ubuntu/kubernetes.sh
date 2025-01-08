#!/usr/bin/sudo /bin/bash

# 嵌入日志
source core/log.sh
# 嵌入安装应用
source ubuntu/install.sh

kubernetes() {
  log INFO 安装镜像定制软件
  install squashfs-tools
  install genisoimage
  install isolinux
  install xorriso

  VERSION=${1:-24.10}
  ARCH=${2:-amd64}
  WORKSPACE="${3:-kubernetes}"

  log INFO 检查工作区目录是否存在
  if [ ! -f "${WORKSPACE}" ]; then
    log INFO 创建工作区 "directory=${WORKSPACE}"
    mkdir -p "${WORKSPACE}"
  fi

  log INFO "进入工作区" "directory=${WORKSPACE}"
  cd "${WORKSPACE}" || exit 1

  FILENAME="ubuntu-${VERSION}-live-server-${ARCH}.iso"
  log INFO "检查本地文件是否存在" "file=${FILENAME}"
  if [ ! -f "${FILENAME}" ]; then
    log WARN "镜像文件不存在" "filename=${FILENAME}"
    URL="https://mirror.nyist.edu.cn/ubuntu-releases/${VERSION}/${FILENAME}"
    log DEBUG "下载镜像文件" "filename=${FILENAME}, url=${URL}"
    wget --output-document="${FILENAME}" "${URL}"
  fi

  TARGET=$(basename "${FILENAME}" .iso)
  if [ ! -f "${TARGET}" ]; then
    log WARN "镜像挂载点不存在，创建挂载点" "target=${TARGET}"
    mkdir --parents "${TARGET}"
  fi

  log INFO 挂载系统镜像 "filename=${FILENAME}, target=${TARGET}"
  sudo mount --options loop "${FILENAME}" "${TARGET}"

  LIVE_CD="${TARGET}-live-cd"
  log INFO 复制镜像内容 "from=${TARGET}, to=${LIVE_CD}"
  sudo cp -rT "${TARGET}" "${LIVE_CD}"

  FS="${TARGET}-system"
  log INFO 解压文件系统 "directory=${FS}"
  sudo unsquashfs -d "${FS}" "${LIVE_CD}/casper/ubuntu-server-minimal.ubuntu-server.squashfs"

  log INFO 切换上下文到文件系统 "directory=${FS}"
  log INFO 创建命令行环境 "directories=[bin, lib, lib64]"
  sudo cp /bin/bash "${FS}/bin/bash"
  sudo chroot "${FS}"


  log WARN 开始定制系统 "system=${FS}"
  log INFO 更新系统 "operation=update"
  sudo apt update -y
  log INFO 更新系统 "operation=upgrade"
  sudo apt upgrade -y
}
