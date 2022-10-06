#!/bin/bash
echo
echo "-----------------------------------------"
echo "           LineageOS Buildbot            "
echo "                  by                     "
echo "               xiaoleGun                 "
echo " Executing in 3 seconds - CTRL-C to exit "
echo "-----------------------------------------"
echo

sleep 3
set -e

type=$1

dt_url=https://github.com/xiaomi-mt6885-devs/tmp.git
dt_branch=TDA
vt_url=https://github.com/xiaomi-mt6885-devs/android_vendor_xiaomi_cezanne
vt_branch=TDA
kt_url=https://github.com/XayahSuSuSu/kernel_redmi_mt6885
kt_branch=TDA
all_branch=lineage-19.1

device=cezanne
vendor=xiaomi

BD=$HOME/builds

initrepo() {
if [ ! -d .repo ]
then
echo ""
echo "--> Initializing LineageOS workspace"
echo ""
repo init -u https://github.com/LineageOS/android.git -b lineage-19.1 --depth=1
fi
}

syncrepo() {
echo ""
echo "--> Syncing repos"
echo ""
repo sync -c --force-sync --no-clone-bundle --no-tags -j$(nproc --all)
}

applypatches() {
if [ ! -d patches ] ;then
git clone https://github.com/coolscode/patches patches
fi
rm -rf patches/patches/lineage/{frameworks_opt_net_ims,frameworks_opt_telephony}
bash patches/apply.sh lineage
}

initenvironment() {
echo ""
echo "--> Setting up build environment"
echo ""
source build/envsetup.sh &> /dev/null
mkdir -p $BD
}

clonemtksepolicy() {
if [ ! -d device/mediatek/sepolicy_vndr ] ;then
git clone https://github.com/xiaomi-mt6853-devs/android_device_mediatek_sepolicy_vndr device/mediatek/sepolicy_vndr
fi
}

clonetree() {
if [ ! -d device/$vendor/$device ] ;then
git clone $dt_url -b $all_branch device/$vendor/$device
fi

if [ ! -d vendor/$vendor/$device ] ;then
git clone $vt_url -b $all_branch vendor/$vendor/$device
fi

if [ ! -d kernel/$vendor/$device ] ;then
git clone $kt_url kernel/$vendor/$device
fi
}

build() {
echo ""
echo "--> Building"
echo ""
lunch lineage_cezanne-$type
#make bacon
make systemimage
make productimage
make vendorimage
}

pack() {
#cp -u out/target/product/$device/*.zip $BD/
cp out/target/product/$device/{system,vendor,product}.img $BD
cd $BD
zip -j -v LineageOS-cezanne.zip *.img 
}

initrepo
syncrepo
applypatches
initenvironment
clonetree
clonemtksepolicy
build
pack
