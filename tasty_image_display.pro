; docformat = 'rst'
;+
;   Providing the save file for the results obtained from trim_tsis_sorce_data, this routine will interpolate 
;   the irradiance 2D arrays for both SORCE and TSIS onto a uniform grid (in both x and y dimensions) for display 
;   purposes only. In doing so will allow image plots to be made with axes in physical units rather than in
;   pixel space (x-axis=wavelength, y-axis=day of overlap).
;
; :Author:
;     Peter Breslin
;
; :Examples:
; ::
;     result_savefile='result_20200618.sav'
;     result=tasty_image_display(result_savefile, timePeriod='solar_min')    
;-

;+
; :Params:
;    result_savefile : in, required, type=string
;      The filename of the IDL savefile containing the output from the function trim_tsis_sorce_data.pro
;
; :Keywords:
;    timePeriod : in, not required, type=string
;      Options are "overlap" or "solar_min", if keyword not set then overlap is default
;
; :Returns:
;     A data structure containing:
;       If Overlap or Solar Min:
;         - An array for the interpolated wavelength grid
;         - An array for the interpolated days grid
;         - Two more data structures (one for SORCE, one for TSIS) containing four 2D arrays for the irradiance,
;           28-day average of the irradiance, standard deviation of this 28-day average, and the relative standard 
;           deviation of this average.
;
function tasty_image_display, result_savefile, timePeriod=timePeriod

  if (n_elements(result_savefile) eq 0 || strlen(result_savefile) eq 0) then begin
    doc_library,'tasty_image_display'
    print,'*** Missing filenames'
    return,-1
  endif
  
  ;Declaring variables
  overlap=0
  solar_min=0

  ;If timePeriod keyword not set, overlap period will be used
  if not keyword_set(timePeriod) then timePeriod="overlap"

  ;Validating inputs
  if timePeriod eq "overlap" then overlap=1 else if timePeriod eq "solar_min" then solar_min=1 else message, /info, "Input must be 'overlap' or 'solar_min' for time period"
  
  restore, result_savefile
  
  
  if overlap then begin
    ;Interpolation --> interpolating for the days and then the wavelength 
    grid_days = [min(result.ref_days):max(result.ref_days):1]   ;uniform grid for days in JD
    gridday = double([0:700:1])                                 ;uniform grid for days from 0 to 700
    grid_waves = double([240:2400:1])                           ;uniform wavelength grid w/ step-size of 1nm
    
    
    ; 1) Full irradiance over overlap 
    sorce_interp0 =  dblarr(n_elements(grid_days), n_elements(result.ref_waves))
    tsis_interp0  =  dblarr(n_elements(grid_days), n_elements(result.ref_waves))
    sorce_interp  =  dblarr(n_elements(grid_days), n_elements(grid_waves))
    tsis_interp   =  dblarr(n_elements(grid_days), n_elements(grid_waves))
    
    ;Looping through each day to regrid the days onto a uniform grid
    for wv=0L,n_elements(result.ref_waves)-1L do begin
      interp4, result.ref_days, result.sorce.irrad[*,wv], grid_days, s_irrad
      sorce_interp0[*,wv]  =  s_irrad
      interp4, result.ref_days, result.tsis.irrad[*,wv], grid_days, t_irrad
      tsis_interp0[*,wv]   =  t_irrad
    endfor
  
    ;Now looping through each wavelength to regrid the wavelengths onto a uniform grid  
    for d=0L,n_elements(grid_days)-1L do begin
      interp4, result.ref_waves, sorce_interp0[d,*], grid_waves, s_irrad
      sorce_interp[d,*] = s_irrad
      interp4, result.ref_waves, tsis_interp0[d,*], grid_waves, t_irrad
      tsis_interp[d,*] = t_irrad
    endfor
    
    ;Transposing to make plotting easier
    s_interp=transpose(sorce_interp)
    t_interp=transpose(tsis_interp)
  
    
    ;28 Day Average ---> do before interpolation, use the tasty_solar_rotation function
  
    rotation=tasty_solar_rotation(result_savefile)
  
    sorce_28avg  = temporary(rotation.sorce_28irrad.mean)
    sorce_28sdev = temporary(rotation.sorce_28irrad.sdev)
    sorce_28rdev = temporary(rotation.sorce_28irrad.rdev)
    tsis_28avg   = temporary(rotation.tsis_28irrad.mean)
    tsis_28sdev  = temporary(rotation.tsis_28irrad.sdev)
    tsis_28rdev  = temporary(rotation.tsis_28irrad.rdev)
    
    
    ; 2) 28-day average of irradiance over overlap
    sorce_interp1 =  dblarr(n_elements(grid_days), n_elements(result.ref_waves))
    tsis_interp1  =  dblarr(n_elements(grid_days), n_elements(result.ref_waves))
    sorce_interp28  =  dblarr(n_elements(grid_days), n_elements(grid_waves))
    tsis_interp28   =  dblarr(n_elements(grid_days), n_elements(grid_waves))
    
    ;Looping through each day to regrid the days onto a uniform grid
    for wv=0L,n_elements(result.ref_waves)-1L do begin
      interp4, result.ref_days, sorce_28avg[*,wv], grid_days, s_irrad
      sorce_interp1[*,wv]  =  s_irrad
      interp4, result.ref_days, tsis_28avg[*,wv], grid_days, t_irrad
      tsis_interp1[*,wv]   =  t_irrad
    endfor
  
    ;Now looping through each wavelength to regrid the wavelengths onto a uniform grid  
    for d=0L,n_elements(grid_days)-1L do begin
      interp4, result.ref_waves, sorce_interp1[d,*], grid_waves, s_irrad
      sorce_interp28[d,*] = s_irrad
      interp4, result.ref_waves, tsis_interp1[d,*], grid_waves, t_irrad
      tsis_interp28[d,*] = t_irrad
    endfor
   
    ;Transposing to make plotting easier 
    s28=transpose(sorce_interp28)
    t28=transpose(tsis_interp28)  
    
    
    ; 3) Standard Deviation of the 28-day average of the irradiance for the overlap
    sorce_interp2 =  dblarr(n_elements(grid_days), n_elements(result.ref_waves))
    tsis_interp2  =  dblarr(n_elements(grid_days), n_elements(result.ref_waves))
    sorce_interp28sdev  =  dblarr(n_elements(grid_days), n_elements(grid_waves))
    tsis_interp28sdev   =  dblarr(n_elements(grid_days), n_elements(grid_waves))
  
    ;Looping through each day to regrid the days onto a uniform grid  
    for wv=0L,n_elements(result.ref_waves)-1L do begin
      interp4, result.ref_days, sorce_28sdev[*,wv], grid_days, s_irrad
      sorce_interp2[*,wv]  =  s_irrad
      interp4, result.ref_days, tsis_28sdev[*,wv], grid_days, t_irrad
      tsis_interp2[*,wv]   =  t_irrad
    endfor
  
    ;Now looping through each wavelength to regrid the wavelengths onto a uniform grid  
    for d=0L,n_elements(grid_days)-1L do begin
      interp4, result.ref_waves, sorce_interp2[d,*], grid_waves, s_irrad
      sorce_interp28sdev[d,*] = s_irrad
      interp4, result.ref_waves, tsis_interp2[d,*], grid_waves, t_irrad
      tsis_interp28sdev[d,*] = t_irrad
    endfor
  
    ;Transposing to make plotting easier   
    s28_sdev=transpose(sorce_interp28sdev)
    t28_sdev=transpose(tsis_interp28sdev)
    
    
    ; 4) Relative standard Deviation of the 28-day average of the irradiance for the overlap
    sorce_interp3 =  dblarr(n_elements(grid_days), n_elements(result.ref_waves))
    tsis_interp3  =  dblarr(n_elements(grid_days), n_elements(result.ref_waves))
    sorce_interp28rdev  =  dblarr(n_elements(grid_days), n_elements(grid_waves))
    tsis_interp28rdev   =  dblarr(n_elements(grid_days), n_elements(grid_waves))
  
    ;Looping through each day to regrid the days onto a uniform grid  
    for wv=0L,n_elements(result.ref_waves)-1L do begin
      interp4, result.ref_days, sorce_28rdev[*,wv], grid_days, s_irrad
      sorce_interp3[*,wv]  =  s_irrad
      interp4, result.ref_days, tsis_28rdev[*,wv], grid_days, t_irrad
      tsis_interp3[*,wv]   =  t_irrad
    endfor
  
    ;Now looping through each wavelength to regrid the wavelengths onto a uniform grid  
    for d=0L,n_elements(grid_days)-1L do begin
      interp4, result.ref_waves, sorce_interp3[d,*], grid_waves, s_irrad
      sorce_interp28rdev[d,*] = s_irrad
      interp4, result.ref_waves, tsis_interp3[d,*], grid_waves, t_irrad
      tsis_interp28rdev[d,*] = t_irrad
    endfor
  
    ;Transposing to make plotting easier   
    s28_rdev=transpose(sorce_interp28rdev)
    t28_rdev=transpose(tsis_interp28rdev)
      
    return, {grid_days:gridday, grid_waves:grid_waves, $
             sorce:{irrad:s_interp, avg28:s28, sdev28:s28_sdev, rdev28:s28_rdev}, $
             tsis:{irrad:t_interp, avg28:t28, sdev28:t28_sdev, rdev28:t28_rdev}}
  endif  
  
  
  
  if solar_min then begin
    sol=tasty_solar_min(result_savefile)
    
    ;Interpolation --> interpolating for the days and then the wavelength
    grid_days = [min(sol.period):max(sol.period):1]   ;uniform grid for days in JD
    gridday = double([0:62:1])                        ;uniform grid for days from 0 to 62
    grid_waves = double([240:2400:1])                 ;uniform wavelength grid w/ step-size of 1nm

    ; 1) Full irradiance over solar min
    sorce_interp0 =  dblarr(n_elements(grid_days), n_elements(result.ref_waves))
    tsis_interp0  =  dblarr(n_elements(grid_days), n_elements(result.ref_waves))
    sorce_interp  =  dblarr(n_elements(grid_days), n_elements(grid_waves))
    tsis_interp   =  dblarr(n_elements(grid_days), n_elements(grid_waves))

    ;Looping through each day to regrid the days onto a uniform grid
    for wv=0L,n_elements(result.ref_waves)-1L do begin
      interp4, sol.period, sol.sorce.irrad[*,wv], grid_days, s_irrad
      sorce_interp0[*,wv]  =  s_irrad
      interp4, sol.period, sol.tsis.irrad[*,wv], grid_days, t_irrad
      tsis_interp0[*,wv]   =  t_irrad
    endfor

    ;Now looping through each wavelength to regrid the wavelengths onto a uniform grid
    for d=0L,n_elements(grid_days)-1L do begin
      interp4, result.ref_waves, sorce_interp0[d,*], grid_waves, s_irrad
      sorce_interp[d,*] = s_irrad
      interp4, result.ref_waves, tsis_interp0[d,*], grid_waves, t_irrad
      tsis_interp[d,*] = t_irrad
    endfor

    ;Transposing to make plotting easier
    s_interp=transpose(sorce_interp)
    t_interp=transpose(tsis_interp)
    
    
    ;28 Day Average ---> do before interpolation, use the tasty_solar_rotation function

    rotation=tasty_solar_rotation(result_savefile, timePeriod='solar_min')

    sorce_28avg  = temporary(rotation.sorce_28irrad.mean)
    sorce_28sdev = temporary(rotation.sorce_28irrad.sdev)
    sorce_28rdev = temporary(rotation.sorce_28irrad.rdev)
    tsis_28avg   = temporary(rotation.tsis_28irrad.mean)
    tsis_28sdev  = temporary(rotation.tsis_28irrad.sdev)
    tsis_28rdev  = temporary(rotation.tsis_28irrad.rdev)


    ; 2) 28-day average of irradiance over solar min
    sorce_interp1 =  dblarr(n_elements(grid_days), n_elements(result.ref_waves))
    tsis_interp1  =  dblarr(n_elements(grid_days), n_elements(result.ref_waves))
    sorce_interp28  =  dblarr(n_elements(grid_days), n_elements(grid_waves))
    tsis_interp28   =  dblarr(n_elements(grid_days), n_elements(grid_waves))

    ;Looping through each day to regrid the days onto a uniform grid
    for wv=0L,n_elements(result.ref_waves)-1L do begin
      interp4, sol.period, sorce_28avg[*,wv], grid_days, s_irrad
      sorce_interp1[*,wv]  =  s_irrad
      interp4, sol.period, tsis_28avg[*,wv], grid_days, t_irrad
      tsis_interp1[*,wv]   =  t_irrad
    endfor

    ;Now looping through each wavelength to regrid the wavelengths onto a uniform grid
    for d=0L,n_elements(grid_days)-1L do begin
      interp4, result.ref_waves, sorce_interp1[d,*], grid_waves, s_irrad
      sorce_interp28[d,*] = s_irrad
      interp4, result.ref_waves, tsis_interp1[d,*], grid_waves, t_irrad
      tsis_interp28[d,*] = t_irrad
    endfor

    ;Transposing to make plotting easier
    s28=transpose(sorce_interp28)
    t28=transpose(tsis_interp28)



    ; 3) Standard Deviation of the 28-day average of the irradiance for the solar min
    sorce_interp2 =  dblarr(n_elements(grid_days), n_elements(result.ref_waves))
    tsis_interp2  =  dblarr(n_elements(grid_days), n_elements(result.ref_waves))
    sorce_interp28sdev  =  dblarr(n_elements(grid_days), n_elements(grid_waves))
    tsis_interp28sdev   =  dblarr(n_elements(grid_days), n_elements(grid_waves))

    ;Looping through each day to regrid the days onto a uniform grid
    for wv=0L,n_elements(result.ref_waves)-1L do begin
      interp4, sol.period, sorce_28sdev[*,wv], grid_days, s_irrad
      sorce_interp2[*,wv]  =  s_irrad
      interp4, sol.period, tsis_28sdev[*,wv], grid_days, t_irrad
      tsis_interp2[*,wv]   =  t_irrad
    endfor

    ;Now looping through each wavelength to regrid the wavelengths onto a uniform grid
    for d=0L,n_elements(grid_days)-1L do begin
      interp4, result.ref_waves, sorce_interp2[d,*], grid_waves, s_irrad
      sorce_interp28sdev[d,*] = s_irrad
      interp4, result.ref_waves, tsis_interp2[d,*], grid_waves, t_irrad
      tsis_interp28sdev[d,*] = t_irrad
    endfor

    ;Transposing to make plotting easier
    s28_sdev=transpose(sorce_interp28sdev)
    t28_sdev=transpose(tsis_interp28sdev)


    ; 4) Relative standard Deviation of the 28-day average of the irradiance for the solar min
    sorce_interp3 =  dblarr(n_elements(grid_days), n_elements(result.ref_waves))
    tsis_interp3  =  dblarr(n_elements(grid_days), n_elements(result.ref_waves))
    sorce_interp28rdev  =  dblarr(n_elements(grid_days), n_elements(grid_waves))
    tsis_interp28rdev   =  dblarr(n_elements(grid_days), n_elements(grid_waves))

    ;Looping through each day to regrid the days onto a uniform grid
    for wv=0L,n_elements(result.ref_waves)-1L do begin
      interp4, sol.period, sorce_28rdev[*,wv], grid_days, s_irrad
      sorce_interp3[*,wv]  =  s_irrad
      interp4, sol.period, tsis_28rdev[*,wv], grid_days, t_irrad
      tsis_interp3[*,wv]   =  t_irrad
    endfor

    ;Now looping through each wavelength to regrid the wavelengths onto a uniform grid
    for d=0L,n_elements(grid_days)-1L do begin
      interp4, result.ref_waves, sorce_interp3[d,*], grid_waves, s_irrad
      sorce_interp28rdev[d,*] = s_irrad
      interp4, result.ref_waves, tsis_interp3[d,*], grid_waves, t_irrad
      tsis_interp28rdev[d,*] = t_irrad
    endfor

    ;Transposing to make plotting easier
    s28_rdev=transpose(sorce_interp28rdev)
    t28_rdev=transpose(tsis_interp28rdev)

      

    return, {grid_days:gridday, grid_waves:grid_waves, $
             sorce:{irrad:s_interp, avg28:s28, sdev28:s28_sdev, rdev28:s28_rdev}, $
             tsis:{irrad:t_interp, avg28:t28, sdev28:t28_sdev, rdev28:t28_rdev}}
             
  endif
  
  
  
end