#!/bin/bash
#-----------------------------------------------------------------------
# This script produces a no-install version of NX player for Windows 
# from respective NOMACHINE installer.
# It needs innoextract from https://constexpr.org/innoextract/
# Respective rpm and deb distributions are available.
#-----------------------------------------------------------------------

  CWD=$PWD

  echo -e "\nProducing no-install version of NOMACHINE player for Windows"

  ### Example: nomachine-enterprise-client_6.0.78_1.exe
  NXEXE=($(/bin/ls -tr -1 nomachine-enterprise-client_*.exe))
  if [[ ${#NXEXE[@]} -eq 0 ]]; then
     echo -e "\n *** No nomachine-enterprise-client installers for Windows found in $CWD"
     exit 1
  fi

### Choose the latest distribution:
  EXE=${NXEXE[-1]}
  echo "Found ${EXE}"
  VER=${EXE#nomachine-enterprise-client_}
  VER=${VER%.exe}
  VER=${VER/_*/}
  echo "NOMACHINE Windows installer version: ${VER}"

  EXTRACT=$(which innoextract 2>/dev/null)
  if [ -z "$EXTRACT" ]; then
     echo -e "\n *** No innoextract app in the system."
     exit 1
  fi

  ZIP=$(which zip 2>/dev/null)
  if [ -z "$ZIP" ]; then
     echo -e "\n *** No zip app in the system."
     exit 1
  fi

  echo "Extracting Windows nxplayer and nxclient using ${EXTRACT}"
  $EXTRACT --include app --silent --progress=0 $EXE
  if [ $? -ne 0 ]; then
     echo "Process $EXTRACT failed"
     exit 1
  elif [ ! -e 'app' ]; then
     echo "Folder 'app' not produced by $EXTRACT"
     exit 1
  fi
  /bin/mv app nxplayer4windows

  ARCHIVE=nxplayer4windows_${VER}.zip
  echo "Creating ${CWD}/${ARCHIVE}"
  $ZIP -mrq ${CWD}/${ARCHIVE} nxplayer4windows

  echo -e "\nFile ${CWD}/${ARCHIVE} is created"
  echo 'Usage:'
  echo "   unzip -x ${ARCHIVE}"
  echo '   cd nxplayer4windows\bin'
  echo '   nxplayer'

  exit
