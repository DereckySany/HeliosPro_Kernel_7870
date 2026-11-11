#!/bin/bash
#
# Cronos Build Script V4.1 (no interaction / CI) - refatorado
# For Exynos7870
# Coded by BlackMesa/AnanJaser1211 @2019
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Uso:
#   ./Cronos_no_interaction.sh <SM-XXXX|Build_All> <1|2|OneUI|Treble> [versao] [nome] [android 7|8|9] [clean y|n]
#
# Exemplo:
#   ./Cronos_no_interaction.sh SM-J710X 2 V5.0 CronosKernel 9
#
# Padrões: versao=V5.0  nome=CronosKernel  android=9 (7 no J710X)  clean=y

#####################################################
# Argumentos
#####################################################
ARG_DEVICE=$1
ARG_VARIANT=$2
CR_VERSION=${3:-V5.0}
CR_NAME=${4:-CronosKernel}
ARG_ANDROID=$5
CR_CLEAN_ARG=${6:-y}

#####################################################
# Aparelhos (fonte única: para adicionar um, inclua na lista
# e declare as 4 variáveis CR_*_<MODELO>)
#####################################################
DEVICES=(J530X J730X J710X J701X G610X J600X A600X)

usage() {
    echo "Uso: $0 <${DEVICES[*]/#/SM-}|Build_All> <1|2|OneUI|Treble> [versao] [nome] [android 7|8|9] [clean y|n]" >&2
    exit 1
}

[ -z "$ARG_DEVICE" ] && usage
if [ "$ARG_DEVICE" != "Build_All" ]; then
    case " ${DEVICES[*]/#/SM-} " in
        *" $ARG_DEVICE "*) ;;
        *) echo "Aparelho inválido: $ARG_DEVICE" >&2; usage ;;
    esac
fi

#####################################################
# Toolchain
#####################################################
chmod a+x download-toolchain.sh && ./download-toolchain.sh || {
    echo "Erro: falha ao preparar o toolchain." >&2
    exit 1
}

#####################################################
# Variáveis globais
#####################################################
CR_DIR=$(pwd)
CR_TC=${CR_TC:-$HOME/toolchains/arm64/gcc-linaro-4.9.4-2017.01-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-}

# DTS
CR_DTS=arch/arm64/boot/dts
CR_DTS_TREBLE=arch/arm64/boot/exynos7870_Treble.dtsi
CR_DTS_ONEUI=arch/arm64/boot/exynos7870_Oneui.dtsi
CR_DTS_X6LTE=arch/arm64/boot/exynos7870_x6lte.dtsi

# Saídas
CR_OUT=$CR_DIR/Cronos/Out
CR_PRODUCT=$CR_DIR/Cronos/Product
CR_AIK=$CR_DIR/Cronos/A.I.K

# Ramdisks
CR_RAMDISK_ONEUI=$CR_DIR/Cronos/Oneui
CR_RAMDISK_PORT=$CR_DIR/Cronos/Treble_unofficial
CR_RAMDISK_TREBLE=$CR_DIR/Cronos/Treble_official

# Imagem / DTB compilados
CR_KERNEL=$CR_DIR/arch/arm64/boot/Image
CR_DTB=$CR_DIR/boot.img-dtb

CR_JOBS=$(nproc --all)
CR_ARCH=arm64
CR_DATE=$(date +%Y%m%d)

export CROSS_COMPILE=$CR_TC
export ARCH=$CR_ARCH

# Configs comuns
CR_CONFIG_TREBLE=treble_defconfig
CR_CONFIG_ONEUI=oneui_defconfig
CR_CONFIG_SPLIT=NULL
CR_CONFIG_HELIOS=helios_defconfig

# Flashable
FL_DIR=$CR_DIR/Cronos/Flashable
FL_EXPORT=$CR_DIR/Cronos/Flashable_OUT
FL_MAGISK=$FL_EXPORT/Helios/magisk/magisk.zip
FL_SCRIPT=$FL_EXPORT/META-INF/com/google/android/updater-script

