EAPI=8

inherit meson gnome2-utils

DESCRIPTION="Yaru GNOME theme for Ubuntu (all components included)"
HOMEPAGE="https://github.com/ubuntu/yaru"
SRC_URI="https://github.com/ubuntu/yaru/archive/${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/yaru-${PV}"

LICENSE="GPL-3 CC-BY-SA-4.0"

SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	x11-themes/hicolor-icon-theme
	gnome-base/librsvg
	x11-libs/gtk+
	x11-libs/gdk-pixbuf
	x11-themes/gtk-engines-murrine
	gnome-base/gnome-shell
"

DEPEND="
	${RDEPEND}
	dev-build/meson
	dev-lang/sassc
	media-gfx/inkscape
"

src_configure() {
	meson_src_configure
}

src_install() {
	meson_src_install
}

pkg_postinst() {
    xdg_icon_cache_update
    gnome2_schemas_update
}

pkg_postrm() {
    xdg_icon_cache_update
    gnome2_schemas_update
}
