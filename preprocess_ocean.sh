#!/usr/bin/env bash

set -e

pop_file=$1
grid=$2
out_file=$3

# select levels up to a depth of ~200m and average over them. Levels were checked using
# `cdo showlevel`
# renaming variables for cdo to recognize them for remapping...
cdo \
  -chname,TLAT,lat \
  -chname,TLONG,lon \
  -vertmean \
  -sellevel,500,1500,2500,3500,4500,5500,6500,7500,8500,9500,10500,11500,12500,13500,14500,15500,16509.8398,17547.9043,18629.127,19766.0273 $pop_file TMP_ocean_top200avg.nc

ncrename -d nlon,lon TMP_ocean_top200avg.nc
ncrename -d nlat,lat TMP_ocean_top200avg.nc

# need to remap from the pop2 grid!!
/$WORK/datasets/remap_pop2/regrid_ocean.sh TMP_ocean_top200avg.nc TMP_ocean_top200avg_latlon.nc

cdo -b F64 -f nc4c remapycon,$grid TMP_ocean_top200avg_latlon.nc TMP_ocean_polar.nc

cdo \
  -chname,SALT,salinity_ocean \
  -chname,TEMP,theta_ocean \
  -setattribute,TEMP@units="Kelvin" \
  -addc,273.15 \
  TMP_ocean_polar.nc TMP_ocean_polar_units.nc

ncatted -O -a standard_name,theta_ocean,o,c,"theta_ocean" TMP_ocean_polar_units.nc
ncatted -O -a long_name,theta_ocean,o,c,"potential temperature of the adjacent ocean" TMP_ocean_polar_units.nc
ncatted -O -a standard_name,salinity_ocean,o,c,"salinity_ocean" TMP_ocean_polar_units.nc
ncatted -O -a long_name,salinity_ocean,o,c,"ocean salinity" TMP_ocean_polar_units.nc


# clean up
mv TMP_ocean_polar_units.nc $out_file
rm TMP_ocean_polar.nc
rm TMP_ocean_top200avg.nc
rm TMP_ocean_top200avg_latlon.nc
