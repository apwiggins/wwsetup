#!/bin/bash

scriptname=`basename $0 .sh`

# the bin2grd script requires the use of csh
if ! which csh > /dev/null; then
   echo -e "Required command csh not found! Installing..."
   sudo apt-get install csh
fi

# the bin2grd script requires the use of gdal_translate
if ! which GMT > /dev/null; then
   echo -e "Required  gdal utilities not found! Installing..."
   sudo apt-get install gdal-bin python-gdal gmt
fi

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
    if [ -d ~/packages/worldwindserver ]; then
        echo "   Removing directory '~/packages/worldwindserver'..."
        sudo rm -Rfv ~/packages/worldwindserver
    fi
    echo "$scriptname INFO: End."
    exit 0
fi

#
# Ensure the list of required packages exist
worldwindzip=~/Downloads/worldwind-1.5.1.zip
srtm30gz=~/Downloads/srtm30.tar.gz

Packages=("${Packages[@]}" "$worldwindzip")
Packages=("${Packages[@]}" "$srtm30gz")
#Packages=("${Packages[@]}" "$SRTM41gz")

echo "$scriptname Info: Generating package list from local and internet sources..."
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
    echo "$scriptname ERROR: file unavailable for $worldwindzip"
    echo "$scriptname INFO: run postinstall-12.04-WorldWindServer.sh first"
    echo "$scriptname INFO: to install the World Wind Server"
    exit 1    
fi

