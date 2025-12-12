# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
GST_ORG_MODULE=gst-plugins-bad

DESCRIPTION="NVIDIA GPU codec plugin for GStreamer"
HOMEPAGE="https://gstreamer.freedesktop.org/"

inherit gstreamer-meson

KEYWORDS="amd64"

RDEPEND="
    x11-drivers/nvidia-drivers
    dev-util/nvidia-cuda-toolkit
"

DEPEND="${RDEPEND}"

multilib_src_configure() {
    local emesonargs=(
        -Dnvcodec=enabled
    )
    gstreamer_multilib_src_configure
}