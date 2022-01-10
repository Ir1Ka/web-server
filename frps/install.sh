#!/bin/sh
set -e

API=https://api.github.com/repos/fatedier/frp/releases/latest

apk add wget jq

arch_convert()
{
  arch=$(cat | tr 'A-Z' 'a-z')
  case $arch in
    x86_64)
      echo amd64
      ;;
    amd64)
      echo x86_64
      ;;
    aarch64)
      echo arm64
      ;;
    arm64)
      echo aarch64
      ;;
    *)
      echo $arch
      ;;
  esac
}

OS=$(uname | tr 'A-Z' 'a-z')
ARCH=$(uname -m | arch_convert)

api_content="$(wget -qO- -t1 -T2 "${API}")"
VERSION="$(echo "${api_content}" | jq -r '.tag_name' | sed -nE '1s/^v(([0-9]+\.)*[0-9]+)$/\1/p')"
for url in $(echo "${api_content}" | jq -r '.assets[].browser_download_url'); do
  ! echo $url | grep -q "${OS}_${ARCH}" || wget $url -O- | tar xz
done
test -d frp_${VERSION}_${OS}_${ARCH}
mkdir -p ./work
cp ./frp_${VERSION}_${OS}_${ARCH}/frps ./work/
mkdir -p ./work/conf
cp ./frp_${VERSION}_${OS}_${ARCH}/frps*.ini ./work/conf

apk del wget jq --purge

./work/frps --version
