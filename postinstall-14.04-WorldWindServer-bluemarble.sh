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
bmng200405gz=~/Downloads/bmng200405.tar.gz

Packages=("${Packages[@]}" "$worldwindzip")
Packages=("${Packages[@]}" "$bmng200405gz")

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
	wget -P ~/Downloads http://builds.worldwind.arc.nasa.gov/worldwind-releases/1.5/builds/worldwind-1.5.1.zip
    if [ $? -ne 0 ]; then
        echo "$scriptname ERROR: downloading file! $worldwindzip"
        echo "$scriptname INFO: Terminated due to error!."
        exit 1
    fi
    echo "$scriptname INFO: missing file was downloaded! $worldwindzip"
fi

# If missing file, then attempt to download from Internet
if [ ! -f "$bmng200405gz" ]; then
    # Generate list of files to be downloaded from the Internet
    Location="http://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73701"
    Files=("${Files[@]}" "$Location/world.topo.bathy.200405.3x5400x2700.png")
    Files=("${Files[@]}" "$Location/world.topo.bathy.200405.3x21600x10800.png")
    Files=("${Files[@]}" "$Location/world.topo.bathy.200405.3x21600x21600.A1.png")
    Files=("${Files[@]}" "$Location/world.topo.bathy.200405.3x21600x21600.A2.png")
    Files=("${Files[@]}" "$Location/world.topo.bathy.200405.3x21600x21600.B1.png")
    Files=("${Files[@]}" "$Location/world.topo.bathy.200405.3x21600x21600.B2.png")
    Files=("${Files[@]}" "$Location/world.topo.bathy.200405.3x21600x21600.C1.png")
    Files=("${Files[@]}" "$Location/world.topo.bathy.200405.3x21600x21600.C2.png")
    Files=("${Files[@]}" "$Location/world.topo.bathy.200405.3x21600x21600.D1.png")
    Files=("${Files[@]}" "$Location/world.topo.bathy.200405.3x21600x21600.D2.png")

    # Make a list of missing Internet files before downloading
    for file in ${Files[@]}; do
        nofile=$(wget --spider $file 2>&1 | grep -F 'Length: unspecified' | wc -l)
        if [ $nofile -eq 1 ]; then
            MissingFiles=("${MissingFiles[@]}" "$file")
        fi
    done

    # If any of the files are missing, terminate the script
    if [[ ${#MissingFiles[@]} > 0 ]]; then
        echo "$scriptname ERROR: missing file! $bmng200405gz"
        echo "$scriptname ERROR: The above missing file could not be generated due to"
        echo "$scriptname ERROR: following missing file(s) from the website:"
        for file in ${MissingFiles[@]}; do
            echo "   $file"
        done
        echo "$scriptname INFO: Terminated due to error!"
        exit 1
    fi

    # Proceed to download the files in order to generate the
    # required file "$bmng200405gz" 
	mkdir -p ~/Downloads/bm
    for file in ${Files[@]}; do
        wget -c -P ~/Downloads/bm $file
    done

    # Generate the required file $bmng200405gz
	cd ~/Downloads/bm
	tar zcvf $bmng200405gz *.png
    echo "$scriptname INFO: missing file was downloaded! $bmng200405gz"
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
sudo mkdir /usr/local/maps/WorldWindInstalled 2>/dev/null

#
# Adding the Blue Marble map
echo "$scriptname INFO: Adding map - Blue Marble..."
mkdir -p /tmp/src/maps/bluemarble/bmng200405
cd /tmp/src/maps/bluemarble/bmng200405
tar -xzf $bmng200405gz
if [ $? -ne 0 ]; then
    echo "$scriptname ERROR: cannot extract file! -> $bmng200405gz"
    echo "$scriptname INFO: Terminating due to error."
    exit 1
fi

sudo cp -Rv /tmp/src/maps/bluemarble /usr/local/maps
cd /usr/local/maps/bluemarble/bmng200405

# convert png files to gtif format
# each tile has a geo location which is added by the script commands below
echo "  (1/10) Translating file 'world.topo.bathy.200405.3x5400x2700.png'..."
if [ ! -f world.topo.bathy.200405.3x5400x2700.gtif ]; then
	sudo gdal_translate -of gtiff -a_srs epsg:4326 -a_ullr -180 90 180 -90 \
    	world.topo.bathy.200405.3x5400x2700.png \
    	world.topo.bathy.200405.3x5400x2700.gtif
fi
echo "  (2/10) Translating file 'world.topo.bathy.200405.3x21600x10800.png'..."
if [ ! -f world.topo.bathy.200405.3x21600x10800.gtif ]; then
	sudo gdal_translate -of gtiff -a_srs epsg:4326 -a_ullr -180 90 180 -90 \
    	world.topo.bathy.200405.3x21600x10800.png \
    	world.topo.bathy.200405.3x21600x10800.gtif
fi

echo "  (3/10) Translating file 'world.topo.bathy.200405.3x21600x21600.A1.png'..."
if [ ! -f world.topo.bathy.200405.3x21600x21600.A1.gtif ]; then
	sudo gdal_translate -of gtiff -a_srs epsg:4326 -a_ullr -180 90 -90 0 -co tiled=yes -co compress=lzw \
    	world.topo.bathy.200405.3x21600x21600.A1.png \
    	world.topo.bathy.200405.3x21600x21600.A1.gtif
fi

echo "  (4/10) Translating file 'world.topo.bathy.200405.3x21600x21600.A2.png'..."
if [ ! -f world.topo.bathy.200405.3x21600x21600.A2.gtif ]; then
	sudo gdal_translate -of gtiff -a_srs epsg:4326 -a_ullr -180 0 -90 -90 -co tiled=yes -co compress=lzw \
    	world.topo.bathy.200405.3x21600x21600.A2.png \
    	world.topo.bathy.200405.3x21600x21600.A2.gtif
fi

echo "  (5/10) Translating file 'world.topo.bathy.200405.3x21600x21600.B1.png'..."
if [ ! -f world.topo.bathy.200405.3x21600x21600.B1.gtif ]; then
	sudo gdal_translate -of gtiff -a_srs epsg:4326 -a_ullr -90 90 0 0 -co tiled=yes -co compress=lzw \
    	world.topo.bathy.200405.3x21600x21600.B1.png \
    	world.topo.bathy.200405.3x21600x21600.B1.gtif
fi

echo "  (6/10) Translating file 'world.topo.bathy.200405.3x21600x21600.B2.png'..."
if [ ! -f world.topo.bathy.200405.3x21600x21600.B2.gtif ]; then
	sudo gdal_translate -of gtiff -a_srs epsg:4326 -a_ullr -90 0 0 -90 -co tiled=yes -co compress=lzw \
	    world.topo.bathy.200405.3x21600x21600.B2.png \
	    world.topo.bathy.200405.3x21600x21600.B2.gtif
fi

echo "  (7/10) Translating file 'world.topo.bathy.200405.3x21600x21600.C1.png'..."
if [ ! -f world.topo.bathy.200405.3x21600x21600.C1.gtif ]; then
	sudo gdal_translate -of gtiff -a_srs epsg:4326 -a_ullr 0 90 90 0 -co tiled=yes -co compress=lzw \
    	world.topo.bathy.200405.3x21600x21600.C1.png \
    	world.topo.bathy.200405.3x21600x21600.C1.gtif
fi

echo "  (8/10) Translating file 'world.topo.bathy.200405.3x21600x21600.C2.png'..."
if [ ! -f world.topo.bathy.200405.3x21600x21600.C2.gtif ]; then
	sudo gdal_translate -of gtiff -a_srs epsg:4326 -a_ullr 0 0 90 -90 -co tiled=yes -co compress=lzw \
	    world.topo.bathy.200405.3x21600x21600.C2.png \
	    world.topo.bathy.200405.3x21600x21600.C2.gtif
fi

echo "  (9/10) Translating file 'world.topo.bathy.200405.3x21600x21600.D1.png'..."
if [ ! -f world.topo.bathy.200405.3x21600x21600.D1.gtif ]; then
	sudo gdal_translate -of gtiff -a_srs epsg:4326 -a_ullr 90 90 180 0 -co tiled=yes -co compress=lzw \
	    world.topo.bathy.200405.3x21600x21600.D1.png \
	    world.topo.bathy.200405.3x21600x21600.D1.gtif
fi

echo " (10/10) Translating file 'world.topo.bathy.200405.3x21600x21600.D2.png'..."
if [ ! -f world.topo.bathy.200405.3x21600x21600.D2.gtif ]; then
	sudo gdal_translate -of gtiff -a_srs epsg:4326 -a_ullr 90 0 180 -90 -co tiled=yes -co compress=lzw \
	    world.topo.bathy.200405.3x21600x21600.D2.png \
	    world.topo.bathy.200405.3x21600x21600.D2.gtif
fi

echo "$scriptname INFO: Installation Successfull!"
echo "$scriptname INFO: End."
exit 0

