#!/bin/bash
#-----------------------------------------------------------------------
# This script produces a no-install versions of NX player for Linux 
# from respective NOMACHINE installers packaged as .tar.gz
#-----------------------------------------------------------------------

  CWD=$PWD

  TAR=$(which tar 2>/dev/null)
  if [ -z "$TAR" ]; then
     echo -e "\n *** No tar app in the system."
     exit 1
  fi

# TARGETS=(i686 x86_64)
  TARGETS=(x86_64)
  for BT in ${TARGETS[@]}; do
     echo -e "\nProducing ${BT} no-install version of NOMACHINE player for Linux"

     ### Example: nomachine-enterprise-client_6.0.66_2_x86_64.tar.gz
     NXTGZ=($(/bin/ls -tr -1 nomachine-enterprise-client_*_${BT}.tar.gz))
     if [[ ${#NXTGZ[@]} -eq 0 ]]; then
        echo -e "\n *** No nomachine-enterprise-client TGZ found."
        continue
     fi

### Choose the latest distribution:
     TGZ=${NXTGZ[-1]}
     echo "Found ${TGZ}"
     VER=${TGZ#nomachine-enterprise-client_}
     VER=${VER%_${BT}.tar.gz}
     VER=${VER/_*/}
     echo "$BT-version ${VER}"

     echo "Extracting nxclient.tar.gz and nxplayer.tar.gz from $TGZ"
     $TAR zxf $TGZ NX/etc/NX/player/packages/nxclient.tar.gz NX/etc/NX/player/packages/nxplayer.tar.gz --strip-components 5
     echo "Unpacking $BT nxclient.tar.gz"
     $TAR zxf nxclient.tar.gz
     echo "Unpacking $BT nxplayer.tar.gz"
     $TAR zxf nxplayer.tar.gz 
     /bin/rm -f nxclient.tar.gz nxplayer.tar.gz
     /bin/mv NX nxplayer4linux

     ARCHIVE=nxplayer4linux_${VER}_${BT}.tgz
     echo "Creating ${CWD}/${ARCHIVE}"
     $TAR zcf ${CWD}/${ARCHIVE} nxplayer4linux --remove-files

     echo -e "\nFile ${CWD}/${ARCHIVE} is created"
     echo 'Usage:'
     echo "   tar zxf ${ARCHIVE}"
     echo '   cd nxplayer4linux/bin/'
     echo '   ./nxplayer'

  done
  exit
