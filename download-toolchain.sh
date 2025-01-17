#!/bin/bash

# URL do toolchain arm64
#TOOLCHAIN_URL="https://snapshots.linaro.org/gnu-toolchain/14.0-2023.06-1/aarch64-linux-gnu/gcc-linaro-14.0.0-2023.06-x86_64_aarch64-linux-gnu.tar.xz"
TOOLCHAIN_URL="https://releases.linaro.org/components/toolchain/binaries/4.9-2017.01/aarch64-linux-gnu/gcc-linaro-4.9.4-2017.01-x86_64_aarch64-linux-gnu.tar.xz"
# Diretório de destino
TOOLCHAIN_DIR="$HOME/toolchains/arm64"

# Criar diretório de destino
mkdir -p "$TOOLCHAIN_DIR"

# Baixar toolchain
curl -L "$TOOLCHAIN_URL" -o "$TOOLCHAIN_DIR/arm64-linux-gnu-binaries.tar.xz"

# Extrair toolchain
tar -xf "$TOOLCHAIN_DIR/arm64-linux-gnu-binaries.tar.xz" -C "$TOOLCHAIN_DIR"

# Adicionar diretório bin ao PATH
export PATH="$TOOLCHAIN_DIR/gcc-linaro-4.9.4-2017.01-x86_64_aarch64-linux-gnu/bin:$PATH"

echo "!ist of Toolchain!"
ls -r $TOOLCHAIN_DIR/gcc-linaro-4.9.4-2017.01-x86_64_aarch64-linux-gnu/bin
echo "Toolchain arm64 instalado com sucesso!"
echo "$PATH"