# If missing file, then attempt to download from Internet
if [ ! -f "$srtm30gz" ]; then
    # Generate list of files to be downloaded from the Internet
    Location="ftp://topex.ucsd.edu/pub/srtm30_plus/srtm30/data/"
    Files=("${Files[@]}" "$Location/e020n40.Bathymetry.srtm")
    Files=("${Files[@]}" "$Location/e020n90.Bathymetry.srtm")
    Files=("${Files[@]}" "$Location/e020s10.Bathymetry.srtm")
    Files=("${Files[@]}" "$Location/e060n40.Bathymetry.srtm")
    Files=("${Files[@]}" "$Location/e060n90.Bathymetry.srtm")
    Files=("${Files[@]}" "$Location/e060s10.Bathymetry.srtm")
    Files=("${Files[@]}" "$Location/e060s60.Bathymetry.srtm")
    Files=("${Files[@]}" "$Location/e100n40.Bathymetry.srtm")
    Files=("${Files[@]}" "$Location/e100n90.Bathymetry.srtm")
    Files=("${Files[@]}" "$Location/e100s10.Bathymetry.srtm")
    Files=("${Files[@]}" "$Location/e120s60.Bathymetry.srtm")
    Files=("${Files[@]}" "$Location/e140n40.Bathymetry.srtm")
    Files=("${Files[@]}" "$Location/e140n90.Bathymetry.srtm")
    Files=("${Files[@]}" "$Location/e140s10.Bathymetry.srtm")
    Files=("${Files[@]}" "$Location/w000s60.Bathymetry.srtm")
    Files=("${Files[@]}" "$Location/w020n40.Bathymetry.srtm")
    Files=("${Files[@]}" "$Location/w020n90.Bathymetry.srtm")
    Files=("${Files[@]}" "$Location/w020s10.Bathymetry.srtm")
    Files=("${Files[@]}" "$Location/w060n40.Bathymetry.srtm")
    Files=("${Files[@]}" "$Location/w060n90.Bathymetry.srtm")
    Files=("${Files[@]}" "$Location/w060s10.Bathymetry.srtm")
    Files=("${Files[@]}" "$Location/w060s60.Bathymetry.srtm")
    Files=("${Files[@]}" "$Location/w100n40.Bathymetry.srtm")
    Files=("${Files[@]}" "$Location/w100n90.Bathymetry.srtm")
    Files=("${Files[@]}" "$Location/w100s10.Bathymetry.srtm")
    Files=("${Files[@]}" "$Location/w120s60.Bathymetry.srtm")
    Files=("${Files[@]}" "$Location/w140n40.Bathymetry.srtm")
    Files=("${Files[@]}" "$Location/w140n90.Bathymetry.srtm")
    Files=("${Files[@]}" "$Location/w140s10.Bathymetry.srtm")
    Files=("${Files[@]}" "$Location/w180n40.Bathymetry.srtm")
    Files=("${Files[@]}" "$Location/w180n90.Bathymetry.srtm")
    Files=("${Files[@]}" "$Location/w180s10.Bathymetry.srtm")
    Files=("${Files[@]}" "$Location/w180s60.Bathymetry.srtm")
    
    # Make a list of missing Internet files before downloading
    for file in ${Files[@]}; do
        nofile=$(wget --spider $file 2>&1 | grep -F 'Length: unspecified' | wc -l)
        if [ $nofile -eq 1 ]; then
            MissingFiles=("${MissingFiles[@]}" "$file")
        fi
    done

    # If any of the files are missing, terminate the script
    if [[ ${#MissingFiles[@]} > 0 ]]; then
        echo "$scriptname ERROR: missing file! $srtm30gz"
        echo "$scriptname ERROR: The above missing file could not be generated due to"
        echo "$scriptname ERROR: following missing file(s) from the website:"
        for file in ${MissingFiles[@]}; do
            echo "   $file"
        done
        echo "$scriptname INFO: Terminated due to error!"
        exit 1
    fi

    # Proceed to download the files in order to generate the
    # required file "$srtm30gz" 
    echo "$scriptname INFO: Downloading 33 files from Internet to ~/Downloads/srtm30"
	mkdir -p ~/Downloads/srtm_1km
    for file in ${Files[@]}; do
        wget -c -P ~/Downloads/srtm_1km $file
    done

    # Generate the required file $srtm30gz
    echo "$scriptname INFO: generating elevation data tarball"
	cd ~/Downloads/srtm_1km
	tar zcvf $srtm30gz *.srtm
    echo "$scriptname INFO: missing file was downloaded! $srtm30gz"
fi

######################################################################
# At this point, all of the required packages exist and
# we will proceed with the installation.
######################################################################

#
# Add the maps for the server
echo "$scriptname INFO: Installing maps in directory '/usr/local/maps'..."

sudo mkdir -p /usr/local/maps 2>/dev/null

# for future installation of generated map tiles by other scripts
sudo mkdir -p /usr/local/maps/WorldWindInstalled 2>/dev/null

#
# Adding the SRTM30 elevation
echo "$scriptname INFO: Adding elevation - SRTM30..."
mkdir -p /tmp/src/maps/srtm/srtm_1km
cd /tmp/src/maps/srtm/srtm_1km
tar -xzf $srtm30gz
if [ $? -ne 0 ]; then
    echo "$scriptname ERROR: cannot extract file! -> $srtm30gz"
    echo "$scriptname INFO: Terminating due to error."
    exit 1
fi

sudo cp ~/Subversion/itn/scripts/worldwindscripts/bin2grd /usr/local/bin
sudo cp ~/Subversion/itn/scripts/worldwindscripts/srtm-bin2grd.sh /usr/local/bin
sudo chmod +x /usr/local/bin/bin2grd
sudo chmod +x /usr/local/bin/srtm-bin2grd.sh

# convert srtm files to gtif format for the Digital Elevation Map (DEM)
# each tile has a geo location which is added by the script commands below

echo "Translating 33 files to WorldWind GeoTIFF format ..."
/usr/local/bin/srtm-bin2grd.sh

# remove interim products from conversions
rm *.nc.tif
rm *.nc
rm *.srtm

# copy final GeoTIFF DEM product to WorldWind maps folder
sudo cp -Rv /tmp/src/maps/srtm /usr/local/maps

echo "$scriptname INFO: Installation Successfull!"
echo "$scriptname INFO: End."
exit 0
