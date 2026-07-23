#!/bin/bash
#
## BUILD SCRIPT TO AUTOMATE SWAN2000 BUILDS FOR ALL SUPPORTED DEVICES ##
#
# The aarch64 and arm32 toolchains are downloaded and installed
# automatically (if not already present) to:
# /tmp/src/android/toolchains/{aarch64-elf , arm-eabi}
#
# You don't need to set anything up manually before running this script.
#
################### MODELS THIS SCRIPT WILL BUILD FOR ###################
#
# LG G5:
# H830		= T-Mobile (US)
# H850		= International (Global)
# RS988		= Unlocked (US)
#
#  ---------------------------------------
# LG V20:
# H910		= AT&T (US)
# H918		= T-Mobile (US)
# US996		= US Cellular & Unlocked (US) (Officially unlocked)
# US996D	= US Cellular & Unlocked (US) (Unlocked with Dirtysanta)
# VS995		= Verizon (US)
# H990DS	= International (Global) (Uses common H990 kernel)
# H990TR	= Turkey (TR) (Uses common H990 kernel)
# LS997		= Sprint (US)
#
#  ---------------------------------------
# LG G6:
# H870		= International (Global)
# US997		= US Cellular & Unlocked (US)
# H872		= T-Mobile (US)

# color codes
COLOR_N="\033[0m"
COLOR_R="\033[0;31m"
COLOR_G="\033[1;32m"
COLOR_Y="\033[1;33m"
COLOR_B="\033[1;34m"
COLOR_P="\033[1;35m"

# root directory where toolchains are downloaded/extracted to
TOOLCHAINS_DIR=/tmp/src/android/toolchains

# toolchain download URLs (Eva GCC)
GCC64_URL="https://github.com/mvaisakh/gcc-build/releases/download/19072026/eva-gcc-arm64-19072026.xz"
GCC32_URL="https://github.com/mvaisakh/gcc-build/releases/download/19072026/eva-gcc-arm-19072026.xz"

ABORT() {
	echo -e $COLOR_R"Error: $*"
	exit 1
}

# downloads & extracts a toolchain archive if it isn't already present
# usage: FETCH_TOOLCHAIN <url> <dest_subdir> <prefix>
FETCH_TOOLCHAIN() {
	local url=$1
	local dest=$TOOLCHAINS_DIR/$2
	local prefix=$3
	local archive=$TOOLCHAINS_DIR/$(basename "$url")

	if [ -x "${dest}/bin/${prefix}gcc" ]; then
		return 0
	fi

	echo -e $COLOR_G"Downloading toolchain: $(basename "$url")..."$COLOR_N
	mkdir -p "$TOOLCHAINS_DIR" || ABORT "Failed to create $TOOLCHAINS_DIR"

	wget -q --show-progress -O "$archive" "$url" \
		|| ABORT "Failed to download $url"

	echo -e $COLOR_G"Extracting toolchain to ${dest}..."$COLOR_N
	local extract_tmp
	extract_tmp=$(mktemp -d "$TOOLCHAINS_DIR/extract.XXXXXX") \
		|| ABORT "Failed to create temp extraction dir"

	tar xf "$archive" -C "$extract_tmp" \
		|| ABORT "Failed to extract $archive"

	# archive contains a single top-level directory, move its contents into place
	local inner
	inner=$(find "$extract_tmp" -mindepth 1 -maxdepth 1 -type d | head -n1)
	[ -n "$inner" ] || ABORT "Unexpected archive layout in $archive"

	rm -rf "$dest"
	mv "$inner" "$dest" || ABORT "Failed to install toolchain to $dest"

	rm -rf "$extract_tmp" "$archive"

	[ -x "${dest}/bin/${prefix}gcc" ] \
		|| ABORT "Toolchain install verification failed for ${dest}/bin/${prefix}gcc"
}

SETUP_TOOLCHAINS() {
	FETCH_TOOLCHAIN "$GCC64_URL" "aarch64-elf" "aarch64-elf-"
	FETCH_TOOLCHAIN "$GCC32_URL" "arm-eabi" "arm-eabi-"
}

# installs ccache via the system package manager if it isn't already available
INSTALL_CCACHE() {
	echo -e $COLOR_G"ccache not found, installing..."$COLOR_N

	if command -v apt-get >/dev/null 2>&1; then
		if [ "$(id -u)" = "0" ]; then
			apt-get update; apt-get install -y ccache
		else
			sudo apt-get update; sudo apt-get install -y ccache
		fi
	elif command -v dnf >/dev/null 2>&1; then
		if [ "$(id -u)" = "0" ]; then
			dnf install -y ccache
		else
			sudo dnf install -y ccache
		fi
	elif command -v pacman >/dev/null 2>&1; then
		if [ "$(id -u)" = "0" ]; then
			pacman -Sy --noconfirm ccache
		else
			sudo pacman -Sy --noconfirm ccache
		fi
	else
		ABORT "Could not find a supported package manager to install ccache. Please install it manually."
	fi

	command -v ccache >/dev/null 2>&1 \
		|| ABORT "ccache installation failed. Please install it manually."
}

# Array of supported models
MODEL_ARRAY=("H850" "H830" "RS988" "H870" "US997" "H872" "H910" "H918" "H990" "LS997" "US996" "US996D" "VS995")

WILL_BUILD="no"

BUILD_ALL () {
    echo -e $COLOR_G"This script is used solely to automate builds of: \n"$COLOR_B
    echo -e "   ______       _____    _   __ ___   __  __  __  "
    echo -e "  / ___/ |     / /   |  / | / /|__ \ /__\/__\/__\ "
    echo -e "  \__ \| | /| / / /| | /  |/ / __/ /// /// /// // "
    echo -e " ___/ /| |/ |/ / ___ |/ /|  / / __///_///_///_//  "
    echo -e "/____/ |__/|__/_/  |_/_/ |_/ /____/\__/\__/\__/   "
    echo -e "         Developers: stendro + AShiningRay        "
    echo -e $COLOR_P"\n\nYOU DON'T NEED THIS TO BUILD FOR A SINGLE DEVICE!\n"
    echo -e $COLOR_Y"Do you wish to build for all supported devices?"
    
    read -p "[yes, anything_else_thats_not_yes] -> " WILL_BUILD

    if [ $WILL_BUILD = "yes" ]; then
        echo -e $COLOR_B"\nvvv Beginning build for all supported devices! vvv\n"$COLOR_N

        SETUP_TOOLCHAINS
        command -v ccache >/dev/null 2>&1 || INSTALL_CCACHE
        export CCACHE_DIR="/tmp/src/android/ccache"
        mkdir -p "$CCACHE_DIR" || ABORT "Failed to create $CCACHE_DIR"

        for DEVICE in "${MODEL_ARRAY[@]}"; do
            echo -e $COLOR_B"|----------------------${DEVICE}----------------------|\n"$COLOR_N
            ./build.sh $DEVICE "build_all"

            echo -e $COLOR_B"\nPacking up ${DEVICE}'s kernel..."$COLOR_N
            ./copy_finished.sh "build_all"

            echo -e $COLOR_B"\n${DEVICE} kernel is ready! \n"$COLOR_N
        done
        echo -e $COLOR_B"\nSwan2000 was built for all supported devices! \n --- Exiting...\n"$COLOR_N
    else
        echo -e "Build aborted!" $COLOR_N
    fi
}

BUILD_ALL