#!/bin/bash
#-----------------------------------------------------------------------
# This script produces a no-install version of NX player for MacOSX
# from respective NOMACHINE installer.
# It needs 7z from the p7zip package (http://p7zip.sourceforge.net) and
# dmg2img from http://vu1tur.eu.org/dmg2img
# Respective rpm and deb distributions are available.
#
# NOTE: you will need to start no-install nxplayer from the Terminal app.
# If you try to start it from Archiver or Finder, you will likely get a
# MacOSX security error.
#-----------------------------------------------------------------------

# DEBUG=1
  if [ "$DEBUG" == "0" ]; then DEBUG=''; fi

  CWD=$PWD

  if [ ! -w "$CWD" ]; then
     echo "Current directory is read-only. Please copy the files elsewhere."
     exit 1
  fi

  echo -e "\nProducing no-install version of NOMACHINE player for MacOSX"

  ### Example: nomachine-player_10.2.3_1.dmg
  PREFIX=nomachine-player_
  NXDMG=($(/bin/ls -tr -1 ${PREFIX}*.dmg))
  if [[ ${#NXDMG[@]} -eq 0 ]]; then
     echo -e "\n *** No nomachine-player installers for MacOSX found in $CWD"
     exit 1
  fi

### Choose the latest distribution:
  DMG=${NXDMG[-1]}
  echo "Found ${DMG}"
  VER=${DMG#${PREFIX}}
  VER=${VER%.dmg}
  VER=${VER/_*/}
  echo "NOMACHINE MacOSX installer version: ${VER}"

  TAR=$(which tar 2>/dev/null)
  if [ -z "$TAR" ]; then
     echo -e "\n *** No tar app in the system."
     exit 1
  fi

  EXTRACT=$(which 7z)
  if [ -z "$EXTRACT" ]; then
     echo -e "\n *** No 7z app in the system."
     exit 1
  fi

  DMG2IMG=$(which dmg2img)
  if [ -z "$DMG2IMG" ]; then
     echo -e "\n *** No dmg2img app in the system."
     exit 1
  fi

# COMPS=(nxclient nxplayer)				#versions before 8
  COMPS=(nxrunner nxplayer)
  echo "Extracting MacOSX NX components ( ${COMPS[*]} ) in several steps"
  if [ -n "$DIRECT_EXTRACT" ]; then
     echo "Extracting NoMachine/NoMachine.pkg from ${DMG}"
     echo "(this step is OK to fail)"
     echo "--> $EXTRACT x -bd -y $DMG"
     OUT=$($EXTRACT x -bd -y $DMG)
#    if [ -n "$DEBUG" ]; then echo -e "$OUT"; fi        #this is common, no need to report
     if [ $? -ne 0 ]; then
        echo -e "\nDirect extracting $DMG with $EXTRACT failed. Trying conversion of DMG to IMG"
        if [ -n "$DEBUG" ]; then read -rsp $'Press any key to continue...\n' -n1 key; fi
        CONVERT_DMG2IMG=1
     fi
  else
     CONVERT_DMG2IMG=1
  fi
  if [ -n "$CONVERT_DMG2IMG" ]; then
     IMG=${DMG/%.dmg}
     if [ -e "$IMG" ]; then /bin/rm -f $IMG; fi
     ### Newer DMG versions cannot be directly extracted with 7z.
     ### First, we need to convert them from DMG to IMG and then
     ### try again:
     IMG=${DMG/%dmg/img}
     echo "Converting ${DMG} to ${IMG}"
     echo "--> $DMG2IMG $DMG"
     OUT=$($DMG2IMG $DMG)
     if [ $? -ne 0 ]; then
        if [ -n "$DEBUG" ]; then echo -e "$OUT"; fi
        echo "Conversion of DMG to IMG failed. Exiting."
        exit 1;
     elif [ ! -e "$IMG" ]; then
        if [ -n "$DEBUG" ]; then echo -e "$OUT"; fi
        echo "No ${IMG} created. Exiting."
        exit 1;
     fi
     if [ -n "$DEBUG" ]; then echo -e "$OUT"; read -rsp $'Press any key to continue...\n' -n1 key; fi
     echo "Extracting content from ${IMG} with ${EXTRACT}"
# Depending on the version of 7z, it may extract either NoMachine/NoMachine.pkg or 4.hfs
     echo "--> $EXTRACT x -bd -y $IMG"
     OUT=$($EXTRACT x -bd -y $IMG)
     if [ $? -ne 0 ]; then
        if [ -n "$DEBUG" ]; then echo -e "$OUT"; fi
        echo "Extracting content of $IMG with $EXTRACT failed too. Exiting."
        if [ -e "$IMG" ]; then /bin/rm -f $IMG; fi
        exit 1
     fi
# $IMG was a temp file, we do not need it anymore.
     if [ -n "$DEBUG" ]; then echo -e "$OUT"; read -rsp $'Press any key to continue...\n' -n1 key; fi
     /bin/rm -f $IMG
  fi
  ### Newer 7z extracts NoMachine/NoMachine.pkg while older 7z first extracts 4.hfs
  if [ -e 4.hfs ]; then
     echo "Extracting content of 4.hfs which should include NoMachine/NoMachine.pkg"
     echo "--> $EXTRACT x -bd -y 4.hfs"
     OUT=$($EXTRACT x -bd -y 4.hfs)
     if [ $? -ne 0 ]; then
        if [ -n "$DEBUG" ]; then echo -e "$OUT"; fi
        echo "Extracting content of 4.hfs with $EXTRACT failed. Exiting."
        /bin/rm -f 4.hfs
        exit 1
     fi
# 4.hfs was a temp file, we do not need it anymore.
     if [ -n "$DEBUG" ]; then echo -e "$OUT"; read -rsp $'Press any key to continue...\n' -n1 key; fi
     /bin/rm -f 4.hfs
     for i in {0..7}; do /bin/rm -rf $i.*; done
  fi

  if [ ! -e NoMachine/NoMachine.pkg ]; then
     echo "File NoMachine/NoMachine.pkg not found after extraction. Exiting."
     exit 1
  fi
  MSG=; for COMP in ${COMPS[@]}; do MSG+=" ${COMP}.pkg"; done
  echo "Extracting (${MSG} ) dirs from NoMachine/NoMachine.pkg"
  echo "--> $EXTRACT x -bd -y NoMachine/NoMachine.pkg"
  OUT=$($EXTRACT x -bd -y NoMachine/NoMachine.pkg)
  if [ $? -ne 0 ]; then
     if [ -n "$DEBUG" ]; then echo -e "$OUT"; fi
     echo "Extracting NoMachine.pkg with $EXTRACT failed. Exiting."
    /bin/rm -rf Distribution Resources/ NoMachine/ \[TOC\].xml
     exit 1
  fi
  if [ -n "$DEBUG" ]; then echo -e "$OUT"; read -rsp $'Press any key to continue...\n' -n1 key; fi
  /bin/rm -rf Distribution Resources/ NoMachine/ \[TOC\].xml

#---
  for COMP in ${COMPS[@]}; do
     echo "--> find . -type d -name \"${COMP}*.pkg\""
     PKGDIR=$(find . -type d -name "${COMP}*.pkg")
     if [ -z "${PKGDIR}" ]; then
        echo "Cannot find directory ${COMP}*.pkg. Exiting."
        exit 1
     fi
     echo -e "\nExtracting ${COMP} files from ${PKGDIR}/Payload"
     if [ ! -e ${PKGDIR}/Payload ]; then
        echo "File ${PKGDIR}/Payload not found after extraction. Exiting."
        exit 1
     fi
     echo "Extracting content of ${PKGDIR}/Payload with $EXTRACT"
     echo "--> $EXTRACT x -bd -y ${PKGDIR}/Payload"
     OUT=$($EXTRACT x -bd -y ${PKGDIR}/Payload)
     if [ $? -ne 0 ]; then
        if [ -n "$DEBUG" ]; then echo -e "$OUT"; fi
        echo "Extracting content of ${PKGDIR}/Payload with $EXTRACT failed. Exiting."
        exit 1
     elif [ ! -e Payload~ ]; then
        if [ -n "$DEBUG" ]; then echo -e "$OUT"; fi
        echo "./Payload~ not found after extracting ${COMP}.pkg/Payload with $EXTRACT. Exiting."
        exit 1
     fi
     if [ -n "$DEBUG" ]; then echo -e "$OUT"; read -rsp $'Press any key to continue...\n' -n1 key; fi
     echo "Extracting content of ./Payload~ with $EXTRACT"
     echo "--> $EXTRACT x -bd -y Payload~"
     OUT=$($EXTRACT x -bd -y Payload~)
     if [ $? -ne 0 ]; then
        if [ -n "$DEBUG" ]; then echo -e "$OUT"; fi
        echo "Extracting ./Payload~ with $EXTRACT failed. Exiting."
        exit 1
     fi
     if [ -n "$DEBUG" ]; then echo -e "$OUT"; read -rsp $'Press any key to continue...\n' -n1 key; fi
     /bin/rm -rf Payload~ ${PKGDIR}
  done

#---
  # NOTE: it is important to preserve the "Contents" level
  # because otherwise nxplayer does not start on MacOSX.
  echo "--> /bin/mv Applications/NoMachine.app ./nxplayer4macosx"
  /bin/mv Applications/NoMachine.app ./nxplayer4macosx
  /bin/rm -rf Applications
  /bin/chmod -R a+rx nxplayer4macosx/Contents/MacOS/ nxplayer4macosx/Contents/Frameworks/bin/

  echo '#!/bin/bash'                                         > startnxplayer.sh
  echo ' xattr -rd com.apple.quarantine nxplayer4macosx'    >> startnxplayer.sh
  echo ' cd $(dirname "$0")/nxplayer4macosx/Contents/MacOS' >> startnxplayer.sh
  echo ' ./nxplayer &'                                      >> startnxplayer.sh
  chmod a+rx startnxplayer.sh

  ARCHIVE=nxplayer4macosx_${VER}.tgz
  echo -e "\nCreating ${CWD}/${ARCHIVE} with ${TAR}"
  echo "--> $TAR zcf ${CWD}/${ARCHIVE} nxplayer4macosx startnxplayer.sh --remove-files"
  OUT=$($TAR zcf ${CWD}/${ARCHIVE} nxplayer4macosx startnxplayer.sh --remove-files)
  if [ $? -ne 0 ]; then
     if [ -n "$DEBUG" ]; then echo -e "$OUT"; fi
     echo "'$TAR zcf ${CWD}/${ARCHIVE} nxplayer4macosx --remove-files' failed. Exiting."
     exit 1
  fi
  if [ -n "$DEBUG" ]; then echo -e "$OUT"; read -rsp $'Press any key to continue...\n' -n1 key; fi

  echo -e "\nFile ${CWD}/${ARCHIVE} is created"
  echo 'Usage:'
  echo "   tar zxf ${ARCHIVE}"
  echo '   ./startnxplayer.sh'

  SCRDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if [ -e ${SCRDIR}/move2dest.sh ]; then ${SCRDIR}/move2dest.sh ${ARCHIVE}; fi
  exit 0
