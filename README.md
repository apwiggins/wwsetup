# World Wind Server Setup scripts

This set of customizable scripts download and install NASA's World Wind Server, the Blue Marble maps, and the Shuttle Radar Topology Mission (SRTM) terrain elevation data.  These scripts were developed to fill a need to have a geo-data server for a lab that is not connected to the Internet.

## Assumptions

- Build assumes that you have a fresh Ubuntu 14.04 server
- Server VM or hardware has 50-100 GB of space for map data; this setup takes less than 10 GB, but you'll probably want to add more
- You have 30-60 minutes available to complete the downloads and install
- Scripts create local tarballs of downloaded file packages for re-use; as good netizens, we're trying to be kind to the organizations that make their data freely available for use by not abusing their servers
- Scripts support headless operation
- An Ubuntu service wrapper is created to manage the worldwind service

### Start

Run the first script to download and install the NASA worldwind server software version 1.5.1. OpenJDK7 will be used as the JVM to run the service.
- ./postinstall-14.04-WorldWindServer.sh

Run the second script to download and install the Blue Marble geo-data maps
- ./postinstall-14.04-WorldWindServer-bluemarble.sh

Run the third script to download and install the SRTM elevation data
- ./postinstall-14.04-WorldWindServer-SRTM.sh

Finally, reboot the VM or hardware to do a clean start.

### File locations
- **server application files** - stored at /usr/local/worldwind
- **maps** - stored at /usr/local/maps
- **service wrapper** - stored at /etc/init.d/worldwind; service control using "sudo service worldwind (start|stop|reload|status)"
- **server logs** - stored at /var/log/worldwind.log
