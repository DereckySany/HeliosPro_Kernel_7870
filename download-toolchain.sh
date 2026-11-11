#!/bin/bash
# Baixa e extrai o toolchain arm64 (aria2c, com fallback para curl)

#TOOLCHAIN_URL="https://snapshots.linaro.org/gnu-toolchain/14.0-2023.06-1/aarch64-linux-gnu/gcc-linaro-14.0.0-2023.06-x86_64_aarch64-linux-gnu.tar.xz"
# "https://releases.linaro.org/components/toolchain/binaries/4.9-2017.01/aarch64-linux-gnu/gcc-linaro-4.9.4-2017.01-x86_64_aarch64-linux-gnu.tar.xz"
# "https://mirrors.cstcloud.cn/armbian-releases/_toolchain/gcc-linaro-7.4.1-2019.02-x86_64_aarch64-linux-gnu.tar.xz"
TOOLCHAIN_URL="https://mirrors.cstcloud.cn/armbian-releases/_toolchain/gcc-linaro-4.9.4-2017.01-x86_64_aarch64-linux-gnu.tar.xz"
TOOLCHAIN_DIR="$HOME/toolchains/arm64"

# Nomes derivados da URL (basta trocar a URL acima)
TARBALL=$(basename "$TOOLCHAIN_URL")
TOOLCHAIN_NAME=${TARBALL%.tar.xz}
TOOLCHAIN_BIN="$TOOLCHAIN_DIR/$TOOLCHAIN_NAME/bin"

mkdir -p "$TOOLCHAIN_DIR" || exit 1

download() {
    local url=$1 dir=$2 file=$3

    if command -v aria2c >/dev/null 2>&1; then
        echo "Baixando com aria2c..."
        aria2c -x16 -s16 -k1M -c --file-allocation=none \
               --max-tries=3 --retry-wait=3 \
               -d "$dir" -o "$file" "$url" && return 0
        echo "aria2c falhou, tentando curl..."
    else
        echo "aria2c não encontrado, usando curl..."
    fi

    if command -v curl >/dev/null 2>&1; then
        curl -L --fail --retry 3 -C - -o "$dir/$file" "$url" && return 0
    fi

    return 1
}

# Pula o download se o toolchain já estiver extraído
if [ -x "$TOOLCHAIN_BIN/aarch64-linux-gnu-gcc" ]; then
    echo "Toolchain já instalado em $TOOLCHAIN_DIR/$TOOLCHAIN_NAME"
else
    download "$TOOLCHAIN_URL" "$TOOLCHAIN_DIR" "$TARBALL" || {
        echo "Erro: falha ao baixar o toolchain." >&2
        exit 1
    }

    echo "Extraindo..."
    tar -xf "$TOOLCHAIN_DIR/$TARBALL" -C "$TOOLCHAIN_DIR" || {
        echo "Erro: falha ao extrair (arquivo corrompido? apague $TOOLCHAIN_DIR/$TARBALL e tente de novo)." >&2
        exit 1
    }
fi

export PATH="$TOOLCHAIN_BIN:$PATH"

echo "Lista do Toolchain:"
ls -r "$TOOLCHAIN_BIN"
echo "Toolchain arm64 instalado com sucesso!"
echo "$PATH"
