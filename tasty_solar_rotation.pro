; docformat = 'rst'
;+
;   Providing the save file for the results obtained from trim_tsis_sorce_data, this routine will do
;   a 28-day average (one solar rotation) of the trimmed solar irradiance measured from both SORCE-SIM 
;   and TSIS-SIM over the overlap period.
;    
; :Author:
;     Peter Breslin
;    
; :Examples:
; ::
;     result_savefile='result_20200618.sav'
;     result=tasty_solar_rotation(result_savefile, timePeriod='solar_min')
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
;     Two data structures (one for SORCE, one for TSIS) containing:
;      - An array for the 28-day average of the irradiance for overlap/solar min day
;      - An array for the standard deviation of this average
;      - An array for the relative standard deviation of this average
;      - An array containing the number of days averaged over for each 28-day scan (from the beginning
;        to the end of the overlap/solar min period)
;
;
function tasty_solar_rotation, result_savefile, timePeriod=timePeriod

  if (n_elements(result_savefile) && 0 || strlen(result_savefile) eq 0) then begin
    doc_library,'tasty_solar_rotation'
    print,'*** Missing filenames'
    return,-1
  endif
  
  overlap=0
  solar_min=0
  
  ;If timePeriod keyword not set, overlap period will be used
  if not keyword_set(timePeriod) then timePeriod="overlap"
  
  ;Validating input
  if timePeriod eq "overlap" then overlap=1 else if timePeriod eq "solar_min" then solar_min=1 $
    else message, /info, "Input must be 'overlap' or 'solar_min' for timePeriod"


  ;Overlap 28-day average
  if overlap then begin
    restore, result_savefile

    ;SORCE
    sorce_28avg = result.sorce.irrad * 0d
    sorce_28sdev = result.sorce.irrad * 0d
    sorce_28ndays = result.ref_days * 0d

    for d=0, n_elements(result.ref_days)-1 do begin
      p=where(abs(result.ref_days - result.ref_days[d]) le 14, count)
      sorce_28avg[d,*]  =  mean(result.sorce.irrad[p,*], dim=1, /nan, /double)
      sorce_28sdev[d,*] =  stddev(result.sorce.irrad[p,*], dim=1, /nan, /double)
      sorce_28ndays[d]  =  count
    endfor

    sorce_28rdev = sorce_28sdev/sorce_28avg*100


    ;Now doing the same for TSIS
    tsis_28avg = result.tsis.irrad * 0d
    tsis_28sdev = result.tsis.irrad * 0d
    tsis_28ndays = result.ref_days * 0d

    for d=0, n_elements(result.ref_days)-1 do begin
      q=where(abs(result.ref_days - result.ref_days[d]) le 14, count)
      tsis_28avg[d,*]  =  mean(result.tsis.irrad[q,*], dim=1, /nan, /double)
      tsis_28sdev[d,*] =  stddev(result.tsis.irrad[q,*], dim=1, /nan, /double)
      tsis_28ndays[d]  =  count
    endfor

    tsis_28rdev = tsis_28sdev/tsis_28avg*100


    return, {sorce_28irrad:{mean:sorce_28avg, sdev:sorce_28sdev, rdev:sorce_28rdev, ndays:sorce_28ndays}, $
             tsis_28irrad:{mean:tsis_28avg, sdev:tsis_28sdev, rdev:tsis_28rdev, ndays:tsis_28ndays}}
  endif

     

  ;Solar minimum 28-day average
  if solar_min then begin
    solmin=tasty_solar_min(result_savefile)
    
    ;SORCE
    sorce_28avg = solmin.sorce.irrad * 0d
    sorce_28sdev = solmin.sorce.irrad * 0d
    sorce_28ndays = solmin.period * 0d

    for d=0, n_elements(solmin.period)-1 do begin
      p=where(abs(solmin.period - solmin.period[d]) le 14, count)
      sorce_28avg[d,*]  =  mean(solmin.sorce.irrad[p,*], dim=1, /nan, /double)
      sorce_28sdev[d,*] =  stddev(solmin.sorce.irrad[p,*], dim=1, /nan, /double)
      sorce_28ndays[d]  =  count
    endfor

    sorce_28rdev = sorce_28sdev/sorce_28avg*100


    ;TSIS
    tsis_28avg = solmin.tsis.irrad * 0d
    tsis_28sdev = solmin.tsis.irrad * 0d
    tsis_28ndays = solmin.period * 0d

    for d=0, n_elements(solmin.period)-1 do begin
      q=where(abs(solmin.period - solmin.period[d]) le 14, count)
      tsis_28avg[d,*]  =  mean(solmin.tsis.irrad[q,*], dim=1, /nan, /double)
      tsis_28sdev[d,*] =  stddev(solmin.tsis.irrad[q,*], dim=1, /nan, /double)
      tsis_28ndays[d]  =  count
    endfor

    tsis_28rdev = tsis_28sdev/tsis_28avg*100
    
    return, {sorce_28irrad:{mean:sorce_28avg, sdev:sorce_28sdev, rdev:sorce_28rdev, ndays:sorce_28ndays}, $
             tsis_28irrad:{mean:tsis_28avg, sdev:tsis_28sdev, rdev:tsis_28rdev, ndays:tsis_28ndays}}
  
  endif
  

end

