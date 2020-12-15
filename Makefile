

prefix=takasumi
gridname=NHEM20
grid=${WORK}/datasets_main/gengrids/CDO_grid_NHEM_20.0km.nc
pop_file=${WORK}/datasets_main/CESM/CESM_PI_GMD2020EXCPL_1stSPINUP/TandS_B1850BPRP.forpub2018.01.hlrn.pop.h.0291to0300_clim.nc
CAM_file=${WORK}/datasets_main/CESM/CESM_PI_GMD2020EXCPL_1stSPINUP/B1850BPRP.forpub2018.01.hlrn.cam.h0.0291to0300_clim.nc
TempStdDevFile=${WORK}/datasets_main/CESM/CESM_PI_GMD2020EXCPL_1stSPINUP/TREFHT_B1850BPRP.forpub2018.01.hlrn.cam.h1.0291to0300_std.nc

heatflux_file=${WORK}/datasets_main/heatflux/heatflx_NHEM_20km.nc
topography_file=${WORK}/datasets_main/ETOPO/ETOPO1_NHEM_20km_polar.nc
oceankill_file=${WORK}/datasets_main/oceankillmask/NHEM_ocean_kill_20km.nc

$(prefix)_4PISM_$(gridname)km.nc: $(prefix)_CAM_$(gridname)km.nc $(prefix)_ocean_$(gridname)km.nc  $(topography_file) $(heatflux_file)
	# oceankillmask has no lat_bnds and lon_bnds and so it can not easily be merged.
	# I could not add those in the mk_ocean_kill_mask.py script so far...

	cdo -O merge $(prefix)_CAM_$(gridname)km.nc $(prefix)_ocean_$(gridname)km.nc  $(topography_file) $(heatflux_file) $@
	./fixup_time.py $@

$(prefix)_CAM_$(gridname)km.nc $(prefix)_referenceHeight_$(gridname)km.nc: $(CAM_file) $(TempStdDevFile) $(grid)
	./preprocess_CESM.sh $(CAM_file) $(TempStdDevFile) $(grid) $(gridname) $(prefix)

$(prefix)_ocean_$(gridname)km.nc: $(pop_file) $(grid)
	./preprocess_ocean.sh $(pop_file) $(grid) $@


clean:
	rm $(prefix)_CAM_$(gridname)km.nc $(prefix)_referenceHeight_$(gridname)km.nc $(prefix)_ocean_$(gridname).nc $(prefix)_4PISM_$(gridname)km.nc
