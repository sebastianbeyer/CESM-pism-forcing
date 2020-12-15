#!/usr/bin/env python3

import numpy as np
from netCDF4 import Dataset
import argparse

parser = argparse.ArgumentParser(
    description=
    'Change time variable in netcdf to be a climatology forcing (one year)')
parser.add_argument('netcdf')
args = parser.parse_args()

secPerYear =  365.25 * 24 * 3600
secPerYear =  365.00 * 24 * 3600

# secPerMonth = 60 * 60 * 24 * 30
secPerMonth = secPerYear / 12
timeMonths = np.arange(12)
timeSecs = timeMonths * secPerMonth
boundsMonths = np.array([[start, start + 1] for start in timeMonths])
boundsSecs = boundsMonths * secPerMonth

rootgrp = Dataset(args.netcdf, "r+")

bnds_dim="nv"
if bnds_dim not in list(rootgrp.dimensions.keys()):
    rootgrp.createDimension(bnds_dim, 2)

nc_time = rootgrp.variables['time']
nc_time[:] = timeSecs

print("creating time bounds var")
time_dim="time"
bnds_var_name = "time_bnds"
if bnds_var_name not in rootgrp.variables:
    nc_time_bounds = rootgrp.createVariable(
        bnds_var_name, "d", dimensions=(time_dim, bnds_dim)
    )
else:
    nc_time_bounds = rootgrp.variables[bnds_var_name]

nc_time_bounds[:] = boundsSecs
print("done")
nc_time.bounds = 'time_bnds'
nc_time.units = 'seconds since 1-1-1'

rootgrp.close()
