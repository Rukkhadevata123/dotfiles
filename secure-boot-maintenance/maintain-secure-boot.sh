#!/bin/bash
set -Eeuo pipefail

# ---- User-maintainable configuration -------------------------------------
MOK_DIR=/etc/ssl/mok
MOK_PRIVATE_KEY="$MOK_DIR/MOK.priv"
MOK_CERT_DER="$MOK_DIR/MOK.der"
MOK_CERT_PEM="$MOK_DIR/MOK.pem"
EXPECTED_SIGNER='Local Secure Boot MOK'

BOOT_DIR=/boot
DKMS_MODULE=nvidia
DKMS_CONFIG=/etc/dkms/framework.conf.d/local-mok.conf
NVIDIA_MODULES=(nvidia nvidia_drm nvidia_modeset nvidia_uvm nvidia_peermem)

# Include administrative commands when sudo supplies a minimal PATH.
PATH=/usr/sbin:/usr/bin:/sbin:/bin
export PATH

# ---- Runtime state --------------------------------------------------------
declare -a XANMOD_KERNELS=()
declare -a DKMS_VERSIONS=()
declare -a DKMS_KERNELS=()
declare -a KERNEL_CHANGED=()
declare -a KERNEL_UNCHANGED=()
declare -a DKMS_CHANGED=()
declare -a DKMS_UNCHANGED=()
declare -a INITRAMFS_REBUILT=()
declare -a SIGNED_TEMP_FILES=()

WORK_DIR=''
EXPECTED_SIG_KEY=''
MOK_DIRECTORY_CREATED=false
DKMS_CONFIG_CHANGED=false
GRUB_UPDATED=false
DRACUT_UPDATED=false
UNSIGNED_REMOVED=0

die() {
    printf '错误：%s\n' "$*" >&2
    exit 1
}

on_error() {
    local rc=$1 line=$2 command=$3
    printf '错误：第 %s 行命令失败（退出码 %s）：%s\n' \
        "$line" "$rc" "$command" >&2
    exit "$rc"
}

cleanup() {
    local file
    for file in "${SIGNED_TEMP_FILES[@]}"; do
        if [[ -e "$file" ]]; then
            rm -f -- "$file"
        fi
    done
    if [[ -n "$WORK_DIR" && -d "$WORK_DIR" ]]; then
        rm -rf -- "$WORK_DIR"
    fi
}

trap 'on_error "$?" "$LINENO" "$BASH_COMMAND"' ERR
trap cleanup EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

