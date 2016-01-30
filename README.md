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

Run the first script to download and install the NASA WorldWind Server software version 1.5.1. OpenJDK7 will be used as the JVM to run the service.
- ./postinstall-14.04-WorldWindServer.sh OR
- ./postinstall-14.04-WorldWindServer2.0.sh (for WorldWindServer version 2.0.0)

Run the second script to download and install the Blue Marble geo-data maps
- ./postinstall-14.04-WorldWindServer-bluemarble.sh (1.5.1 only)

Run the third script to download and install the SRTM elevation data
- ./postinstall-14.04-WorldWindServer-SRTM.sh (1.5.1 only)

Finally, reboot the VM or hardware to do a clean start.

### File locations
- **server application files** - stored at /usr/local/worldwind
- **maps** - stored at /usr/local/maps
- **service wrapper** - stored at /etc/init.d/worldwind; service control using "sudo service worldwind (start|stop|reload|status)"
- **server logs** - stored at /var/log/worldwind.log

## License
The MIT License (MIT)

Copyright (c) [2015] [Phil Wiggins]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
