

prefix=CESM1.2_CAM5_CN_PD_lowalbedo
gridname=NHEM20
grid=${WORK}/datasets_main/gengrids/CDO_grid_NHEM_20.0km.nc
pop_file=${WORK}/datasets_main/CESM/CESM1.2_CAM5_CN_PD_lowalbedo_Ute/TandS_b.e12.B2000C5_CN.f19_g16.PD.B4.pop.h.0087to0186_clim.nc
CAM_file=${WORK}/datasets_main/CESM/CESM1.2_CAM5_CN_PD_lowalbedo_Ute/b.e12.B2000C5_CN.f19_g16.PDalb.B4.cam.h0.0301to0400_clim.nc
TempStdDevFile=${WORK}/datasets_main/CESM/CESM1.2_CAM5_CN_PD_lowalbedo_Ute/TREFHT_b.e12.B2000C5_CN.f19_g16.PDalb.B4.cam.h1.0301to0400_std.nc

heatflux_file=${WORK}/datasets_main/heatflux/heatflx_GRN_20km.nc
topography_file=${WORK}/datasets_main/ETOPO/ETOPO1_GRN_20km_polar.nc
oceankill_file=${WORK}/datasets_main/oceankillmask/GRN_ocean_kill_20km.nc


$(prefix)_CAM_$(gridname)km.nc $(prefix)_referenceHeight_$(gridname)km.nc : $(CAM_file) $(TempStdDevFile) $(grid)
	./preprocess_CESM.sh $(CAM_file) $(TempStdDevFile) $(grid) $(gridname) $(prefix)

$(prefix)_ocean_$(gridname).nc : $(pop_file) $(grid)
	./preprocess_ocean.sh $(pop_file) $(grid) $@

$(prefix)_4PISM_$(gridname)km.nc: $(prefix)_CAM_$(gridname)km.nc $(prefix)_ocean_$(gridname).nc  $(topography_file) $(heatflux_file)
	# oceankillmask has no lat_bnds and lon_bnds and so it can not easily be merged.
	# I could not add those in the mk_ocean_kill_mask.py script so far...

	cdo -O merge $(prefix)_CAM_$(gridname)km.nc $(prefix)_ocean_$(gridname).nc  $(topography_file) $(heatflux_file) $@
	./fixup_time.py $@

clean:
	rm $(prefix)_CAM_$(gridname)km.nc $(prefix)_referenceHeight_$(gridname)km.nc $(prefix)_ocean_$(gridname).nc $(prefix)_4PISM_$(gridname)km.nc
