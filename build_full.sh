#!/bin/bash

cd ~

# Env
# sudo apt update && sudo apt -y dist-upgrade
sudo apt install -y gcc g++ python make texinfo texlive bc bison build-essential ccache curl flex g++-multilib gcc-multilib \
    git gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses5-dev libsdl1.2-dev \
    libssl-dev libwxgtk3.0-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev \
    unzip language-pack-zh-hans
# GCC Cross
# wget "https://developer.arm.com/-/media/Files/downloads/gnu-a/9.2-2019.12/binrel/gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu.tar.xz"
# xz -d gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu.tar.xz
# tar xf gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu.tar
# mv gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu .gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu

echo "download lang-r445002"
mkdir clang-r445002
wget -q https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/836b6c7f87c4c946d860ef664052282939a9bd31/clang-r445002.tar.gz -O "clang-r445002.tar.gz"
tar -xf clang-r445002.tar.gz -C clang-r445002

echo "download aarch64-linux-android-4.9"
mkdir aarch64-linux-android-4.9
wget -q https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/+archive/refs/tags/android-12.0.0_r15.tar.gz -O "gcc64.tar.gz"
tar -xf gcc64.tar.gz -C aarch64-linux-android-4.9

echo "download arm-linux-androideabi-4.9"
mkdir arm-linux-androideabi-4.9
wget -q https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/+archive/refs/tags/android-12.0.0_r15.tar.gz -O "gcc32.tar.gz"
tar -xf gcc32.tar.gz -C arm-linux-androideabi-4.9


# Env
export ARCH=arm64
export SUBARCH=arm64
# export PATH=~/.gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu/bin:$PATH
# export CROSS_COMPILE=aarch64-none-linux-gnu-


git clone https://github.com/osm0sis/AnyKernel3 AnyKernel
rm -rf AnyKernel/.git
rm -rf AnyKernel/.github
rm AnyKernel/anykernel.sh
cp android_kernel_xiaomi_sm8250/anykernel.sh AnyKernel/

cd android_kernel_xiaomi_sm8250
# make clean 
# make mrproper 
mkdir -p out
make O=out clean
make distclean
make oldconfig && make prepare

# args="-j$(nproc --all) O=out ARCH=arm64 SUBARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu-" 
# args="-j64 O=out ARCH=arm64 SUBARCH=arm64 CROSS_COMPILE=aarch64-none-linux-gnu-" 

args="ARCH=arm64 SUBARCH=arm64 CC=/home/runner/clang-r445002/bin/clang CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=/home/runner/aarch64-linux-android-4.9/bin/aarch64-linux-android- CROSS_COMPILE_ARM32=/home/runner/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-"

make -j$(nproc --all) ${args} O=out alioth_defconfig
make ${args} CONFIG_DEBUG_SECTION_MISMATCH=y
