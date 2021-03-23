# nx-extract
Extract no-install NX players from installation packages for Linux, MacOSX and Windows

These Linux scripts help to extract no-install version of free NOMACHINE NX player from the installers freely available at the NOMACHINE website. The issue is that some NX users cannot run the NX installer because they do not have administrative rights on a computer. Lately NOMACHINE started providing a browser version of NX player which does not require an installer, but not all NX servers will serve browser login as it requires an additional port in the firewall and a certain version of the player.
The scripts presented here are bash scripts running on Linux. For extracting NX player for Windows one additionally needs the "innoextract" app from https://constexpr.org/innoextract/ and for extracting NX player for MacOS one needs "7z" from the p7zip package (http://p7zip.sourceforge.net) and "dmg2img" from http://vu1tur.eu.org/dmg2img. RPM and DEB packages of these tools can be easily found.
To produce no-install NX players, one needs to download the installation packages from https://www.nomachine.com and then execute the scripts in the download directory.
