#!/bin/bash
#
ARCHITECTURES="aarch64 armhf armv7 ppc64le s360x x86 x86_64"
VERSION=$(cat version.txt | cut -d 'v' -f 2)
RELEASE=$(echo "$VERSION" | cut -d '.' -f 1-2)
MANIFEST=ghcr.io/oci-base/alpine

buildah manifest create "$MANIFEST:v$VERSION"
for arch in $(echo $ARCHITECTURES); do
  ctr=$(buildah from --arch "$arch" scratch)
  buildah add "$ctr" https://dl-cdn.alpinelinux.org/alpine/"$RELEASE/releases/$arch/alpine-netboot-$VERSION-$arch".tar.gz
  buildah commit --manifest "$MANIFEST:v$VERSION" "$ctr" "$MANIFEST:$VERSION-$arch"
done
echo "$GITHUB_TOKEN" | buildah login ghcr.io -u "$GITHUB_ACTOR" --password-stdin
buildah manifest push --all "$MANIFEST:v$VERSION" docker://"$MANIFEST:v$VERSION"
