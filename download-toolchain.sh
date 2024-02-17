#!/bin/bash

# URL do toolchain arm64
TOOLCHAIN_URL="https://developer.arm.com/tools-and-software/open-source-software/gnu-toolchain/aarch64-linux-gnu-binaries/latest"

# Diretório de destino
TOOLCHAIN_DIR="$HOME/toolchains/arm64"

# Criar diretório de destino
mkdir -p "$TOOLCHAIN_DIR"

# Baixar toolchain
curl -L "$TOOLCHAIN_URL" -o "$TOOLCHAIN_DIR/arm64-linux-gnu-binaries.tar.gz"

# Extrair toolchain
tar -xzf "$TOOLCHAIN_DIR/arm64-linux-gnu-binaries.tar.gz" -C "$TOOLCHAIN_DIR"

# Adicionar diretório bin ao PATH
export PATH="$TOOLCHAIN_DIR/bin:$PATH"

echo "Toolchain arm64 instalado com sucesso!"
