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

  CWD=$PWD

  echo -e "\nProducing no-install version of NOMACHINE player for MacOSX"

  ### Example: nomachine-enterprise-client_6.0.78_4.dmg
  NXDMG=($(/bin/ls -tr -1 nomachine-enterprise-client_*.dmg))
  if [[ ${#NXDMG[@]} -eq 0 ]]; then
     echo -e "\n *** No nomachine-enterprise-client installers for MacOSX found in $CWD"
     exit 1
  fi

### Choose the latest distribution:
  DMG=${NXDMG[-1]}
  echo "Found ${DMG}"
  VER=${DMG#nomachine-enterprise-client_}
  VER=${VER%.dmg}
  VER=${VER/_*/}
  echo "NOMACHINE MacOSX installer version: ${VER}"

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

  echo "Extracting MacOSX nxplayer and nxclient in several steps"
  echo "Extracting NoMachine/NoMachine.pkg from ${DMG}"
  $EXTRACT x -bd -y $DMG  >/dev/null
  if [ $? -ne 0 ]; then
     IMG=${DMG/%.dmg}
     if [ -e "$IMG" ]; then /bin/rm -f $IMG; fi
     echo -e "\nDirect extracting $DMG with $EXTRACT failed. Trying conversion of DMG to IMG"
     ### Newer DMG versions cannot be directly extracted with 7z.
     ### First, we need to convert them from DMG to IMG and then
     ### try again:
     IMG=${DMG/%dmg/img}
     echo "Converting ${DMG} to ${IMG}"
     $DMG2IMG $DMG  >/dev/null
     if [ $? -ne 0 ]; then
        echo "Conversion of DMG to IMG failed. Exiting."
        exit 1;
     elif [ ! -e "$IMG" ]; then
        echo "No ${IMG} created. Exiting."
        exit 1;
     fi
     echo "Extracting content from ${IMG} with ${EXTRACT}"
# Depending on the version of 7z, it may extract either NoMachine/NoMachine.pkg or 4.hfs
     $EXTRACT x -bd -y $IMG  >/dev/null
     if [ $? -ne 0 ]; then
        echo "Extracting contect of $IMG with $EXTRACT failed too. Exiting."
        if [ -e "$IMG" ]; then /bin/rm -f $IMG; fi
        exit 1
     else 
# $IMG was a temp file, we do not need it anymore.
        /bin/rm -f $IMG
     fi
  fi
  ### Newer 7z extracts NoMachine/NoMachine.pkg while older 7z first extracts 4.hfs
  if [ -e 4.hfs ]; then 
     echo "Extracting content of 4.hfs which should include NoMachine/NoMachine.pkg"
     $EXTRACT x -bd -y 4.hfs  >/dev/null
     if [ $? -ne 0 ]; then
        echo "Extracting content of 4.hfs with $EXTRACT failed. Exiting."
        /bin/rm -f 4.hfs
        exit 1
     else
# 4.hfs was a temp file, we do not need it anymore.
        /bin/rm -f 4.hfs
        for i in {0..7}; do
#          echo "Removing $i.*"
           /bin/rm -rf $i.*
        done
     fi
  fi

  if [ -e NoMachine/NoMachine.pkg ]; then 
     /bin/mv NoMachine/NoMachine.pkg .
     /bin/rm -rf NoMachine/ 
  else
     echo "File NoMachine/NoMachine.pkg not found after extraction. Exiting."
     exit 1
  fi
  echo "Extracting nxclient.pkg and nxplayer.pkg dirs from NoMachine.pkg"
  $EXTRACT x -bd -y NoMachine.pkg  >/dev/null
  if [ $? -ne 0 ]; then
     echo "Extracting NoMachine.pkg with $EXTRACT failed. Exiting."
    /bin/rm -rf NoMachine.pkg Distribution Resources/ NoMachine.pkg \[TOC\].xml 
     exit 1
  fi
  /bin/rm -rf Distribution Resources/ NoMachine.pkg \[TOC\].xml 

#---
  echo -e "\nExtracting nxclient files from nxclient.pkg/Payload"
  if [ -e nxclient.pkg/Payload ]; then
     echo "Moving nxclient.pkg/Payload to ./Payload"
     /bin/mv nxclient.pkg/Payload .
  else
     echo "File nxclient.pkg/Payload not found after extraction. Exiting."
     exit 1
  fi
  echo "Extracting content of ./Payload with $EXTRACT"
  $EXTRACT x -bd -y Payload  >/dev/null
  if [ $? -ne 0 ]; then
     echo "Extracting content of ./Payload with $EXTRACT failed. Exiting."
     exit 1
  elif [ ! -e Payload~ ]; then 
     echo "./Payload~ not found after extracting ./Payload with $EXTRACT. Exiting."
     exit 1
  fi
  echo "Extracting content of ./Payload~ with $EXTRACT"
  $EXTRACT x -bd -y Payload~  >/dev/null
  if [ $? -ne 0 ]; then
     echo "Extracting ./Payload~ with $EXTRACT failed. Exiting."
     exit 1
  fi
  /bin/rm -rf Payload* nxclient.pkg

#---
  echo -e "\nExtracting nxplayer files from nxplayer.pkg/Payload"
  if [ -e nxplayer.pkg/Payload ]; then
     echo "Moving nxplayer.pkg/Payload to ./Payload"
     /bin/mv nxplayer.pkg/Payload .
  else
     echo "File nxplayer.pkg/Payload not found after extraction. Exiting."
     exit 1
  fi
  echo "Extracting content of ./Payload with $EXTRACT"
  $EXTRACT x -bd -y Payload  >/dev/null
  if [ $? -ne 0 ]; then
     echo "Extracting content of ./Payload with $EXTRACT failed. Exiting."
     exit 1
  elif [ ! -e Payload~ ]; then 
     echo "./Payload~ not found after extracting ./Payload with $EXTRACT. Exiting."
     exit 1
  fi
  echo "Extracting content of ./Payload~ with $EXTRACT"
  $EXTRACT x -bd -y Payload~  >/dev/null 
  if [ $? -ne 0 ]; then
     echo "Extracting content of ./Payload~ with $EXTRACT failed. Exiting."
     exit 1
  fi
  /bin/rm -rf Payload* nxplayer.pkg

#---
  ARCHIVE=nxplayer4macosx_${VER}.tgz
  echo -e "\nCreating ${CWD}/${ARCHIVE}"
  # NOTE: it is important to preserve the "Contents" level
  # because otherwise nxplayer does not start on MacOSX.
  /bin/mv Applications/NoMachine.app ./nxplayer4macosx
  /bin/rm -rf Applications
  cd nxplayer4macosx/Contents
  /bin/chmod -R a+x MacOS/ Frameworks/bin/
  cd ../../
  /bin/tar zcf ${CWD}/${ARCHIVE} nxplayer4macosx --remove-files

  echo -e "\nFile ${CWD}/${ARCHIVE} is created"
  echo 'Usage:'
  echo "   tar zxf ${ARCHIVE}"
  echo '   cd nxplayer4macosx/Contents/MacOS'
  echo '   ./nxplayer'

  exit
