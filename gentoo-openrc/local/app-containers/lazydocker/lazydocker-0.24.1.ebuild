# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="A simple terminal UI for docker and docker-compose, written in Go with the gocui library"
HOMEPAGE="https://github.com/jesseduffield/lazydocker"
SRC_URI="https://github.com/jesseduffield/lazydocker/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="dev-lang/go"

QA_PREBUILT="/usr/bin/lazydocker"

src_compile() {
    export CGO_CPPFLAGS="${CPPFLAGS}"
    export CGO_CFLAGS="${CFLAGS}"
    export CGO_CXXFLAGS="${CXXFLAGS}"
    export GOFLAGS="-buildmode=pie -trimpath -mod=readonly -modcacherw"

    ego build -mod=vendor -ldflags="-extldflags \"${LDFLAGS}\" -s -w -X main.version=${PV}" -o lazydocker main.go
}

src_install() {
    dobin lazydocker
    dodoc LICENSE
}