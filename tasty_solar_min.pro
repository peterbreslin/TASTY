; docformat = 'rst'
;+
;   Providing the save file for the results obtained from trim_tsis_sorce_data.pro, this routine will 
;   define the solar minimum period and find the total irradiance, mean irradiance, and standard deviation 
;   of the irradiance during this time range.
;   
; :Author:
;     Peter Breslin
;     
; :Examples:
; ::
;     result_savefile='result_20200703.sav'
;     result=tasty_solar_min(result_savefile)
;-

;+
; :Params:
;    result_savefile : in, required, type=string
;      The filename of the IDL savefile containing the output from the function trim_tsis_sorce_data.pro
;    dateRange : in, not required, type=array
;      The specified time range in Julian Date for the solar minimum period
;
; :Keywords:
;
; :Returns:
;     An array with the solar minimum period in julian date
;     Two data structures (one for SORCE, one for TSIS) containing:
;      - An array for the irradiance for each day of the solar min period
;      - An array for the mean irradiance at each wavelength over this period
;      - An array for the standard deviation of the irradiance over this period
;
;
function tasty_solar_min, result_savefile, dateRange

  if (n_elements(result_savefile) eq 0 && strlen(result_savefile) eq 0) then begin
    doc_library,'tasty_solar_min'
    print,'*** Missing filenames'
    return,-1
  endif
  
  if not keyword_set(dateRange) then dateRange=[2458732.50,2458794.50]

  restore, result_savefile

  ;Defining the region of Solar minimum (06Sep-07Nov 2019)
  start  =  dateRange[0]
  finish =  dateRange[1]
  ;start  =  datetime_adapt('06-Sep-2019 00:00:00.00', from='vms', to='jd')
  ;finish =  datetime_adapt('07-Nov-2019 00:00:00.00', from='vms', to='jd')

  ;Selecting solar minimum region within ref_days array
  p=where((result.ref_days ge start) and (result.ref_days le finish), count)
  min_period = result.ref_days[p]
  
  ;Creating arrays for both the SORCE and TSIS solar min irradiance
  ssm_irrad = dblarr(n_elements(min_period), n_elements(result.ref_waves))
  tsm_irrad = dblarr(n_elements(min_period), n_elements(result.ref_waves))
  
  ;Getting the irradiance values corresponding to the solar min period
  ssm_irrad = result.sorce.irrad[p,*]
  tsm_irrad = result.tsis.irrad[p,*]
  
  
  ;Getting the resistant mean and sdev of the irrad for the solar min period
  ; --- SORCE
   sigma = 2.0
   ssm_mean_irrad = dblarr(n_elements(result.ref_waves))
   ssm_mean_sdev  = dblarr(n_elements(result.ref_waves))
   for wv=0L, n_elements(result.ref_waves)-1L do begin
      resistant_mean, ssm_irrad[*,wv], sigma, mean_irrad, num_rej, good=good
      ssm_mean_irrad[wv] = mean_irrad
      ;Ignoring the points outside the sigma threshold
      ssm_mean_sdev[wv]  = stddev(ssm_irrad[good,wv])
   endfor
      
   ; --- TSIS
   tsm_mean_irrad = dblarr(n_elements(result.ref_waves))
   tsm_mean_sdev  = dblarr(n_elements(result.ref_waves))
   for wv=0L, n_elements(result.ref_waves)-1L do begin
     resistant_mean, tsm_irrad[*,wv], sigma, mean_irrad, num_rej, good=good
     tsm_mean_irrad[wv] = mean_irrad
     ;Ignoring the points outside the sigma threshold
     tsm_mean_sdev[wv]  = stddev(tsm_irrad[good,wv])
   endfor


   return, {period:min_period, $
            sorce:{irrad:ssm_irrad, mean_irrad:ssm_mean_irrad, mean_sdev:ssm_mean_sdev}, $
            tsis:{irrad:tsm_irrad, mean_irrad:tsm_mean_irrad, mean_sdev:tsm_mean_sdev}}



end
