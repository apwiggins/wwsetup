#!/bin/bash

scriptname=`basename $0 .sh`

#
# Uninstall if requested
if [ "$1" == "uninstall" ]; then
    echo "$scriptname INFO: Uninstalling the WorldWind Server..."
    if [ -d /usr/local/maps ]; then
        echo "   Removing directory '/usr/local/maps'..."
        sudo rm -Rf /usr/local/maps
    fi
    if [ -d /usr/local/worldwind ]; then
        echo "   Removing directory '/usr/local/worldwind'..."
        sudo rm -Rf /usr/local/worldwind
    fi
    if [ -d ./packages/worldwindserver ]; then
        echo "   Removing directory '~/packages/worldwindserver'..."
        sudo rm -Rfv ./packages/worldwindserver
    fi
    echo "$scriptname INFO: End."
    exit 0
fi

#
# Ensure the list of required packages exist
worldwindzip=~/Downloads/worldwind-1.5.1.zip

Packages=("${Packages[@]}" "$worldwindzip")

for package in ${Packages[@]}; do
    if [ ! -e $package ]; then
        MissingPackages=("${MissingPackages[@]}" "$package")
    fi
done

if [[ ${#MissingPackages[@]} > 0 ]]; then
    echo "$scriptname WARNING: ${#MissingPackages[@]} Missing package(s):"
    for package in ${MissingPackages[@]}; do
        echo "   $package"
    done
    echo "$scriptname Info: will attempt to download from the Internet..."
fi

# If missing file, then attempt to download from Internet
if [ ! -f "$worldwindzip" ]; then
	wget -P ~/Downloads wget https://github.com/NASAWorldWind/WorldWindJava/releases/download/v1.5.1/worldwind-1.5.1.zip
    if [ $? -ne 0 ]; then
        echo "$scriptname ERROR: downloading file! $worldwindzip"
        echo "$scriptname INFO: Terminated due to error!."
        exit 1
    fi
    echo "$scriptname INFO: missing file was downloaded! $worldwindzip"
fi


######################################################################
# At this point, all of the required packages exist and
# we will proceed with the installation.
######################################################################

#
# Begin installing...
echo "$scriptname INFO: Installation started..."

# Create the packages directory
mkdir ~/packages 2>/dev/null

#
# Install to use JDK7
echo "$scriptname INFO: Installing JDK7..."
sudo apt-get -y install ant openjdk-7-jdk openjdk-7-jre openjdk-7-doc openjdk-7-jre-headless unzip

#
# Configure worldwind to operate as a system service
echo "$scriptname INFO: Configure worldwind system service..."

# modified to use standard linux locations
sudo cp ./service/startWMS.sh /usr/local/bin/startWMS.sh
sudo chmod +x /usr/local/bin/startWMS.sh
#sudo ln -s /usr/local/worldwind/startWMS.sh /usr/local/bin/startWMS.sh

# create and register a standard linux service
sudo cp ./service/worldwind /etc/init.d/worldwind
sudo chmod +x /etc/init.d/worldwind
sudo update-rc.d worldwind defaults

#
# Build and install the worldwind server
echo "$scriptname INFO: Building the worldwind server..."
mkdir ~/packages/worldwindserver 2>/dev/null
cd ~/packages/worldwindserver
unzip -q $worldwindzip
ant build
ant servers.deployment

echo "$scriptname INFO: Installing the worldwind server (/usr/local/worldwind)..."
sudo mkdir /usr/local/worldwind 2>/dev/null
sudo cp -R servers-deployment/* /usr/local/worldwind

#
# Configure the server to host maps
echo "$scriptname INFO: Configure the server to host maps..."
sudo apt-get -y install gdal-bin

cd /usr/local/worldwind/WEB-INF
# modify file 'web.xml'
Count=$(cat web.xml | grep 'GDAL.Path" value=""' | wc -l)
if [ $Count -eq 1 ]; then
    sudo sed -i.ORIG 's|GDAL.Path" value=""|GDAL.Path" value="/usr/bin"|' web.xml
fi
# modify file 'wms.DataFileStore.xml'
Count=$(cat wms.DataFileStore.xml | grep '<location property="" wwDir="/usr/local/maps"' | wc -l)
if [ $Count -eq 0 ]; then
    sudo sed -i.ORIG '/<writeLocations>/a \\t<location property="" wwDir="/usr/local/maps" create="true"/>' wms.DataFileStore.xml
fi

# modify file 'wms.config.xml' - Adding configuration for Blue Marble map
cat << 'END_HEREDOC' > /tmp/bluemarble.sed
/<\/server>/a \
    <mapsource name="bmng200405" title="BlueMarbleNG 05/2004">\
        <description keywords="NASA; Blue Marble; Global Imagery; 2004">Nasa\'s BlueMarbleNG, 2004</description>\
        <root-dir>/usr/local/maps/bluemarble/bmng200405</root-dir>\
	<class>gov.nasa.worldwind.servers.wms.generators.BlueMarbleNG500MGenerator</class>\
        <property name="BlueMarble500M.defaultTime" value="200405"/>\
        <property name="BlueMarble500M.namingscheme.prefix" value="world.topo.bathy" />\
        <property name="BlueMarble500M.namingscheme.suffix" value="gtif" />\
        <property name="gov.nasa.worldwind.avkey.LastUpdateKey" value="2009-03-24 10:55:00" />\
    </mapsource>\
    <mapsource name="mergedSrtm" title="mergedSrtm">\
	<description keywords="mergedSrtm">mergedSrtm</description>\
	<root-dir>/usr/local/maps/srtm</root-dir>\
	<class>gov.nasa.worldwind.servers.wms.generators.CompoundElevationsGenerator</class>\
  	<mapsource name="srtm30" title="SRTM30 Plus">\
		<description keywords="SRTM30 Elevation">SRTM30 Elevation Data</description>\
		<root-dir>/usr/local/maps/srtm/srtm_1km</root-dir>\
		<class>gov.nasa.worldwind.servers.wms.generators.ElevationSrtm30</class>\
		<property name="gov.nasa.worldwind.avkey.MissingDataFlag" value="-9999" />\
 		<scale-hint min="0.012" max="0.008333330" />\
        </mapsource>\
        <mapsource name="srtm3" title="SRTM3 V4.1">\
        	<description keywords="SRTM3 V4.1 (Finished and filled)" />\
                <root-dir>/usr/local/maps/srtm/srtm_90m</root-dir>\
                <class>gov.nasa.worldwind.servers.wms.generators.ElevationSrtm3V4</class>\
                <property name="debug" value="ON" />\
                <property name="filenaming_format" value="%s%ssrtm_%02d_%02d.tif" />\
                <property name="gov.nasa.worldwind.avkey.MissingDataFlag" value="-9999" />\
                <property name="gov.nasa.worldwind.avkey.LastUpdateKey" value="2009-04-23 10:55:00" />\
                <scale-hint min="0.009" max="0.00083333" />\
        </mapsource>\
  </mapsource>\
END_HEREDOC

Count=$(cat wms.config.xml | grep '<mapsource name="bmng200405"' | wc -l)
if [ $Count -eq 0 ]; then
    sudo sed -i.ORIG -f /tmp/bluemarble.sed  wms.config.xml
fi
rm -f /tmp/bluemarble.sed

#
# Add the maps folders for the server

sudo mkdir -p /usr/local/maps 2>/dev/null
sudo mkdir /usr/local/maps/WorldWindInstalled 2>/dev/null

echo "$scriptname INFO: Installation Successfull!"
echo "$scriptname INFO: End."
exit 0

