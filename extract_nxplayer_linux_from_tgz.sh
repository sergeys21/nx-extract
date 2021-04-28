#!/bin/bash
#-----------------------------------------------------------------------
# This script produces a no-install versions of NX player for Linux 
# from respective NOMACHINE installers packaged as .tar.gz
#-----------------------------------------------------------------------

# DEBUG=1
  if [ "$DEBUG" == "0" ]; then DEBUG=''; fi

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
     OUT=$($TAR zxf $TGZ NX/etc/NX/player/packages/nxclient.tar.gz NX/etc/NX/player/packages/nxplayer.tar.gz --strip-components 5)
     if [ $? -ne 0 ]; then
        if [ -n "$DEBUG" ]; then echo -e "$OUT"; fi
        echo "Extracting failed. Exiting."
        exit 1
     fi
     if [ -n "$DEBUG" ]; then echo -e "$OUT"; read -rsp $'Press any key to continue...\n' -n1 key; fi

     echo "Unpacking $BT nxclient.tar.gz"
     OUT=$($TAR zxf nxclient.tar.gz)
     if [ $? -ne 0 ]; then
        if [ -n "$DEBUG" ]; then echo -e "$OUT"; fi
        echo "Unpacking failed. Exiting."
        exit 1
     fi
     if [ -n "$DEBUG" ]; then echo -e "$OUT"; read -rsp $'Press any key to continue...\n' -n1 key; fi

     echo "Unpacking $BT nxplayer.tar.gz"
     OUT=$($TAR zxf nxplayer.tar.gz)
     if [ $? -ne 0 ]; then
        if [ -n "$DEBUG" ]; then echo -e "$OUT"; fi
        echo "Unpacking failed. Exiting."
        exit 1
     fi
     if [ -n "$DEBUG" ]; then echo -e "$OUT"; read -rsp $'Press any key to continue...\n' -n1 key; fi

     /bin/rm -f nxclient.tar.gz nxplayer.tar.gz
     /bin/mv NX nxplayer4linux

     echo '#!/bin/bash'              > startnxplayer.sh
     echo ' cd nxplayer4linux/bin'  >> startnxplayer.sh
     echo ' ./nxplayer &'           >> startnxplayer.sh
     chmod a+rx  startnxplayer.sh 

     ARCHIVE=nxplayer4linux_${VER}_${BT}.tgz
     echo "Creating ${CWD}/${ARCHIVE} with ${TAR}"
     OUT=$($TAR zcf ${CWD}/${ARCHIVE} nxplayer4linux startnxplayer.sh --remove-files)
     if [ $? -ne 0 ]; then
        if [ -n "$DEBUG" ]; then echo -e "$OUT"; fi
        echo "Creating ${CWD}/${ARCHIVE} failed. Exiting."
        exit 1
     fi
     if [ -n "$DEBUG" ]; then echo -e "$OUT"; read -rsp $'Press any key to continue...\n' -n1 key; fi

     echo -e "\nFile ${CWD}/${ARCHIVE} is created"
     echo 'Usage:'
     echo "   tar zxf ${ARCHIVE}"
     echo '   ./startnxplayer.sh'

  done
  exit