#####################################################
# Dados dos aparelhos
#####################################################
# [SM-J530_2GB (F/G/S/L/K)]
CR_DTSFILES_J530X="exynos7870-j5y17lte_eur_open_00.dtb exynos7870-j5y17lte_eur_open_01.dtb exynos7870-j5y17lte_eur_open_02.dtb exynos7870-j5y17lte_eur_open_03.dtb exynos7870-j5y17lte_eur_open_05.dtb exynos7870-j5y17lte_eur_open_07.dtb"
CR_CONFG_J530X=j5y17lte_defconfig
CR_VARIANT_J530X=J530X
CR_FLMODEL_J530X=j5y17lte
# [SM-J530_3GB (Y/YM/FM/GM)] (fora da lista)
CR_DTSFILES_J530M="exynos7870-j5y17lte_sea_openm_03.dtb exynos7870-j5y17lte_sea_openm_05.dtb exynos7870-j5y17lte_sea_openm_07.dtb"
CR_CONFG_J530M=j5y17lte_defconfig
CR_VARIANT_J530M=J530Y
CR_FLMODEL_J530M=j5y17lte
# [SM-J730X]
CR_DTSFILES_J730X="exynos7870-j7y17lte_eur_open_00.dtb exynos7870-j7y17lte_eur_open_01.dtb exynos7870-j7y17lte_eur_open_02.dtb exynos7870-j7y17lte_eur_open_03.dtb exynos7870-j7y17lte_eur_open_04.dtb exynos7870-j7y17lte_eur_open_05.dtb exynos7870-j7y17lte_eur_open_06.dtb exynos7870-j7y17lte_eur_open_07.dtb"
CR_CONFG_J730X=j7y17lte_defconfig
CR_VARIANT_J730X=J730X
CR_FLMODEL_J730X=j7y17lte
# [SM-J710X]
CR_DTSFILES_J710X="exynos7870-j7xelte_eur_open_00.dtb exynos7870-j7xelte_eur_open_01.dtb exynos7870-j7xelte_eur_open_02.dtb exynos7870-j7xelte_eur_open_03.dtb exynos7870-j7xelte_eur_open_04.dtb"
CR_CONFG_J710X=j7xelte_defconfig
CR_VARIANT_J710X=J710X
CR_FLMODEL_J710X=j7xelte
# [SM-J701X]
CR_DTSFILES_J701X="exynos7870-j7velte_sea_open_00.dtb exynos7870-j7velte_sea_open_01.dtb exynos7870-j7velte_sea_open_03.dtb"
CR_CONFG_J701X=j7veltesea_defconfig
CR_VARIANT_J701X=J701X
CR_FLMODEL_J701X=j7velte
# [SM-G610X]
CR_DTSFILES_G610X="exynos7870-on7xelte_swa_open_00.dtb exynos7870-on7xelte_swa_open_01.dtb exynos7870-on7xelte_swa_open_02.dtb"
CR_CONFG_G610X=on7xelteswa_defconfig
CR_VARIANT_G610X=G610X
CR_FLMODEL_G610X=on7xelte
# [SM-J600X]
CR_DTSFILES_J600X="exynos7870-j6lte_ltn_00.dtb exynos7870-j6lte_ltn_02.dtb"
CR_CONFG_J600X=j6lte_defconfig
CR_VARIANT_J600X=J600X
CR_FLMODEL_J600X=j6lte
# [SM-A600X]
CR_DTSFILES_A600X="exynos7870-a6lte_eur_open_00.dtb exynos7870-a6lte_eur_open_01.dtb exynos7870-a6lte_eur_open_02.dtb exynos7870-a6lte_eur_open_03.dtb"
CR_CONFG_A600X=a6lte_defconfig
CR_VARIANT_A600X=A600X
CR_FLMODEL_A600X=a6lte

# ---- Exceções por aparelho (só o que difere do padrão) ----
# Android padrão do aparelho quando o parâmetro 5 não é informado (padrão geral: 9)
CR_DEFANDROID_J710X=7
# X6LTE: ramdisk Treble oficial + dtsi próprio, em qualquer modo
for M in J600X A600X; do
    declare "CR_RAMDISK_$M=$CR_RAMDISK_TREBLE"
    declare "CR_DTB_MOUNT_$M=$CR_DTS_X6LTE"
done

# Lê a variável "<prefixo><modelo>" (A+B=AB)
_v() { local r="$1$2"; printf '%s' "${!r}"; }

# 7 -> n, 8 -> o, qualquer outro -> p
android_letter() { case $1 in 7) echo n ;; 8) echo o ;; *) echo p ;; esac; }

#####################################################
# Modo de build e limpeza (via parâmetros)
#####################################################
if [ "$ARG_VARIANT" = "Treble" ] || [ "$ARG_VARIANT" = "treble" ] || [ "$ARG_VARIANT" = "2" ]; then
    echo "Build Treble Variant"
    CR_MODE=2
else
    echo "Build OneUI Variant"
    CR_MODE=1
fi

if [ "$CR_CLEAN_ARG" = "Y" ] || [ "$CR_CLEAN_ARG" = "y" ]; then
    echo "Clean Build"
    CR_CLEAN=1
else
    echo "Dirty Build"
    CR_CLEAN=0
fi

