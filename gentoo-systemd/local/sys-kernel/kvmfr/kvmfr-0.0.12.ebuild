# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-mod-r1

MY_PV="B7"
DESCRIPTION="KVMFR kernel module for Looking Glass"
HOMEPAGE="https://github.com/gnif/LookingGlass"
SRC_URI="https://github.com/gnif/LookingGlass/archive/refs/tags/${MY_PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/LookingGlass-${MY_PV}/module"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

DOCS=(
    "../README.md"
)

src_compile() {
    local modlist=(
        kvmfr
    )
    local modargs=(
        KDIR="${KV_OUT_DIR}"
    )

    linux-mod-r1_src_compile
}

pkg_postinst() {
    linux-mod-r1_pkg_postinst

    elog "To load the KVMFR module with a specific memory size:"
    elog "  modprobe kvmfr static_size_mb=32"
    elog ""
    elog "To make the setting permanent, create /etc/modprobe.d/kvmfr.conf:"
    elog "  options kvmfr static_size_mb=32"
    elog ""
    elog "To auto-load the module at boot, create /etc/modules-load.d/kvmfr.conf:"
    elog "  kvmfr"
    elog ""
    elog "After successful loading, you should have /dev/kvmfr0 device."
}