#!/usr/bin/sudo /bin/bash

# 嵌入日志
source core/log.sh
# 嵌入定制命令
source core/chroot.sh
# 嵌入安装应用
source ubuntu/install.sh
# 嵌入安装应用
source ubuntu/uninstall.sh

setup() {
    log INFO 安装镜像定制软件
    install squashfs-tools
    install genisoimage
    install isolinux
    install xorriso
    install debootstrap

    trap 'uninstall debootstrap' EXIT
    trap 'uninstall debootstrap' EXIT
    trap 'uninstall debootstrap' EXIT
    trap 'uninstall debootstrap' EXIT
    trap 'uninstall debootstrap' EXIT
}

kubernetes() {
  setup # 准备环境

  VERSION=${1:-24.10}
  ARCH=${2:-amd64}
  WORKSPACE="${3:-kubernetes}"

  ROOT_PASSWORD=${4}
  USERNAME=${5:-kubernetes}
  PASSWORD=${6}

  log INFO 检查工作区目录是否存在
  if [ ! -d "${WORKSPACE}" ]; then
    log INFO 创建工作区 "directory=${WORKSPACE}"
    mkdir --parents "${WORKSPACE}"
  fi

  log INFO 进入工作区 "directory=${WORKSPACE}"
  cd "${WORKSPACE}" || exit 1


  ROOT="ubuntu-${VERSION}-${ARCH}"
  PACKAGES="bash"
  PACKAGES="${PACKAGES},locales"

  log INFO 准备文件系统 "filepath=${ROOT}"
  sudo debootstrap --arch="${ARCH}" --include="${PACKAGES}" --variant=minbase jammy "${ROOT}" https://mirrors.ustc.edu.cn/ubuntu


  log INFO 开始定制系统 "root=${ROOT}"
  # sudo mount --options --rbind /dev "${ROOT}/dev"
  # sudo mount --options --rbind /proc "${ROOT}/proc"
  # sudo mount --options --rbind /sys "${ROOT}/sys"

  if [[ -n ${USERNAME} ]]; then # 创建用户
    GID=1000
    UID=1000
    customize "${ROOT}" 创建用户组 groupadd --gid ${UID} --system "${USERNAME}"
    customize "${ROOT}" 创建用户 useradd --uid ${UID} --gid ${GID} --system "${USERNAME}" --home-dir /home/"${USERNAME}"
  fi
  if [[ -n ${PASSWORD} ]]; then # 配置密码
    customize "${ROOT}" 设置用户密码 echo "${USERNAME}:${PASSWORD}" | chpasswd
  fi
  if [[ -n ${ROOT_PASSWORD} ]]; then # 配置根账号密码
    customize "${ROOT}" 设置根用户密码 echo "root:${ROOT_PASSWORD}" | chpasswd
  fi

  customize "${ROOT}" 更新系统 apt update
  customize "${ROOT}" 升级系统 apt upgrade
  customize "${ROOT}" 使用Bash环境 chsh --shell /usr/bin/bash
  customize "${ROOT}" 设置时间为重庆 apt install tzdata -y && cp /usr/share/zoneinfo/Asia/Chongqing /etc/localtime
  customize "${ROOT}" 安装SSH服务器并 apt install openssh-server -y
  customize "${ROOT}" 开启ROOT账号登录权限 echo "PermitRootLogin yes" > /etc/ssh/sshd_config.d/root
}
