# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

DESCRIPTION="Vulkan benchmark"
HOMEPAGE="https://github.com/vkmark/vkmark"
SRC_URI="https://github.com/vkmark/vkmark/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64"
IUSE="wayland X"

DEPEND="
	media-libs/assimp:=
	media-libs/glm
	dev-util/vulkan-headers
	X? (
		x11-libs/libxcb:=
		x11-libs/xcb-util-wm
	)
	wayland? (
		dev-libs/wayland
		dev-libs/wayland-protocols
	)
"
RDEPEND="
	media-libs/assimp:=	
	media-libs/vulkan-loader
	X? (
		x11-libs/libxcb:=
		x11-libs/xcb-util-wm
	)
	wayland? ( dev-libs/wayland )
"

PATCHES=(
    "${FILESDIR}/DispatchLoaderDynamic1.patch"
    "${FILESDIR}/DispatchLoaderDynamic2.patch"
)

src_configure() {
    local emesonargs=(
        $(meson_use wayland)
        $(meson_use X xcb)
        -Dkms=true
    )
    meson_src_configure
}
