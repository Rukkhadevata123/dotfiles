# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker

DESCRIPTION="Shading language that makes it easier to build and maintain large shader codebases"
HOMEPAGE="https://github.com/shader-slang/slang"
SRC_URI="https://github.com/shader-slang/slang/releases/download/v${PV}/slang-${PV}-linux-x86_64.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="
    dev-util/glslang
    !media-libs/shader-slang
"

QA_PREBUILT="
    opt/shader-slang-bin/bin/*
    opt/shader-slang-bin/lib/*
"

src_unpack() {
    unpack ${A}
}

src_install() {
    insinto /opt/shader-slang-bin
    doins -r bin lib include share

    # Install license
    dodir /opt/shader-slang-bin/share/licenses/shader-slang
    doins LICENSE
    
    # Create symlinks for binaries
    dodir /usr/bin
    for bin in slangc slangd; do
        dosym /opt/shader-slang-bin/bin/${bin} /usr/bin/${bin}
    done

    fperms +x /opt/shader-slang-bin/bin/slangc
    fperms +x /opt/shader-slang-bin/bin/slangd

    # Add library path
    cat <<-EOF > "${T}/99${PN}"
LDPATH="/opt/shader-slang-bin/lib"
EOF
    doenvd "${T}/99${PN}"
}

pkg_postinst() {
    elog "Shader Slang has been installed to /opt/shader-slang-bin"
    elog "Binaries are available in /usr/bin"
    elog "The library path has been added to the environment"
}