#!/usr/bin/env bash
set -euo pipefail

# Run after building the image. Arguments override the default GUI command.
image="${OCCT_DEV_IMAGE:-localhost/arch-occt:8.0.1}"
runtime_directory="${XDG_RUNTIME_DIR:?Run this script in your desktop session}"
display_name="${WAYLAND_DISPLAY:?WAYLAND_DISPLAY is not set}"
case "$display_name" in
    /*) wayland_socket="$display_name" ;;
    *) wayland_socket="$runtime_directory/$display_name" ;;
esac

if [[ ! -S "$wayland_socket" ]]; then
    printf 'Wayland socket does not exist: %s\n' "$wayland_socket" >&2
    exit 1
fi

if [[ $# -eq 0 ]]; then
    set -- imgui-sdl3-vulkan-demo
fi

# Match the existing LNNI NVIDIA/CDI setup; force SDL to use native Wayland.
exec podman run --rm -it \
    --network=none \
    --gpus=all \
    --security-opt=label=disable \
    --env NVIDIA_DRIVER_CAPABILITIES=graphics,display,utility \
    --env XDG_RUNTIME_DIR=/tmp/xdg-runtime \
    --env WAYLAND_DISPLAY=wayland-0 \
    --env SDL_VIDEODRIVER=wayland \
    --env VK_INSTANCE_LAYERS=VK_LAYER_KHRONOS_validation \
    --mount "type=bind,source=$wayland_socket,target=/tmp/xdg-runtime/wayland-0" \
    "$image" "$@"
