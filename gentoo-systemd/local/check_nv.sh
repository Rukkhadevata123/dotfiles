#!/bin/bash

set -e

# 遍历 overlay 下所有 nvchecker.toml 文件
find /var/db/repos/local -name nvchecker.toml | while read -r nvfile; do
    pkgdir=$(dirname "$nvfile")
    pkgname=$(basename "$pkgdir")
    # 运行 nvchecker，获取 updated to 后的版本号
     newver=$(nvchecker --logger json -c "$nvfile" 2>/dev/null | jq -r 'select(.event=="updated") | .version' | head -n1)
    # 获取本地 ebuild 的 PV
    ebuild=$(find "$pkgdir" -maxdepth 1 -name "${pkgname}-*.ebuild" | sort | tail -n1)
    if [[ -z "$ebuild" ]]; then
        echo "$pkgname: No ebuild found"
        continue
    fi
    curver=$(basename "$ebuild" | sed -E "s/^${pkgname}-([0-9][^\.]*\.[0-9\.]+)\.ebuild$/\1/")
    # 比较版本
    if [[ "$newver" == "$curver" ]]; then
        echo "$pkgname: Up to date (version $curver)"
    elif [[ -n "$newver" ]]; then
        echo "$pkgname: Update available ($curver -> $newver)"
    else
        echo "$pkgname: Could not detect upstream version"
    fi
done