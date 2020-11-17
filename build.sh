#!/bin/bash -e

#patch -p1 -i 0001-config.gz.patch
#patch -p1 -i 0002-cfqd_fix.patch

GCC64_DIR=~/WorkDir/gcc-aarch64-elf-10.2
GCC32_DIR=~/WorkDir/gcc-arm-eabi-10.2
LLVM_DIR=~/WorkDir/proton-clang-20200906

export ARCH=arm64
export SUBARCH=arm64
export HEADER_ARCH=arm64

export LOCALVERSION=

export KBUILD_BUILD_USER="irfan"
export KBUILD_BUILD_HOST="irfan-pc"

rm -f out/.version

export CROSS_COMPILE=aarch64-elf-
export CROSS_COMPILE_ARM32=arm-eabi-
export PATH=$GCC64_DIR/bin:$GCC32_DIR/bin:$PATH

useLLVM=Y

if [ "$useLLVM" ]; then
	LLVM="ARCH=arm64 AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip CC=clang HOSTCC=clang"
#	LLVM="$LLVM CROSS_COMPILE=$CROSS_COMPILE CROSS_COMPILE_ARM32=$CROSS_COMPILE_ARM32"
	LLVM="$LLVM CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi-"
	export PATH=$LLVM_DIR/bin:$PATH
fi

#[ ! -e out/.config ] || cp out/.config ./; rm -rf out; mkdir out; [ ! -e .config ] || mv .config out/

make O=out mido_defconfig $LLVM
make O=out menuconfig $LLVM

make -j $(nproc --all) O=out $LLVM

exit

cp out/arch/arm64/boot/Image.gz-dtb ../AnyKernel3/zImage

export INSTALL_MOD_PATH=$(realpath ../kernel_modules_flasher/)
rm -rf $INSTALL_MOD_PATH/lib
make O=out modules_install

DATE=$(date +"%d-%b_%y-%T")

cd ../AnyKernel3
zip -r9 ~/mido_kernel_${DATE}.zip *
rm zImage

cd ../kernel_modules_flasher
rm -f lib/modules/*/{build,source}
zip -r9 ~/mido_kernel_modules_${DATE}.zip *
rm -rf lib
