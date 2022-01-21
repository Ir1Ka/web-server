#!/bin/sh
set -e

API=https://api.github.com/repos/shadowsocks/v2ray-plugin/releases/latest

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

for url in $(wget -qO- -t1 -T2 "${API}" | jq -r '.assets[].browser_download_url'); do
  ! echo $url | grep -q "${OS}-${ARCH}" || wget $url -O- | tar xz
done
test -f v2ray-plugin_${OS}_${ARCH}
mv v2ray-plugin_${OS}_${ARCH} v2ray-plugin

apk del wget jq --purge

./v2ray-plugin --version
