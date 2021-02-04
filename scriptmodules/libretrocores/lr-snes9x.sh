#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-snes9x"
rp_module_desc="Super Nintendo emu - Snes9x (current) port for libretro"
rp_module_help="ROM Extensions: .bin .smc .sfc .fig .swc .mgd .zip\n\nCopy your SNES roms to $romdir/snes"
rp_module_licence="NONCOM https://raw.githubusercontent.com/snes9xgit/snes9x/master/LICENSE"
rp_module_section="opt armv8=main x86=main"

function sources_lr-snes9x() {
    gitPullOrClone "$md_build" https://github.com/snes9xgit/snes9x.git

    # Improves performance on Kirby's Dream Land 3 by almost 10% on a RPi3B+
    # inside the windy room with Nago and Rick on 1-1
    applyPatch "$md_data/0001-Revert-Merge-pull-request-523-from-yoffy-unmacro-til.patch"

    # Adds a 2.68 MHz underclock option
    # Reported to improve performance on Kirby's Dream Land 3 and
    # Super Mario RPG, and fix a black screen on Tenshi no Uta
    applyPatch "$md_data/0002-libretro-add-2.68-MHz-underclock-option.patch"
}

function build_lr-snes9x() {
    local params=()
    isPlatform "arm" && params+=(platform="armv")

    cd libretro
    make "${params[@]}" clean
    # temporarily disable distcc due to segfaults with cross compiler and lto
    DISTCC_HOSTS="" make "${params[@]}"
    md_ret_require="$md_build/libretro/snes9x_libretro.so"
}

function install_lr-snes9x() {
    md_ret_files=(
        'libretro/snes9x_libretro.so'
        'docs'
    )
}

function configure_lr-snes9x() {
    mkRomDir "snes"
    ensureSystemretroconfig "snes"

    local def=0
    ! isPlatform "armv6" && ! isPlatform "armv7" && def=1
    addEmulator $def "$md_id" "snes" "$md_inst/snes9x_libretro.so"
    addSystem "snes"
}
