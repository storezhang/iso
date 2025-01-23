#!/usr/bin/sudo /bin/bash

# 嵌入日志
source core/log.sh

codename() {
    version=$1
    version="${version//-/ }" # 中划线替换为空格
    version="${version//_/ }" # 下划线替换为空格
    version="${version^^}" # 转换为大写

    url="https://changelogs.ubuntu.com/meta-release"
    content=$(curl -s "${url}")
    while IFS= read -r line; do
        if [[ "${line}" == "Dist: "* ]]; then
            dist="${line#* }"
        fi

        if [[ "${line}" == *"Version: ${version}"* ]]; then
            echo -n "${dist}" # !不输出换行符，不然会干扰读取结果
            break
        fi
    done <<< "${content}"
}

# 用于测试
codename "$@"
