#!/bin/bash
set -e

PACKAGES_FILE="/home/yoimiya/localrepo/dists/sid/main/binary-amd64/Packages"

# 运行nvchecker并获取所有包的最新版本
nvchecker --logger json -c /home/yoimiya/localrepo/nvchecker.toml | while read -r json_line; do
    # 只处理更新事件
    if echo "$json_line" | jq -e '.event == "updated"' >/dev/null 2>&1; then
        pkg=$(echo "$json_line" | jq -r '.name')
        new_ver=$(echo "$json_line" | jq -r '.version')
        
        # 直接从Packages文件获取当前版本
        old_ver=$(grep -A 10 "^Package: $pkg$" "$PACKAGES_FILE" | grep -m 1 "^Version:" | awk '{print $2}')
        
        # 输出结果
        if [ "$old_ver" = "$new_ver" ]; then
            echo "$pkg: up to date $old_ver"
        else
            echo "$pkg: update available $old_ver -> $new_ver"
        fi
    fi
done
