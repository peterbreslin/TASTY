; docformat = 'rst'
;+
;   Providing the save file for the results obtained from trim_tsis_sorce_data, this routine will find
;   some ratios and differences between the trimmed irradiance arrays for both SORCE-SIM and TISIS-SIM
;
;
; :Examples:
; ::
;     result_savefile='result_20200703.sav'
;     result=tsis_sorce_irrad_diff(result_savefile)
;
;-

;+
; :Params:
;    result_savefile : in, required, type=string
;      The filename of the IDL savefile containing the output from the function trim_tsis_sorce_data.pro
;
; :Keywords:
;
; :Returns:
;     A data structure containing:
;      - An array for the difference in irradiance from the mean value for both SORCE and TSIS
;      - An array for the absolute difference in the mean irradiance between SORCE and TSIS
;      - An array for the fractional difference of the mean irradiance between SORCE and TSIS
;
;
function tsis_sorce_irrad_diff, result_savefile, indata=indata

  if (n_elements(result_savefile) eq 0 && strlen(result_savefile) eq 0) then begin
    doc_library,'tsis_sorce_irrad_diff'
    print,'*** Missing filenames'
    return,-1
  endif

  restore, result_savefile


  ;Difference in the irradiance from the mean value
  sorce_irrad_diff = result.sorce.irrad * 0d
  tsis_irrad_diff = result.tsis.irrad * 0d
  
  for i=0,538 do sorce_Irrad_diff[i,*] = result.sorce.irrad[i,*] - result.sorce.mean_irrad
  for i=0,538 do tsis_irrad_diff[i,*] = result.tsis.irrad[i,*] - result.tsis.mean_irrad
  
  ;Absolute difference in the mean irradiance between SORCE and TSIS
  abs_mean_diff = abs(result.sorce.mean_irrad - result.tsis.mean_irrad)
  
  ;Ratio of mean irradiance from SORCE and TSIS (fractional difference) 
  mean_irrad_ratio = result.sorce.mean_irrad/result.tsis.mean_irrad
  
  
  return, {sorce_irrad_diff:sorce_irrad_diff, tsis_irrad_diff:tsis_irrad_diff, $
           abs_mean_diff:abs_mean_diff, mean_irrad_ratio:mean_irrad_ratio}






end