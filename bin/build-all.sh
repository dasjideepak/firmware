#!/bin/bash

set -e

source bin/version.sh

COUNTRIES="US EU433 EU865 CN JP"
# COUNTRIES=US

SRCMAP=.pio/build/esp32/output.map
SRCBIN=.pio/build/esp32/firmware.bin
SRCELF=.pio/build/esp32/firmware.elf
OUTDIR=release/latest

# We keep all old builds (and their map files in the archive dir)
ARCHIVEDIR=release/archive 

rm -f $OUTDIR/firmware*

for COUNTRY in $COUNTRIES; do 

    HWVERSTR="1.0-$COUNTRY"
    COMMONOPTS="-DAPP_VERSION=$VERSION -DHW_VERSION_$COUNTRY -DHW_VERSION=$HWVERSTR -Wall -Wextra -Wno-missing-field-initializers -Isrc -Os -Wl,-Map,.pio/build/esp32/output.map -DAXP_DEBUG_PORT=Serial"

    export PLATFORMIO_BUILD_FLAGS="-DT_BEAM_V10 $COMMONOPTS"
    echo "Building with $PLATFORMIO_BUILD_FLAGS"
    rm -f $SRCBIN $SRCMAP
    pio run # -v
    cp $SRCBIN $OUTDIR/firmware-TBEAM-$COUNTRY-$VERSION.bin
    cp $SRCELF $OUTDIR/firmware-TBEAM-$COUNTRY-$VERSION.elf    
    #cp $SRCMAP $ARCHIVEDIR/firmware-TBEAM-$COUNTRY-$VERSION.map

    export PLATFORMIO_BUILD_FLAGS="-DHELTEC_LORA32 $COMMONOPTS"
    rm -f $SRCBIN $SRCMAP
    pio run # -v
    cp $SRCBIN $OUTDIR/firmware-HELTEC-$COUNTRY-$VERSION.bin
    cp $SRCELF $OUTDIR/firmware-HELTEC-$COUNTRY-$VERSION.elf
    #cp $SRCMAP $ARCHIVEDIR/firmware-HELTEC-$COUNTRY-$VERSION.map
done

# keep the bins in archive also
cp $OUTDIR/firmware* $ARCHIVEDIR

cat >$OUTDIR/curfirmwareversion.xml <<XML
<?xml version="1.0" encoding="utf-8"?>

<!-- This file is kept in source control because it reflects the last stable
release.  It is used by the android app for forcing software updates.  Do not edit.
Generated by bin/buildall.sh -->

<resources>
    <string name="cur_firmware_version">$VERSION</string>
</resources>
XML

rm -f $ARCHIVEDIR/firmware-$VERSION.zip
zip $ARCHIVEDIR/firmware-$VERSION.zip $OUTDIR/firmware-*-$VERSION.*

echo BUILT ALL