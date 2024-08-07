#!/bin/sh

set -ex

esd="${1}"
tmpdir=$(mktemp -d)

__cleanup() {
    set -e
    rm -rf "${tmpdir}"
}
trap __cleanup EXIT

image_count=$(wiminfo "${esd}" --header | grep '^Image Count' | cut -d= -f 2 )

wimapply "${esd}" 1 "${tmpdir}"
wimexport "${esd}" 2 "${tmpdir}/sources/boot.wim" --compress=LZX --chunk-size 32K
wimexport "${esd}" 3 "${tmpdir}/sources/boot.wim" --compress=LZX --chunk-size 32K --boot

for index in $(seq 4 ${image_count})
do
    wimexport "${esd}" "${index}" "${tmpdir}/sources/install.esd" --compress=LZMS --chunk-size 128K
done

iso="$2"

rm -f "${iso}"
hdiutil makehybrid -o "${iso}" -iso -udf -hard-disk-boot -eltorito-boot "${tmpdir}/efi/microsoft/boot/efisys.bin" -iso-volume-name ESD_ISO -udf-volume-name ESD-ISO "${tmpdir}"

