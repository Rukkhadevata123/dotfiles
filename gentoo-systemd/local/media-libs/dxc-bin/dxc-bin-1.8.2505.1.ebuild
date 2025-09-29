# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker

DESCRIPTION="DirectXShaderCompiler (dxc) binary package for Linux"
DXC_DATE="2025_07_14"
HOMEPAGE="https://github.com/microsoft/DirectXShaderCompiler"
SRC_URI="https://github.com/microsoft/DirectXShaderCompiler/releases/download/v${PV}/linux_dxc_${DXC_DATE}.x86_64.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}"

LICENSE="LLVM MS"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="!media-libs/dxc"

QA_PREBUILT="
    opt/dxc-bin/bin/*
    opt/dxc-bin/lib/*
"

src_unpack() {
    unpack ${A}
}

src_install() {
    insinto /opt/dxc-bin
    doins -r bin lib include

    # Install licenses
    dodir /opt/dxc-bin/share/licenses/dxc-bin
    doins LICENSE-MS.txt LICENSE-LLVM.txt

    # Install ReleaseNotes
    dodoc ReleaseNotes.md

    # Create symlinks for binaries
    dodir /usr/bin
    for bin in dxc dxv dxv-3.7; do
        dosym /opt/dxc-bin/bin/${bin} /usr/bin/${bin}
    done

    # Add execute permissions
    fperms +x /opt/dxc-bin/bin/dxc
    fperms +x /opt/dxc-bin/bin/dxv
    fperms +x /opt/dxc-bin/bin/dxv-3.7

    # Add library path
    cat <<-EOF > "${T}/99${PN}"
LDPATH="/opt/dxc-bin/lib"
EOF
    doenvd "${T}/99${PN}"
}

pkg_postinst() {
    elog "DirectXShaderCompiler (dxc) has been installed to /opt/dxc-bin"
    elog "Binaries are available in /usr/bin"
    elog "The library path has been added to the environment"
    elog "See /opt/dxc-bin/share/licenses/dxc-bin for license files"
    elog "Release notes are installed as /usr/share/doc/${PF}/ReleaseNotes.md"
}