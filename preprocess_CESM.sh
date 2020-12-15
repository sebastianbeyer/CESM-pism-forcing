#!/usr/bin/env bash

set -e 
set -x

CAMFile=$1
TempStdDevFile=$2
grid=$3
res=$4
prefix=$5


SPY=31536000 # 365_day
SPD=86400

ncks -O -v PRECL,PRECC,TREFHT,PHIS,lat,lon ${CAMFile} ${prefix}_CAM_vars.nc
cdo -b F64 -f nc4c remapbil,$grid ${prefix}_CAM_vars.nc ${prefix}_CAM_${res}km.nc

rm ${prefix}_CAM_vars.nc

ncap2 -O -s "precipitation=('PRECL'+'PRECC')*$SPY * 1000" ${prefix}_CAM_${res}km.nc TMP_${prefix}_CAM_${res}km.nc
mv TMP_${prefix}_CAM_${res}km.nc ${prefix}_CAM_${res}km.nc

ncatted -O -a units,precipitation,o,c,"kg m-2 year-1" ${prefix}_CAM_${res}km.nc
ncatted -O -a long_name,precipitation,o,c,"mean monthly precipitation rate" ${prefix}_CAM_${res}km.nc

ncrename -O -v TREFHT,air_temp ${prefix}_CAM_${res}km.nc
ncatted -O -a units,air_temp,o,c,"Kelvin" ${prefix}_CAM_${res}km.nc
ncatted -O -a standard_name,air_temp,o,c,"air_temp" ${prefix}_CAM_${res}km.nc


## reference height
ncap2 -O -s "referenceHeight=PHIS/9.81" ${prefix}_CAM_${res}km.nc ${prefix}_referenceHeight_${res}km.nc
ncatted -O -a units,referenceHeight,o,c,"m" ${prefix}_referenceHeight_${res}km.nc
ncatted -O -a standard_name,referenceHeight,o,c,"surface_altitude" ${prefix}_referenceHeight_${res}km.nc

## clean up a little
ncks -O -v precipitation,air_temp,lat,lon ${prefix}_CAM_${res}km.nc TEMP_${prefix}_CAM_${res}km.nc
mv TEMP_${prefix}_CAM_${res}km.nc ${prefix}_CAM_${res}km.nc


# standard deviation
cdo -b F64 -f nc4c remapbil,$grid $TempStdDevFile ${prefix}_airTempStdDev_${res}km.nc
ncrename -O -v TREFHT,air_temp_sd ${prefix}_airTempStdDev_${res}km.nc
ncatted -O -a units,air_temp_sd,o,c,"Kelvin" ${prefix}_airTempStdDev_${res}km.nc
ncatted -O -a long_name,air_temp_sd,o,c,"air temperature standard deviation" ${prefix}_airTempStdDev_${res}km.nc

cdo -O merge ${prefix}_CAM_${res}km.nc ${prefix}_airTempStdDev_${res}km.nc ${prefix}_CAM_wtempStdDev_${res}km.nc
mv ${prefix}_CAM_wtempStdDev_${res}km.nc ${prefix}_CAM_${res}km.nc 
rm ${prefix}_airTempStdDev_${res}km.nc




# clean up


