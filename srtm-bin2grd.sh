#!/bin/bash
/usr/local/bin/bin2grd e020n40.Bathymetry.srtm  020  060 -10  40 
/usr/local/bin/bin2grd e020n90.Bathymetry.srtm  020  060  40  90 
/usr/local/bin/bin2grd e020s10.Bathymetry.srtm  020  060 -60 -10 
/usr/local/bin/bin2grd e060n40.Bathymetry.srtm  060  100 -10  40 
/usr/local/bin/bin2grd e060n90.Bathymetry.srtm  060  100  40  90 
/usr/local/bin/bin2grd e060s10.Bathymetry.srtm  060  100 -60 -10 
/usr/local/bin/bin2grd e100n40.Bathymetry.srtm  100  140 -10  40 
/usr/local/bin/bin2grd e100n90.Bathymetry.srtm  100  140  40  90 
/usr/local/bin/bin2grd e100s10.Bathymetry.srtm  100  140 -60 -10 
/usr/local/bin/bin2grd e140n40.Bathymetry.srtm  140  180 -10  40 
/usr/local/bin/bin2grd e140n90.Bathymetry.srtm  140  180  40  90 
/usr/local/bin/bin2grd e140s10.Bathymetry.srtm  140  180 -60 -10 
/usr/local/bin/bin2grd w020n40.Bathymetry.srtm -020  020 -10  40 
/usr/local/bin/bin2grd w020n90.Bathymetry.srtm -020  020  40  90 
/usr/local/bin/bin2grd w020s10.Bathymetry.srtm -020  020 -60 -10 
/usr/local/bin/bin2grd w060n40.Bathymetry.srtm -060 -020 -10  40 
/usr/local/bin/bin2grd w060n90.Bathymetry.srtm -060 -020  40  90 
/usr/local/bin/bin2grd w060s10.Bathymetry.srtm -060 -020 -60 -10 
/usr/local/bin/bin2grd w100n40.Bathymetry.srtm -100 -060 -10  40 
/usr/local/bin/bin2grd w100n90.Bathymetry.srtm -100 -060  40  90 
/usr/local/bin/bin2grd w100s10.Bathymetry.srtm -100 -060 -60 -10 
/usr/local/bin/bin2grd w140n40.Bathymetry.srtm -140 -100 -10  40 
/usr/local/bin/bin2grd w140n90.Bathymetry.srtm -140 -100  40  90 
/usr/local/bin/bin2grd w140s10.Bathymetry.srtm -140 -100 -60 -10 
/usr/local/bin/bin2grd w180n40.Bathymetry.srtm -180 -140 -10  40 
/usr/local/bin/bin2grd w180n90.Bathymetry.srtm -180 -140  40  90 
/usr/local/bin/bin2grd w180s10.Bathymetry.srtm -180 -140 -60 -10 
/usr/local/bin/bin2grd w180s60.Bathymetry.srtm -180 -120 -90 -60 
/usr/local/bin/bin2grd w120s60.Bathymetry.srtm -120 -060 -90 -60 
/usr/local/bin/bin2grd w060s60.Bathymetry.srtm -060  000 -90 -60 
/usr/local/bin/bin2grd w000s60.Bathymetry.srtm  000  060 -90 -60 
/usr/local/bin/bin2grd e060s60.Bathymetry.srtm  060  120 -90 -60 
/usr/local/bin/bin2grd e120s60.Bathymetry.srtm  120  180 -90 -60 

for file in `ls *.nc` 
do 
        gdal_translate -co TILED=yes -a_srs EPSG:4326 -ot Int16 -of GTiff $file $file.tif 

done 

# a goofy rename to match a typo in Worldwind Server code
rename 's/Bathymetry.srtm.nc.tif/Bathmetry.tif/g' ./*
