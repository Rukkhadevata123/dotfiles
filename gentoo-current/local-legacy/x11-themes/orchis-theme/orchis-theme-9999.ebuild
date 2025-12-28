EAPI=8

DESCRIPTION="Orchis GTK theme (All variants included)"
HOMEPAGE="https://github.com/vinceliuice/Orchis-theme"
SRC_URI="
    https://github.com/vinceliuice/Orchis-theme/raw/master/release/Orchis.tar.xz
    https://github.com/vinceliuice/Orchis-theme/raw/master/release/Orchis-Green.tar.xz
    https://github.com/vinceliuice/Orchis-theme/raw/master/release/Orchis-Grey.tar.xz
    https://github.com/vinceliuice/Orchis-theme/raw/master/release/Orchis-Orange.tar.xz
    https://github.com/vinceliuice/Orchis-theme/raw/master/release/Orchis-Pink.tar.xz
    https://github.com/vinceliuice/Orchis-theme/raw/master/release/Orchis-Purple.tar.xz
    https://github.com/vinceliuice/Orchis-theme/raw/master/release/Orchis-Red.tar.xz
    https://github.com/vinceliuice/Orchis-theme/raw/master/release/Orchis-Teal.tar.xz
    https://github.com/vinceliuice/Orchis-theme/raw/master/release/Orchis-Yellow.tar.xz
"
S="${WORKDIR}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

src_install() {
    insinto /usr/share/themes
    doins -r "${WORKDIR}"/*
}