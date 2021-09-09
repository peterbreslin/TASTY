; docformat = 'rst'
;+
;   Providing the save file for the results obtained from trim_tsis_sorce_data, this routine will
;   make various plots displaying different statistics for both SORCE and TSIS.
;
; :Author:
;     Peter Breslin
;
; :Examples:
; ::
;     result_savefile='result_20200703.sav'
;     plotting=tasty_plots(result_savefile, "graph", timePeriod="solar_min", "mean_irrad")
;-

;+
; :Params:
;    result_savefile : in, required, type=string
;      The filename of the IDL savefile containing the output from the function trim_tsis_sorce_data.pro
;    type : in, required, type=string
;      The type of plot wanted (options = "graph" or "img")
;    statistic : in, required, type=string
;      The statistic to be plotted: 
;       - For type eq "graph" and timePeriod eq "overlap" or "solar_min", input statistic as 
;         'mean_irrad', 'sdev_irrad', 'rdev_irrad', 'abs_irrad', or 'irrad_ratio'
;       - For type eq "img" and timePeriod eq "overlap", input statistic as 'irrad', 'avg28', 
;         'sdev28', or 'avg28_ratio'
;       - For type eq "img" and timePeriod eq "solar_min", input statistic as 'irrad', 'sdev_irrad',
;         or 'irrad_ratio'
;
; :Keywords:
;    timePeriod : in, not required, type=string
;      Options are "overlap" or "solar_min", if keyword not set then overlap is default
;    range : in, not required, type=array
;      The wavelength range (x-axis range), if keyword not set then default is 240-2400nm
;
; :Returns:
;     A plot of the specified parameters
;
function tasty_plots, result_savefile, type, timePeriod=timePeriod, range=range, statistic

  if (n_elements(result_savefile) eq 0 || strlen(result_savefile) eq 0) then begin
    doc_library,'tasty_plots'
    print,'*** Missing filenames'
    return,-1
  endif
  
  
  restore, result_savefile
  
  ;Declaring variables 
  graph=0
  img=0
  overlap=0
  solar_min=0
  mean_irrad=0
  sdev_irrad=0
  rdev_irrad=0
  abs_irrad=0
  irrad_ratio=0
  irrad=0
  avg28=0
  sdev28=0
  avg28_ratio=0
  range=[]


  ;If timePeriod keyword not set, overlap period will be used
  if not keyword_set(timePeriod) then timePeriod="overlap"
  ;If wv_range keyword not set, the whole range will be used
  if not keyword_set(range) then range=[240.0,2400.0]


  ;Validating inputs
  if type eq "graph" then graph=1 else if type eq "img" then img=1 else message, /info, "Input must be 'graph' or 'img' for plot type"
  if timePeriod eq "overlap" then overlap=1 else if timePeriod eq "solar_min" then solar_min=1 else message, /info, "Input must be 'overlap' or 'solar_min' for time period"
  
  if isa(range, /array) then begin
    if (min(range ge 240.0)) or (max(range le 2400.0)) then begin
      range=range
    endif else message, /info, "Input out of wavelength range"  
  endif else message, /info, "Wavelength range must be an array"
  
  if type eq "graph" then begin
    if isa(statistic, /string) then begin
      if statistic eq 'mean_irrad' then mean_irrad=1 else if statistic eq 'sdev_irrad' then sdev_irrad=1 $
        else if statistic eq 'rdev_irrad' then rdev_irrad=1 else if statistic eq 'abs_irrad' then abs_irrad=1 $
        else if statistic eq 'irrad_ratio' then irrad_ratio=1 else message, /info, $
        "Input must be either 'mean_irrad', 'sdev_irrad', 'rdev_irrad', 'abs_irrad' or 'irrad_ratio' for statistic"
    endif else message, /info, "Statistic must be a string"
  endif
  
  if type eq "img" then begin
    if isa(statistic, /string) then begin
      if statistic eq 'irrad' then irrad=1 else if statistic eq 'avg28' then avg28=1 $
      else if statistic eq 'sdev28' then sdev28=1 else if statistic eq 'avg28_ratio' then avg28_ratio=1 $
      else if statistic eq 'irrad_ratio' then irrad_ratio=1 else if statistic eq 'sdev_irrad' then sdev_irrad=1 $
      else message, /info, "Input must be either 'irrad', 'avg28', 'sdev28', or 'avg28_ratio' for statistic"
    endif else message, /info, "Statistic must be a string"
  endif
  
 
  ;Begin plotting ---> overlap
  xticks=[400:2400:400]
  lticks=[240,300,400,500,700,1000,2000]
  
  if graph then begin
    
    if overlap and mean_irrad then begin
      s=plot(result.ref_waves, result.sorce.mean_irrad, /xst)
      s.color='r'  
      s.xtitle='Wavelength (nm)'
      s.ytitle='Irradiance (W/m$^2$/nm)'
      s.title='Average Irradiance for the Overlap Period (2018-03-27 to 2020-02-25)' 
      s.xtickvalues=lticks
      s.xlog=1 
      s.name='SORCE V27.v276'
      s.xticklen=0.025 
      s.yticklen=0.015
      s.xrange=range
      s.font_size=18    
      
      t=plot(result.ref_waves, result.tsis.mean_irrad, /xst, /over)
      t.color='b'
      t.xlog=1 
      t.name='TSIS V04'
      
      leg=legend(target=[s,t], font_size=16)
      ;s.save, "mean_irrad.png"
    endif
    
    if overlap and sdev_irrad then begin
      s=plot(result.ref_waves, result.sorce.mean_std, /xst)
      s.color='r'
      s.xtitle='Wavelength (nm)'
      s.ytitle='Standard Deviation (W/m$^2$/nm)'
      s.title='Standard Deviation of the Average Irradiance for the Overlap Period (2018-03-27 to 2020-02-25)'
      s.xtickvalues=lticks
      s.xlog=1 
      s.name='SORCE V27.v276' 
      s.xticklen=0.025 
      s.yticklen=0.015
      s.xrange=range
      s.font_size=18
      
      t=plot(result.ref_waves, result.tsis.mean_std, /xst, /over)
      t.color='b'
      t.name='TSIS V04'
      
      leg=legend(target=[s,t], font_size=16)    
      ;s.save, "sdev_irrad.png"
    endif
    
    if overlap and rdev_irrad then begin
      rticks=[200:2400:100]
      s=plot(result.ref_waves, (result.sorce.mean_std/result.sorce.mean_irrad*100), /xst)
      s.color='r' 
      s.xtitle='Wavelength (nm)'
      s.ytitle='Percentage (%)'
      s.title='Relative Standard Deviation (SDEV/MEAN*100) for the Overlap Period (2018-03-27 to 2020-02-25)'
      s.xlog=0
      s.xtickvalues=rticks
      s.ylog=1
      s.name='SORCE V27.v276' 
      s.xticklen=0.025
      s.yticklen=0.015
      s.xrange=range
      s.font_size=18
      
      t=plot(result.ref_waves, (result.tsis.mean_std/result.tsis.mean_irrad*100), /xst, /over)
      t.color='b'
      t.name='TSIS V04'
      
      leg=legend(target=[s,t], font_size=16)
      ;s.save, "rdev_irrad.png"
    endif
  
    if overlap and abs_irrad then begin
      s=plot(result.ref_waves, abs(result.sorce.mean_irrad - result.tsis.mean_irrad), /xst)
      s.color='g'  
      s.xtitle='Wavelength (nm)' 
      s.ytitle='DIfference in Irradiance (W/m$^2$/nm)'
      s.title='Absolute Irradiance between SORCE and TSIS for the Overlap Period (2018-03-27 to 2020-02-25)'
      s.xtickvalues=lticks
      s.xlog=1
      s.xticklen=0.025 
      s.yticklen=0.015
      s.ylog=1
      s.xrange=range
      s.font_size=18
      ;s.save, "abs_irrad.png"
    endif
    
    if overlap and irrad_ratio then begin
      s=plot(result.ref_waves, (result.sorce.mean_irrad/result.tsis.mean_irrad), /xst)
      s.color='g'
      s.xtitle='Wavelength (nm)'
      s.ytitle='Fractional Difference'
      s.title='Ratio of the Mean Irradiance for SORCE to that of TSIS for the Overlap Period (2018-03-27 to 2020-02-25)'
      s.xtickvalues=lticks
      s.xlog=1
      s.xticklen=0.025
      s.yticklen=0.015 
      s.ylog=0 
      ;s.xrange=[240,2000]
      ;s.yrange=[0.90,1.10]
      s.font_size=18
      ;s.save, "irrad_ratio.png"
    endif
    
    
    
    ;Solar Minimum
    if solar_min then begin
      sol=tasty_solar_min(result_savefile)
    endif
   
    if solar_min and mean_irrad then begin
      s=plot(result.ref_waves, sol.sorce.mean_irrad, /xst)
      s.color='r'
      s.xtitle='Wavelength (nm)'
      s.ytitle='Irradiance (W/m$^2$/nm)'
      s.title='Average Irradiance for the Solar Minimum Period (2019-09-06 to 2019-11-07)'
      s.xtickvalues=lticks 
      s.xlog=1 
      s.name='SORCE V27.v276'
      s.xticklen=0.025
      s.yticklen=0.015 
      s.xrange=range
      s.font_size=18
      
      t=plot(result.ref_waves, sol.tsis.mean_irrad, /xst, /over)
      t.color='b'
      t.xlog=1 
      t.name='TSIS V04'
      
      leg=legend(target=[s,t], font_size=16)
      ;s.save, "mean_irrad_min.png"
    endif
  
    if solar_min and sdev_irrad then begin
      s=plot(result.ref_waves, sol.sorce.mean_sdev, /xst)
      s.color='r' 
      s.xtitle='Wavelength (nm)'
      s.ytitle='Standard Deviation (W/m$^2$/nm)'
      s.title='Standard Deviation of the Average Irradiance for the Solar Minimum Period (2019-09-06 to 2019-11-07)' 
      s.xtickvalues=lticks
      s.xlog=1 
      s.name='SORCE V27.v276'
      s.xticklen=0.025 
      s.yticklen=0.015 
      s.xrange=range
      s.font_size=18
      
      t=plot(result.ref_waves, sol.tsis.mean_sdev, /xst, /over)
      t.color='b'
      t.xlog=1 
      t.name='TSIS V04'
      
      leg=legend(target=[s,t], font_size=16)
      ;s.save, "sdev_irrad_min.png"
    endif
  
    if solar_min and rdev_irrad then begin
      s=plot(result.ref_waves, (sol.sorce.mean_sdev/sol.sorce.mean_irrad*100), /xst)
      s.color='r' 
      s.xtitle='Wavelength (nm)' 
      s.ytitle='Percentage (%)'
      s.title='Relative Standard Deviation (SDEV/MEAN*100) for the Solar Minimum Period (2019-09-06 to 2019-11-07)' 
      s.xlog=1 
      s.xtickvalues=lticks 
      s.ylog=1
      s.name='SORCE V27.v276' 
      s.xticklen=0.025 
      s.yticklen=0.015 
      s.xrange=range
      s.font_size=18
      
      t=plot(result.ref_waves, (sol.tsis.mean_sdev/sol.tsis.mean_irrad*100), /xst, /over)
      t.color='b'
      t.name='TSIS V04'
      
      leg=legend(target=[s,t], font_size=16)
      ;s.save, "rdev_irrad_min.png"
    endif
  
    if solar_min and abs_irrad then begin
      s=plot(result.ref_waves, abs(sol.sorce.mean_irrad - sol.tsis.mean_irrad), /xst)
      s.color='g'
      s.xtitle='Wavelength (nm)'
      s.ytitle='DIfference in Irradiance (W/m$^2$/nm)'
      s.title='Absolute Irradiance between SORCE and TSIS for the Solar Minimum Period (2019-09-06 to 2019-11-07)'
      s.xtickvalues=lticks 
      s.xlog=1
      s.xticklen=0.025 
      s.yticklen=0.015 
      s.ylog=1
      s.xrange=range
      s.font_size=18
      s.yrange=[0.000006,0.1]
      ;s.save, "abs_irrad_min.png"
    endif
  
    if solar_min and irrad_ratio then begin
      s=plot(result.ref_waves, (sol.sorce.mean_irrad/sol.tsis.mean_irrad), /xst)
      s.color='g' 
      s.xtitle='Wavelength (nm)' 
      s.ytitle='Fractional Difference'
      s.title='Ratio of the Mean Irradiance for SORCE to that of TSIS for the Solar Minimum Period (2019-09-06 to 2019-11-07)' 
      s.xtickvalues=lticks
      s.xlog=1
      s.xticklen=0.025 
      s.yticklen=0.015 
      s.ylog=0
      s.xrange=range 
      s.yrange=[0.90,1.10]
      s.font_size=18
      ;s.save, "irrad_ratio_min.png"
    endif  
    
    return, {s:s}  
  endif



  ;Image plots
  if img then begin
    if irrad or avg28 or sdev28 or avg28_ratio or irrad_ratio then begin
      r=tasty_image_display(result_savefile)
    endif
    winsize=500
    ;Overlap
    if overlap and irrad then begin
      w=window(dimensions=[3*winsize, 2*winsize])
      s=image(r.sorce.irrad, r.grid_waves, r.grid_days, axis_style=2, /current) 
      s.position=[.20,.61,.85,.91]
      s.rgb_table=74
      ;s.max_value=1.10
      ;s.min_value=0.90      
      s.title='Average Irradiance over the Overlap Period (2018-03-27 to 2020-02-25)'
      s.xtitle='Wavelength (nm)'
      s.ytitle='Day of Overlap'
      s.xrange=range
      s.xtickvalues=xticks
      s.xminor=3
      s.yminor=4
      s.yticklen=0.015
      s.font_size=18
      
      t=image(r.tsis.irrad, r.grid_waves, r.grid_days, axis_style=2, /current)
      t.position=[.20,.23,.85,.53]
      t.rgb_table=74
      ;s.max_value=1.10
      ;s.min_value=0.90      
      t.xtitle='Wavelength (nm)'
      t.ytitle='Day of Overlap'
      t.xrange=range
      t.xtickvalues=xticks
      t.xminor=3
      t.yminor=4
      t.yticklen=0.015
      t.font_size=18
      
      cticks=[0.2:2.0:0.2]
      
      cb=colorbar(target=[s])
      cb.position=[.25,.10,.80,.15]
      cb.border_on=1
      cb.title='Irradiance (W/m$^2$/nm)'
      cb.font_size=16 
      cb.tickvalues=cticks
      
      t1 = text([0.5],[0.75], 'SORCE V27.v276', font_size=16, /current)
      t2 = text([0.5],[0.375], 'TSIS V04', font_size=16, /current)
    endif
    
    if overlap and avg28 then begin
      w=window(dimensions=[3*winsize, 2*winsize])
      s=image(r.sorce.avg28, r.grid_waves, r.grid_days, axis_style=2, /current)
      s.position=[.20,.61,.85,.91]
      s.rgb_table=74
      s.title='28-day Average Irradiance over the Overlap Period (2018-03-27 to 2020-02-25)'
      s.xtitle='Wavelength (nm)'
      s.ytitle='Day of Overlap'
      s.xrange=range
      s.xtickvalues=xticks
      s.xminor=3
      s.yminor=4
      s.yticklen=0.015
      s.font_size=18
      
      t=image(r.tsis.avg28, r.grid_waves, r.grid_days, axis_style=2, /current)
      t.position=[.20,.23,.85,.53]
      t.rgb_table=74
      t.xtitle='Wavelength (nm)'
      t.ytitle='Day of Overlap'
      t.xrange=range
      t.xtickvalues=xticks
      t.xminor=3
      t.yminor=4
      t.yticklen=0.015
      t.font_size=18
      
      cticks=[0.2:2.0:0.2]
      
      cb=colorbar(target=[s])
      cb.position=[.25,.10,.80,.15]
      cb.border_on=1
      cb.title='Irradiance (W/m$^2$/nm)'
      cb.tickvalues=cticks
      cb.font_size=16
      
      t1 = text([0.5],[0.75], 'SORCE V27.v276', font_size=16, /current)
      t2 = text([0.5],[0.375], 'TSIS V04', font_size=16, /current)
    endif
    
    if overlap and sdev28 then begin
      w=window(dimensions=[3*winsize, 2*winsize])
      s=image(r.sorce.sdev28, r.grid_waves, r.grid_days, axis_style=2, /current)
      s.position=[.20,.61,.85,.91]
      s.rgb_table=74
      s.title='Standard Deviation of 28-day Average Irradiance for Overlap (2018-03-27 to 2020-02-25)'
      s.xtitle='Wavelength (nm)'
      s.ytitle='Day of Overlap'
      s.xrange=range
      s.xtickvalues=xticks
      s.xminor=3
      s.yminor=4
      s.yticklen=0.015
      s.font_size=18
      
      t=image(r.tsis.sdev28, r.grid_waves, r.grid_days, axis_style=2, /current)
      t.position=[.20,.23,.85,.53]
      t.rgb_table=74
      t.xtitle='Wavelength (nm)'
      t.ytitle='Day of Overlap'
      t.xrange=range
      t.xtickvalues=xticks
      t.xminor=3
      t.yminor=4
      t.yticklen=0.015
      t.font_size=18
      
      ;cticks=[-0.001:0.0025:0.0005]
      
      cb=colorbar(target=[s])
      cb.position=[.25,.10,.80,.15]
      cb.border_on=1
      cb.title='Standard Deviation (W/m$^2$/nm)'
      ;cb.tickvalues=cticks
      cb.font_size=16
      
      c=colorbar(target=[t])
      c.position=[.25,.10,.80,.15]
      c.border_on=1
      c.title='Irradiance (W/m$^2$/nm)'
      ;c.tickvalues=cticks
      c.font_size=16
      
      t1 = text([0.5],[0.75], 'SORCE V27.v276', font_size=16, /current)
      t2 = text([0.5],[0.375], 'TSIS V04', font_size=16, /current)
    endif
    
    if overlap and avg28_ratio then begin
      w=window(dimensions=[2.5*winsize, 1.5*winsize])
      s=image(r.sorce.avg28/r.tsis.avg28, r.grid_waves, r.grid_days, axis_style=2, /current)
      s.position=[.15,.40,.90,.85]
      s.rgb_table=74
      s.title='Ratio of the 28-day Average Irradiance for Overlap (2018-03-27 to 2020-02-25)'
      s.xtitle='Wavelength (nm)'
      s.ytitle='Day of Overlap'
      s.xrange=range
      s.xtickvalues=xticks
      s.xminor=3
      s.yminor=4
      s.yticklen=0.015
      s.font_size=18
      
      ;cticks=[0.8:1.4:0.1]
      
      cb=colorbar(target=[s])
      cb.position=[.25,.19,.80,.27]
      cb.border_on=1
      cb.title='Ratio (SORCE V27.v276/TSIS V04)'
      ;cb.tickvalues=cticks
      cb.minor=4
      cb.font_size=16
    endif
    
    if overlap and irrad_ratio then begin
      w=window(dimensions=[2.5*winsize, 1.5*winsize])
      s=image((r.sorce.irrad/r.tsis.irrad), r.grid_waves, r.grid_days, axis_style=2, /current)
      s.position=[.15,.40,.90,.85]
      s.max_value=1.10
      s.min_value=0.90
      s.rgb_table=74
      s.title='Ratio of the Avg. Irradiance for Overlap Period (2018-03-27 to 2020-02-25)'
      s.xtitle='Wavelength (nm)'
      s.ytitle='Day of Overlap'
      s.xrange=range
      s.xtickvalues=xticks
      s.xminor=3
      s.yminor=4
      s.yticklen=0.015
      s.font_size=18

      ;cticks=[0.8:1.4:0.1]

      cb=colorbar(target=[s])
      cb.position=[.25,.19,.80,.27]
      cb.border_on=1
      cb.title='Ratio (SORCE V27.v276/TSIS V04) '
      ;cb.tickvalues=cticks
      cb.minor=4
      cb.font_size=16
    endif
    
    
    ;Solar Min
    if solar_min then begin
      q=tasty_image_display(result_savefile, timePeriod='solar_min')
    endif
    
    if solar_min and irrad then begin
      w=window(dimensions=[3*winsize, 2*winsize])
      s=image(q.sorce.irrad, q.grid_waves, q.grid_days, axis_style=2, /current)
      s.position=[.20,.61,.85,.91]
      s.rgb_table=74
      s.title='Average Irradiance over Solar Minimum Period (2019-09-06 to 2019-11-07)'
      s.xtitle='Wavelength (nm)'
      s.ytitle='Day of Overlap'
      s.xrange=range
      s.xtickvalues=xticks
      s.xminor=3
      s.yminor=4
      s.yticklen=0.015
      s.font_size=18

      t=image(q.tsis.irrad, q.grid_waves, q.grid_days, axis_style=2, /current)
      t.position=[.20,.23,.85,.53]
      t.rgb_table=74
      t.xtitle='Wavelength (nm)'
      t.ytitle='Day of Overlap'
      t.xrange=range
      t.xtickvalues=xticks
      t.xminor=3
      t.yminor=4
      t.yticklen=0.015
      t.font_size=18

      cticks=[0.2:2.0:0.2]
      
      cb=colorbar(target=[s])
      cb.position=[.25,.10,.80,.15]
      cb.border_on=1
      cb.title='Irradiance (W/m$^2$/nm)'
      cb.font_size=16 
      cb.tickvalues=cticks

      t1 = text([0.5],[0.75], 'SORCE V27.v276', font_size=16, /current)
      t2 = text([0.5],[0.375], 'TSIS V04', font_size=16, /current)
    endif

    if solar_min and irrad_ratio then begin
      w=window(dimensions=[2.5*winsize, 1.5*winsize])
      s=image((q.sorce.irrad/q.tsis.irrad), q.grid_waves, q.grid_days, axis_style=2, /current)
      s.position=[.15,.40,.90,.85]
      s.max_value=1.10
      s.min_value=0.90
      s.rgb_table=74
      s.title='Ratio of the Avg. Irradiance for Solar Minimum Period (2019-09-06 to 2019-11-07)'
      s.xtitle='Wavelength (nm)'
      s.ytitle='Day of Overlap'
      s.xrange=range
      s.xtickvalues=xticks
      s.xminor=3
      s.yminor=4
      s.yticklen=0.015
      s.font_size=18
      
      cb=colorbar(target=[s])
      cb.position=[.25,.19,.80,.27]
      cb.border_on=1
      cb.title='Ratio (SORCE V27.v276/TSIS V04) '
      ;cb.tickvalues=cticks
      cb.minor=4
      cb.font_size=16
    endif

    return, {s:s}
  endif

  

  
end