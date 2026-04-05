#!/bin/bash

########################################################################
#                                                                      #
#  Shell script to download and install piHPSDR (HB9TOB fork)         #
#  for Linux PC (Desktop/Laptop).                                      #
#                                                                      #
#  This fork is based on DL1YCF's piHPSDR and adds:                   #
#    - Fix: Adalm Pluto TX chain not activated at startup (SoapySDR)   #
#      The TX stream is now enabled only during actual transmission    #
#      and disabled again when returning to receive.                   #
#                                                                      #
#  Inspired by M0AWS install script (https://m0aws.co.uk/)             #
#                                                                      #
########################################################################
#                                                                      #
#  History:                                                            #
#                                                                      #
#  2025-04-05  V1.0 - HB9TOB - Initial version (based on M0AWS V2.2)  #
#                                                                      #
########################################################################

VERSION="v1.0"
NOW=$(date | sed 's/ /-/g' | sed 's/:/-/g')
ID=$(id | awk '{print $1}' | awk -F "(" '{print $2}' | sed 's/)//g')
HOMEDIR=$(grep "^${ID}:" /etc/passwd | awk -F":" '{print $6}')
NEWDIR="$HOMEDIR/PiHPSDR-HB9TOB-$NOW"
URL="https://github.com/hb9tob/pihpsdr"
GIT=$(which git)
SOAPY=false

clear
echo " "
echo "install-pihpsdr-hb9tob $VERSION - HB9TOB fork"
echo "================================================"
echo " "
echo "  Source: $URL"
echo "  Fork of DL1YCF piHPSDR with Adalm Pluto TX fix"
echo " "

# Check git is installed
case $GIT in
    "") echo "Installing git ..."
        sudo apt install --yes git
        ;;
esac

# Clone the source
echo -e "Cloning piHPSDR (HB9TOB fork) ...\n"
mkdir -p "$NEWDIR"
cd "$NEWDIR"
git clone "$URL"
echo -e "\n\nSource code stored in $NEWDIR\n\n  Please make a note of this!\n"
read -p "Press Enter to continue" INPUT

cd ./pihpsdr

# Update desktop icon name
mv ./LINUX/libinstall.sh ./LINUX/libinstall.sh.ORIG
sed 's/Name=piHPSDR/Name=HB9TOB-PiHPSDR/g' ./LINUX/libinstall.sh.ORIG > ./LINUX/libinstall.sh
chmod 755 ./LINUX/libinstall.sh

# Write build configuration:
#   - GPIO=OFF  : not needed on a Linux PC (no Raspberry Pi GPIO)
#   - SOAPYSDR=ON: required for Adalm Pluto, RTL-SDR, etc.
cat > ./make.config.pihpsdr <<'EOF'
GPIO=OFF
SOAPYSDR=ON
EOF

read -p "Do you want to also build extra SoapySDR device modules (Pluto, RTL-SDR, Airspy, HackRF, SDRplay)? [Y/N]: " INPUT
case $INPUT in
    Y|y) SOAPY=true ;;
esac

# Install dependencies and compile
echo -e "\n\nStarting installation, please wait ...\n"
./LINUX/libinstall.sh
make clean
make

if [ $? -ne 0 ]; then
    echo -e "\n\nERROR: compilation failed. Check the output above.\n"
    exit 1
fi

# Optionally build SoapySDR device modules
case $SOAPY in
    true)
        echo -e "\nBuilding SoapySDR device modules ...\n"
        ./LINUX/soapy.pluto.sh
        ./LINUX/soapy.rtlstick.sh
        ./LINUX/soapy.airspy.sh
        ./LINUX/soapy.hackrf.sh
        ./LINUX/soapy.sdrplay.sh
        ;;
esac

echo -e "
========================================================
  Installation complete!
========================================================

  Binary: $NEWDIR/pihpsdr/pihpsdr

  To start piHPSDR:
    $NEWDIR/pihpsdr/pihpsdr

  On first run, piHPSDR will compute FFT wisdom tables.
  This takes a few minutes — do not interrupt it.

  Adalm Pluto note:
    This build includes a fix so the TX chain is only
    activated during actual transmission. Connect your
    Pluto via USB before starting piHPSDR.

73 de HB9TOB
"
