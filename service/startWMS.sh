#! /bin/bash
#
#
#
WWDIR=/usr/local/worldwind
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib

cd $WWDIR

java -Xmx512M -server -cp lib/worldwind-servers.jar:lib/worldwind.jar:lib/jogl.jar:.: \
     -Djava.library.path='pwd'/lib  \
     -Djava.awt.headless=true \
     -Dsun.java2d.noddraw=true \
     -Djava.util.logging.config.file=wms.logging.properties \
     gov.nasa.worldwind.servers.app.ApplicationServerLauncher 2>/var/log/worldwind.log >/var/log/out.log &
echo $! >/var/run/wms.pid
echo "logging at /var/log/worldwind.log"