require_root_and_commands() {
    if (( EUID != 0 )); then
        die "请使用 sudo 运行此脚本。"
    fi

    local -a required=(
        awk basename chmod chown cmp cp depmod dkms dracut find grep install
        mktemp mokutil modinfo mv openssl rm sbsign sbverify sed sha256sum
        sort stat uname update-grub
    )
    local -a missing=()
    local command_name

    for command_name in "${required[@]}"; do
        if ! command -v "$command_name" >/dev/null 2>&1; then
            missing+=("$command_name")
        fi
    done

    if (( ${#missing[@]} > 0 )); then
        printf '错误：缺少以下必需命令：%s\n' "${missing[*]}" >&2
        printf '请先安装对应软件包；尚未对系统进行任何修改。\n' >&2
        exit 127
    fi
}

ensure_mok_directory_and_keys() {
    local generated_key="$WORK_DIR/MOK.priv"
    local generated_der="$WORK_DIR/MOK.der"
    local generated_pem="$WORK_DIR/MOK.pem"

    if [[ -d "$MOK_DIR" ]]; then
        printf 'MOK 目录已存在，跳过密钥生成：%s\n' "$MOK_DIR"
        return 0
    fi
    if [[ -e "$MOK_DIR" ]]; then
        die "$MOK_DIR 已存在但不是目录，拒绝覆盖。"
    fi

    printf 'MOK 目录不存在，正在生成本地 Secure Boot 密钥……\n'
    openssl req -new -x509 -newkey rsa:2048 \
        -keyout "$generated_key" \
        -outform DER -out "$generated_der" \
        -nodes -days 36500 \
        -subj "/CN=$EXPECTED_SIGNER/"
    openssl x509 -inform DER -in "$generated_der" -out "$generated_pem"

    # Generate everything first, then install it so a failed openssl command
    # cannot leave a partially populated default directory.
    install -d -o root -g root -m 0755 "$MOK_DIR"
    install -o root -g root -m 0600 "$generated_key" "$MOK_PRIVATE_KEY"
    install -o root -g root -m 0644 "$generated_der" "$MOK_CERT_DER"
    install -o root -g root -m 0644 "$generated_pem" "$MOK_CERT_PEM"
    MOK_DIRECTORY_CREATED=true
    printf '已创建 MOK 密钥目录：%s\n' "$MOK_DIR"
}

validate_mok_material() {
    local file der_hash pem_hash cert_key_hash private_key_hash
    local mok_status serial_hex

    for file in "$MOK_PRIVATE_KEY" "$MOK_CERT_DER" "$MOK_CERT_PEM"; do
        [[ -f "$file" ]] || die "缺少 MOK 文件：$file"
    done

    der_hash=$(sha256sum "$MOK_CERT_DER" | awk '{print $1}')
    pem_hash=$(openssl x509 -in "$MOK_CERT_PEM" -outform DER \
        | sha256sum | awk '{print $1}')
    [[ "$der_hash" == "$pem_hash" ]] || die 'MOK.pem 与 MOK.der 不匹配。'

    cert_key_hash=$(openssl x509 -in "$MOK_CERT_PEM" -pubkey -noout \
        | openssl pkey -pubin -outform DER \
        | sha256sum | awk '{print $1}')
    private_key_hash=$(openssl pkey -in "$MOK_PRIVATE_KEY" -pubout -outform DER \
        | sha256sum | awk '{print $1}')
    [[ "$cert_key_hash" == "$private_key_hash" ]] \
        || die 'MOK 私钥与证书不匹配。'

    mok_status=$(LC_ALL=C mokutil --test-key "$MOK_CERT_DER" 2>&1 || true)
    if [[ "$mok_status" != *'is already enrolled'* ]]; then
        if [[ "$MOK_DIRECTORY_CREATED" == true ]]; then
            printf '\n新 MOK 已生成，但尚未注册。请执行：\n' >&2
            printf '  sudo mokutil --import %s\n' "$MOK_CERT_DER" >&2
            printf '然后重启，在 MOK Manager 中完成 enroll，再重新运行本脚本。\n' >&2
            exit 2
        fi
        die "MOK.der 未显示为已注册：$mok_status"
    fi

    serial_hex=$(openssl x509 -in "$MOK_CERT_PEM" -noout -serial \
        | sed 's/^serial=//')
    [[ -n "$serial_hex" ]] || die '无法读取 MOK 证书序列号。'
    if (( ${#serial_hex} % 2 != 0 )); then
        serial_hex="0$serial_hex"
    fi
    EXPECTED_SIG_KEY=$(printf '%s' "${serial_hex^^}" \
        | sed 's/../&:/g; s/:$//')
}

discover_targets() {
    local kernel dkms_status line version arch

    while IFS= read -r -d '' kernel; do
        case "$kernel" in
            *.signed|*.unsigned|*.old|*.bak|*.backup) continue ;;
        esac
        XANMOD_KERNELS+=("$kernel")
    done < <(find "$BOOT_DIR" -maxdepth 1 -type f \
        -name 'vmlinuz-*-xanmod*' -print0 | sort -z)

    (( ${#XANMOD_KERNELS[@]} > 0 )) \
        || die "在 $BOOT_DIR 中没有找到 XanMod vmlinuz。"

    dkms_status=$(dkms status -m "$DKMS_MODULE")
    while IFS= read -r line; do
        if [[ "$line" =~ ^${DKMS_MODULE}/([^,]+),[[:space:]]*([^,]+),[[:space:]]*([^:]+):[[:space:]]*installed$ ]]; then
            version=${BASH_REMATCH[1]}
            kernel=${BASH_REMATCH[2]}
            arch=${BASH_REMATCH[3]}
            [[ -n "$arch" ]] || continue
            DKMS_VERSIONS+=("$version")
            DKMS_KERNELS+=("$kernel")
        fi
    done <<< "$dkms_status"

    (( ${#DKMS_KERNELS[@]} > 0 )) \
        || die "没有找到状态为 installed 的 $DKMS_MODULE DKMS 模块。"
}

configure_dkms_signing() {
    local desired="$WORK_DIR/local-mok.conf"

    printf '%s\n' \
        '# Managed by maintain-secure-boot.sh.' \
        '# Use the locally enrolled MOK for all future DKMS module signing.' \
        'try_sign_modules="true"' > "$desired"
    printf 'mok_signing_key="%s"\n' "$MOK_PRIVATE_KEY" >> "$desired"
    printf 'mok_certificate="%s"\n' "$MOK_CERT_DER" >> "$desired"

    if [[ -f "$DKMS_CONFIG" ]] && cmp -s "$desired" "$DKMS_CONFIG"; then
        DKMS_CONFIG_CHANGED=false
    else
        install -o root -g root -m 0644 "$desired" "$DKMS_CONFIG"
        DKMS_CONFIG_CHANGED=true
    fi
}

kernel_signature_valid() {
    local kernel=$1
    sbverify --cert "$MOK_CERT_PEM" "$kernel" >/dev/null 2>&1
}

sign_xanmod_kernels() {
    local kernel signed backup

    for kernel in "${XANMOD_KERNELS[@]}"; do
        if kernel_signature_valid "$kernel"; then
            KERNEL_UNCHANGED+=("$kernel")
            printf '内核已使用目标 MOK 签名，跳过：%s\n' "$kernel"
            continue
        fi

        signed="${kernel}.signed"
        backup="${kernel}.unsigned"
        SIGNED_TEMP_FILES+=("$signed")

        rm -f -- "$signed"
        printf '正在签名 XanMod 内核：%s\n' "$kernel"
        sbsign --key "$MOK_PRIVATE_KEY" --cert "$MOK_CERT_PEM" \
            --output "$signed" "$kernel"
        kernel_signature_valid "$signed" \
            || die "临时签名文件验证失败：$signed"

        # This backup remains available until the complete final verification.
        cp -a -- "$kernel" "$backup"
        chown --reference="$kernel" "$signed"
        chmod --reference="$kernel" "$signed"
        mv -f -- "$signed" "$kernel"
        kernel_signature_valid "$kernel" \
            || die "替换后的内核签名验证失败：$kernel"
        KERNEL_CHANGED+=("$kernel")
    done

    if (( ${#KERNEL_CHANGED[@]} > 0 )); then
        update-grub
        GRUB_UPDATED=true
    fi
}

nvidia_module_signature_valid() {
    local kernel=$1 module=$2 signer sig_key
    signer=$(modinfo -k "$kernel" -F signer "$module" 2>/dev/null || true)
    sig_key=$(modinfo -k "$kernel" -F sig_key "$module" 2>/dev/null || true)
    [[ "$signer" == "$EXPECTED_SIGNER" && "$sig_key" == "$EXPECTED_SIG_KEY" ]]
}

nvidia_kernel_signatures_valid() {
    local kernel=$1 module
    for module in "${NVIDIA_MODULES[@]}"; do
        nvidia_module_signature_valid "$kernel" "$module" || return 1
    done
}

sign_nvidia_dkms() {
    local index version kernel module

    for index in "${!DKMS_KERNELS[@]}"; do
        version=${DKMS_VERSIONS[$index]}
        kernel=${DKMS_KERNELS[$index]}

        if nvidia_kernel_signatures_valid "$kernel"; then
            DKMS_UNCHANGED+=("$kernel")
            printf 'NVIDIA 模块已使用目标 MOK 签名，跳过：%s\n' "$kernel"
            continue
        fi

        printf '正在为 %s 强制重建并签名 %s/%s……\n' \
            "$kernel" "$DKMS_MODULE" "$version"
        dkms build --force -m "$DKMS_MODULE" -v "$version" -k "$kernel"
        dkms install --force -m "$DKMS_MODULE" -v "$version" -k "$kernel"
        depmod "$kernel"

        for module in "${NVIDIA_MODULES[@]}"; do
            nvidia_module_signature_valid "$kernel" "$module" \
                || die "$kernel 的 $module 签名验证失败。"
        done
        DKMS_CHANGED+=("$kernel")
    done
}

initramfs_is_stale() {
    local kernel=$1 initrd="$BOOT_DIR/initrd.img-$1" module module_file

    [[ -s "$initrd" ]] || return 0
    for module in "${NVIDIA_MODULES[@]}"; do
        module_file=$(modinfo -k "$kernel" -F filename "$module" 2>/dev/null || true)
        [[ -n "$module_file" && -f "$module_file" ]] || return 0
        [[ "$module_file" -nt "$initrd" ]] && return 0
    done
    return 1
}

array_contains() {
    local needle=$1 item
    shift
    for item in "$@"; do
        [[ "$item" == "$needle" ]] && return 0
    done
    return 1
}

rebuild_initramfs_if_needed() {
    local running_kernel kernel needs_rebuild
    local -a rebuild_kernels=()

    for kernel in "${DKMS_KERNELS[@]}"; do
        needs_rebuild=false
        if array_contains "$kernel" "${DKMS_CHANGED[@]}"; then
            needs_rebuild=true
        elif initramfs_is_stale "$kernel"; then
            needs_rebuild=true
        fi
        if [[ "$needs_rebuild" == true ]] \
            && ! array_contains "$kernel" "${rebuild_kernels[@]}"; then
            rebuild_kernels+=("$kernel")
        fi
    done

    (( ${#rebuild_kernels[@]} > 0 )) || return 0
    running_kernel=$(uname -r)

    for kernel in "${rebuild_kernels[@]}"; do
        if [[ "$kernel" != "$running_kernel" ]]; then
            printf '正在重建非当前内核 %s 的 initramfs……\n' "$kernel"
            dracut --no-hostonly --force "$BOOT_DIR/initrd.img-$kernel" "$kernel"
            INITRAMFS_REBUILT+=("$kernel")
        fi
    done

    # Keep the requested command as the final initramfs rebuild operation.
    printf '正在重建当前内核 %s 的 initramfs……\n' "$running_kernel"
    dracut --no-hostonly --force
    INITRAMFS_REBUILT+=("$running_kernel")
    DRACUT_UPDATED=true
}

verify_everything() {
    local kernel module initrd grub_config="$BOOT_DIR/grub/grub.cfg"
    local mok_status

    mok_status=$(LC_ALL=C mokutil --test-key "$MOK_CERT_DER" 2>&1 || true)
    [[ "$mok_status" == *'is already enrolled'* ]] \
        || die '最终验证失败：MOK.der 不再显示为已注册。'

    for kernel in "${XANMOD_KERNELS[@]}"; do
        kernel_signature_valid "$kernel" \
            || die "最终验证失败：内核签名无效：$kernel"
        if [[ -f "$grub_config" ]]; then
            grep -Fq "$(basename "$kernel")" "$grub_config" \
                || die "最终验证失败：GRUB 配置未引用 $(basename "$kernel")。"
        else
            die "最终验证失败：找不到 $grub_config。"
        fi
    done

    for kernel in "${DKMS_KERNELS[@]}"; do
        for module in "${NVIDIA_MODULES[@]}"; do
            nvidia_module_signature_valid "$kernel" "$module" \
                || die "最终验证失败：$kernel/$module 签名不匹配。"
        done
        initrd="$BOOT_DIR/initrd.img-$kernel"
        [[ -s "$initrd" ]] \
            || die "最终验证失败：initramfs 不存在或为空：$initrd"
    done
}

remove_unsigned_backups() {
    local kernel backup
    for kernel in "${XANMOD_KERNELS[@]}"; do
        backup="${kernel}.unsigned"
        if [[ -e "$backup" ]]; then
            rm -f -- "$backup"
            UNSIGNED_REMOVED=$((UNSIGNED_REMOVED + 1))
        fi
    done
}

join_or_none() {
    if (( $# == 0 )); then
        printf '无'
    else
        local IFS=', '
        printf '%s' "$*"
    fi
}

print_summary() {
    local config_status grub_status dracut_status mok_directory_status kernel

    if [[ "$MOK_DIRECTORY_CREATED" == true ]]; then
        mok_directory_status='本次创建'
    else
        mok_directory_status='已存在，跳过生成'
    fi
    if [[ "$DKMS_CONFIG_CHANGED" == true ]]; then
        config_status='已更新'
    else
        config_status='已符合，未改动'
    fi
    if [[ "$GRUB_UPDATED" == true ]]; then
        grub_status='已运行 update-grub'
    else
        grub_status='内核未变化，已验证现有 GRUB 配置'
    fi
    if [[ "$DRACUT_UPDATED" == true ]]; then
        dracut_status='已重建（最后执行 dracut --no-hostonly --force）'
    else
        dracut_status='DKMS 模块未变化，未重复重建'
    fi

    printf '\n===== Secure Boot 最终验证汇总 =====\n'
    printf 'MOK 目录            %s（%s）\n' "$mok_directory_status" "$MOK_DIR"
    printf 'MOK                 已注册；签名者：%s\n' "$EXPECTED_SIGNER"
    printf 'MOK 模块签名序列号  %s\n' "$EXPECTED_SIG_KEY"
    printf 'DKMS 配置           %s（%s）\n' "$config_status" "$DKMS_CONFIG"
    printf 'XanMod 内核         %s 个，全部签名验证通过\n' "${#XANMOD_KERNELS[@]}"
    for kernel in "${XANMOD_KERNELS[@]}"; do
        printf '  - %s\n' "$(basename "$kernel")"
    done
    printf '新签名内核          %s\n' "$(join_or_none "${KERNEL_CHANGED[@]}")"
    printf '已合格内核          %s\n' "$(join_or_none "${KERNEL_UNCHANGED[@]}")"
    printf 'NVIDIA DKMS 内核    %s 个，五个模块均验证通过\n' "${#DKMS_KERNELS[@]}"
    printf '重签 DKMS 内核      %s\n' "$(join_or_none "${DKMS_CHANGED[@]}")"
    printf '已合格 DKMS 内核    %s\n' "$(join_or_none "${DKMS_UNCHANGED[@]}")"
    printf 'GRUB                %s\n' "$grub_status"
    printf 'initramfs           %s\n' "$dracut_status"
    printf '重建 initramfs      %s\n' "$(join_or_none "${INITRAMFS_REBUILT[@]}")"
    printf '.unsigned 清理      已删除 %s 个\n' "$UNSIGNED_REMOVED"
    printf '最终结果            全部验证通过\n'
}

main() {
    require_root_and_commands
    WORK_DIR=$(mktemp -d)
    ensure_mok_directory_and_keys
    validate_mok_material
    discover_targets

    configure_dkms_signing
    sign_xanmod_kernels
    sign_nvidia_dkms
    rebuild_initramfs_if_needed
    verify_everything
    remove_unsigned_backups
    print_summary
}

main "$@"
