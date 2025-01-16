#!/usr/bin/sudo /bin/bash

# 嵌入日志
source core/log.sh
# 嵌入定制命令
source core/chroot.sh

before() { # 执行前的步骤
    # 嵌入安装应用
    source ubuntu/install.sh
    # 嵌入安装应用
    source ubuntu/uninstall.sh

    install 安装镜像定制软件 squashfs-tools genisoimage isolinux xorriso debootstrap
    trap 'source ubuntu/uninstall.sh uninstall 移除镜像定制软件 squashfs-tools genisoimage isolinux xorriso debootstrap' EXIT
}

check() { # 检查执行条件是否满足
    workspace=$1

    log INFO 检查工作区目录是否存在
    if [ ! -d "${workspace}" ]; then
        log INFO 创建工作区 "directory=${workspace}"
        mkdir --parents "${workspace}"
    fi
}

authentication() { # 处理认证信息
    basedir=$1
    root_password=$2
    username=$3
    password=$4
    cleanup=$5

    if [[ -n ${root_password} ]]; then # 配置根账号密码
        customize "${basedir}" 设置根用户密码 sh -c "echo root:${root_password} | chpasswd"
    fi

    if [[ -n ${username} ]]; then # 创建用户
        gid=1001
        uid=1001
        customize 创建组 "${basedir}" sudo groupadd --system --gid=${gid} "${username}"
        customize 创建用户 "${basedir}" sudo useradd --system --uid=${uid} --gid=${gid} "${username}" --home-dir="/home/${username}"
    fi

    if [[ -n ${password} ]]; then # 配置密码
        customize 设置用户密码 "${basedir}" sh -c "echo ${username}:${password} | chpasswd"
    fi
}

attach() { # 挂载
    name=$1
    from=$2
    to=$3

    log INFO 开始挂载文件 "from=${from}, to=${to}"
    sudo mount --options --rbind "${from}" "${to}"
    log INFO 挂载文件成功 "from=${from}, to=${to}"
    trap 'sudo unmount ${to}' EXIT
}

prepare() { # 准备执行环境
    source ubuntu/codename.sh

    arch=$1
    version=$2
    basedir=$3
    packages=$4
    mirror=${5:-https://mirrors.aliyun.com/ubuntu}

    name=$(codename "${version}")
    log INFO 准备文件系统 "filepath=${basedir}, arch=${arch}, version=${version}, name=${name}"
    if [ "${cleanup}" = true ]; then # 配置根账号密码
        trap 'sudo rm -rf ${basedir}' EXIT
    fi

    sudo debootstrap --arch="${arch}" --include="${packages}" --variant=minbase "${name}" "${basedir}" "${mirror}"

    # attach 设备 "/dev" "${basedir}/dev"
    # attach 进程 "/proc" "${basedir}/proc"
    # attach 系统 "/sys" "${basedir}/sys"
}

execute() { # 定制系统
    basedir=$1

    log INFO 开始定制系统 "root=${basedir}"
    customize 更新系统 "${basedir}" apt update
    customize 升级系统 "${basedir}" apt upgrade
    customize 使用Bash环境 "${basedir}" chsh --shell /usr/bin/bash
    customize 设置时间为重庆 "${basedir}" apt install tzdata -y && cp /usr/share/zoneinfo/Asia/Chongqing /etc/localtime
    customize 安装SSH服务器并 "${basedir}" apt install openssh-server -y
    customize 开启ROOT账号登录权限 "${basedir}" echo "PermitRootLogin yes" > /etc/ssh/sshd_config.d/root
}

kubernetes() { # 入口
    before # 准备执行环境

    workspace="${3:-kubernetes}"
    check "${workspace}"

    # 准备环境
    arch=${1:-amd64}
    version=${2:-24.10}
    basedir="${workspace}/ubuntu-${arch}-${version// /-}"
    mirror=$7
    cleanup=$8
    prepare "${arch}" "${version}" "${basedir}" "bash,locales" "${mirror}" "${cleanup}"

    # 处理用户
    root_password=${4}
    username=${5:-kubernetes}
    password=${6}
    authentication "${basedir}" "${root_password}" "${username}" "${password}"

    # 定制系统
    execute "${basedir}"
}