#####################################################
# Funções
#####################################################
BUILD_CLEAN()
{
    if [ "$CR_CLEAN" = 1 ]; then
        echo " "
        echo " Cleaning build dir"
        make clean && make mrproper
        rm -rf "$CR_OUT"/*.img "$CR_OUT"/*.zip
    else
        echo " "
        echo " Skip Full cleaning"
    fi
    rm -rf "$CR_DTB" "$CR_DTS"/.*.tmp "$CR_DTS"/.*.cmd "$CR_DTS"/*.dtb \
           "$CR_DIR/.config" "$CR_DTS/exynos7870.dtsi"
}

BUILD_IMAGE_NAME()
{
    CR_IMAGE_NAME=$CR_NAME-$CR_VERSION-$CR_VARIANT-$CR_DATE
    # CR_VARIANT = <MODELO>-<MODO>; FL_VARIANT = <MODELO>-Treble/OneUI
    if [ "$CR_MODE" = 2 ]; then FL_VARIANT="$CR_BASE-Treble"; else FL_VARIANT="$CR_BASE-OneUI"; fi
}

BUILD_GENERATE_CONFIG()
{
    local CFG=$CR_DIR/arch/$CR_ARCH/configs
    echo "----------------------------------------------"
    echo " "
    echo "Building defconfig for $CR_VARIANT"
    echo " "
    BUILD_CLEAN
    if [ -e "$CFG/tmp_defconfig" ]; then
        echo " cleanup old configs "
        rm -f "$CFG/tmp_defconfig"
    fi
    echo " Copy $CR_CONFIG "
    cp -f "$CFG/$CR_CONFIG" "$CFG/tmp_defconfig" || exit 1
    if [ "$CR_CONFIG_SPLIT" = NULL ]; then
        echo " No split config support! "
    else
        echo " Copy $CR_CONFIG_SPLIT "
        cat "$CFG/$CR_CONFIG_SPLIT" >> "$CFG/tmp_defconfig"
    fi
    echo " Copy $CR_CONFIG_USB "
    cat "$CFG/$CR_CONFIG_USB" >> "$CFG/tmp_defconfig"
    echo " Copy $CR_CONFIG_HELIOS "
    cat "$CFG/$CR_CONFIG_HELIOS" >> "$CFG/tmp_defconfig"
    echo " Set $CR_VARIANT to generated config "
    CR_CONFIG=tmp_defconfig
}

BUILD_ZIMAGE()
{
    echo "----------------------------------------------"
    echo " "
    echo "Building zImage for $CR_VARIANT"
    export LOCALVERSION=-$CR_IMAGE_NAME
    cp "$CR_DTB_MOUNT" "$CR_DTS/exynos7870.dtsi" || exit 1
    echo "Make $CR_CONFIG"
    make "$CR_CONFIG" || exit 1
    make -j"$CR_JOBS"
    if [ ! -e "$CR_KERNEL" ]; then
        echo "Image Failed to Compile"
        echo " Abort "
        exit 1
    fi
    sizT=$(du -k "$CR_KERNEL" | cut -f1)
    echo " "
    echo "----------------------------------------------"
}

BUILD_DTB()
{
    echo "----------------------------------------------"
    echo " "
    echo "Building DTB for $CR_VARIANT"
    # This source compiles dtbs while doing Image
    ./scripts/dtbTool/dtbTool -o "$CR_DTB" -d "$CR_DTS/" -s 2048
    if [ ! -e "$CR_DTB" ]; then
        echo "DTB Failed to Compile"
        echo " Abort "
        exit 1
    fi
    rm -rf "$CR_DTS"/.*.tmp "$CR_DTS"/.*.cmd "$CR_DTS"/*.dtb "$CR_DTS/exynos7870.dtsi"
    sizdT=$(du -k "$CR_DTB" | cut -f1)
    echo " "
    echo "----------------------------------------------"
}

PACK_BOOT_IMG()
{
    echo "----------------------------------------------"
    echo " "
    echo "Building Boot.img for $CR_VARIANT"
    cp -rf "$CR_RAMDISK"/* "$CR_AIK"
    mv "$CR_KERNEL" "$CR_AIK/split_img/boot.img-zImage"
    mv "$CR_DTB" "$CR_AIK/split_img/boot.img-dtb"
    "$CR_AIK/repackimg.sh"
    # Remove red warning at boot
    echo -n "SEANDROIDENFORCE" >> "$CR_AIK/image-new.img"
    cp "$CR_AIK/image-new.img" "$CR_PRODUCT/$CR_IMAGE_NAME.img"
    mv "$CR_AIK/image-new.img" "$CR_OUT/$CR_IMAGE_NAME.img"
    sizkT=$(du -k "$CR_OUT/$CR_IMAGE_NAME.img" | cut -f1)
    echo " "
    "$CR_AIK/cleanup.sh"
}

PACK_FLASHABLE()
{
    local ZIP=$CR_NAME-$CR_VERSION-$FL_VARIANT-$CR_DATE.zip
    echo "----------------------------------------------"
    echo "$CR_NAME $CR_VERSION Flashable Generator"
    echo "----------------------------------------------"
    echo " "
    echo " Target device : $CR_VARIANT "
    echo " Target image $CR_OUT/$CR_IMAGE_NAME.img "
    echo " Prepare Temporary Dirs"
    FL_DEVICE=$FL_EXPORT/Helios/device/$FL_MODEL/boot.img
    echo " Copy $FL_DIR to $FL_EXPORT"
    rm -rf "$FL_EXPORT"
    mkdir "$FL_EXPORT"
    cp -rf "$FL_DIR"/* "$FL_EXPORT"
    echo " Generate updater for $FL_VARIANT"
    sed -i "s/FL_NAME/ui_print(\"* $CR_NAME\");/g"             "$FL_SCRIPT"
    sed -i "s/FL_VERSION/ui_print(\"* $CR_VERSION\");/g"       "$FL_SCRIPT"
    sed -i "s/FL_VARIANT/ui_print(\"* For $FL_VARIANT \");/g" "$FL_SCRIPT"
    sed -i "s/FL_DATE/ui_print(\"* Compiled at $CR_DATE\");/g" "$FL_SCRIPT"
    echo " Copy Image to $FL_DEVICE"
    cp "$CR_OUT/$CR_IMAGE_NAME.img" "$FL_DEVICE"
    echo " Packing zip"
    ( cd "$FL_EXPORT" && zip -r "$CR_OUT/$ZIP" . ) || exit 1
    rm -rf "$FL_EXPORT"
    cp "$CR_OUT/$ZIP" "$CR_PRODUCT"
    BUILD_CLEAN
}

BUILD_OUT()
{
    echo " "
    echo "----------------------------------------------"
    echo "$CR_VARIANT kernel build finished."
    echo "Compiled DTB Size = $sizdT Kb"
    echo "Kernel Image Size = $sizT Kb"
    echo "Boot Image   Size = $sizkT Kb"
    echo "Image Generated at $CR_PRODUCT/$CR_IMAGE_NAME.img"
    echo "Zip Generated at $CR_PRODUCT/$CR_NAME-$CR_VERSION-$FL_VARIANT-$CR_DATE.zip"
    echo "----------------------------------------------"
}

# Monta todas as variáveis do aparelho $1 (ex.: J530X) e executa o build
BUILD_TARGET()
{
    local M=$1 MODE D_RAMDISK D_DTB AND r

    CR_BASE=$(_v CR_VARIANT_ "$M")
    CR_CONFIG=$(_v CR_CONFG_ "$M")
    CR_DTSFILES=$(_v CR_DTSFILES_ "$M")
    FL_MODEL=$(_v CR_FLMODEL_ "$M")

    # Android: parâmetro 5 > padrão do aparelho > 9
    AND=${ARG_ANDROID:-$(_v CR_DEFANDROID_ "$M")}
    AND=${AND:-9}
    export ANDROID_MAJOR_VERSION=$(android_letter "$AND")
    export PLATFORM_VERSION="$AND.0.0"

    if [ "$CR_MODE" = 2 ]; then
        MODE=TREBLE
        CR_CONFIG_USB=$CR_CONFIG_TREBLE
        D_RAMDISK=$CR_RAMDISK_PORT
        D_DTB=$CR_DTS_TREBLE
    else
        MODE=ONEUI
        CR_CONFIG_USB=$CR_CONFIG_ONEUI
        D_RAMDISK=$CR_RAMDISK_ONEUI
        D_DTB=$CR_DTS_ONEUI
    fi

    # Exceção do aparelho se existir, senão padrão do modo
    r=CR_RAMDISK_$M;   CR_RAMDISK=${!r:-$D_RAMDISK}
    r=CR_DTB_MOUNT_$M; CR_DTB_MOUNT=${!r:-$D_DTB}

    CR_VARIANT=$CR_BASE-$MODE
    echo "Starting $CR_BASE kernel build (Android $AND / $ANDROID_MAJOR_VERSION)..."
    echo " Building $MODE variant "

    BUILD_IMAGE_NAME
    BUILD_GENERATE_CONFIG
    BUILD_ZIMAGE
    BUILD_DTB
    PACK_BOOT_IMG
    PACK_FLASHABLE
    BUILD_OUT
}

#####################################################
# Execução
#####################################################
echo "----------------------------------------------"
echo "$CR_NAME $CR_VERSION Build Script"
echo "----------------------------------------------"

if [ "$ARG_DEVICE" = "Build_All" ]; then
    for M in "${DEVICES[@]}"; do BUILD_TARGET "$M"; done
    echo " "
    echo " compilation finished "
    echo " Targets at $CR_OUT"
else
    BUILD_TARGET "${ARG_DEVICE#SM-}"
fi
