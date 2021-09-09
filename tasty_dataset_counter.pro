; docformat = 'rst'
;+
;   Providing the save files for the level 3 data for SORCE and TSIS, this function will look at the spectra
;   for each day over a specified date range and count the number of datasets used at each wavelength.
;
; :Author:
;     Peter Breslin
;
; :Examples:
; ::
;     result_savefile='result_20200703.sav'
;     sorce_savefile='L3_V27_v276_wjumpc_10.0.3_208.sav'
;     tsis_savefile='TSIS_L3_c24h_V04.sav'
;     counter=tasty_dataset_counter(result_savefile, sorce_savefile, tsis_savefile, dateRange='solar_min')
;-

;+
; :Params:
;    result_savefile : in, required, type=string
;      The filename of the IDL savefile containing the output from the function trim_tsis_sorce_data.pro
;    sorce_savefile : in, required, type=string
;      The filename of the IDL savefile containing the SORCE L3 data
;    tsis_savefile : in, required, type=string
;      The filename of the IDL savefile containing the TSIS L3 data
;
; :Keywords:
;    dateRange : in, not required, type=string
;      The specified time period over which to count the number of
;      datasets. Input must either 'overlap' or 'solar_min'
;
; :Returns:
;     - An array of counts as a function of wavelength for SORCE
;     - An array of counts as a function of wavelength for TSIS
;     - An array for the wavelength scale used for SORCE
;     - An array for the wavelength scale used for TSIS
;
function tasty_dataset_counter, result_savefile, sorce_savefile, tsis_savefile, dateRange=dateRange

   if (n_elements(result_savefile) eq 0) || (strlen(sorce_savefile) eq 0) && (strlen(tsis_savefile) eq 0) then begin
       doc_library,'tasty_dataset_counter'
       print,'*** Missing filenames'
       return,-1
   endif
   
   ;If dateRange keyword not set, overlap period will be used
   if not keyword_set(dateRange) then dateRange='overlap'
   
   ;Defining the overlap and solar minimum time periods
   start=[]
   finish=[]
   if isa(dateRange, /string) then begin
    if dateRange eq "overlap" then begin
      start=2458205.0 & finish=2458905.0
    endif else begin
      if dateRange eq "solar_min" then begin
        start=2458732.50 & finish=2458794.50
      endif else begin
        if (dateRange ne "overlap") or (dateRange ne "solar_min") then begin
          message, /info, "dateRange must be a string, input either 'overlap' or 'solar_min'"
        endif
      endelse
    endelse
   endif
   
   restore, result_savefile
   if dateRange eq 'overlap' then print, n_elements(result.ref_days), format='("All ",I0," days of overlap chosen")'
   if dateRange eq 'solar_min' then print, n_elements(result.ref_days), format='("52 out of ",I0," days of overlap chosen")'     
 
   
   ;SORCE
   restore, sorce_savefile
   sorce_data=[temporary(uv),temporary(vis),temporary(ir),temporary(esr)]
   
   ;Trimming data to desired time period
   start_gps=datetime_adapt(start, from='jd', to='ugps')
   finish_gps=datetime_adapt(finish, from='jd', to='ugps')
      
   s=where((sorce_data.nominalgpstimetag ge start_gps) and (sorce_data.nominalgpstimetag le finish_gps), count)
   sorce_data=sorce_data[s]
   sorce_jd = round(datetime_adapt(sorce_data.nominalgpstimetag, from='ugps', to='jd') * 10d) / 10d
   
   ;Looking at the days where we have SORCE and TSIS data
   keep=[]
   for d=0L,n_elements(result.ref_days)-1L do begin
     p=where(sorce_jd eq result.ref_days[d],count)
     if count gt 0 then keep=[keep,p]
   endfor
   sorce_data=sorce_data[keep]
 
   ;Counting the number of datasets used per wavelength
   sorce_count=intarr(n_elements(result.ref_waves))
   for w=0L,n_elements(result.ref_waves)-1L do begin
     q=where(sorce_data.minwavelength eq result.ref_waves[w],count)
     sorce_count[w]=count
   endfor
   
   
   ;TSIS
   restore,tsis_savefile
   tsis_data=temporary(data)
   
   r=where((tsis_data.nominal_date_jdn ge start) and (tsis_data.nominal_date_jdn le finish), count)
   tsis_data=tsis_data[r]
   tsis_jd = round(tsis_data.nominal_date_jdn * 10d) / 10d
   
   ;Looking at the days where we have SORCE and TSIS data 
   ;Using the wavelength scale specific to TSIS (before interpolation to SORCE grid)
   keep=[]
   tsis_waves=[]
   mxw=0L
   for d=0L,n_elements(result.ref_days)-1L do begin
     p=where(tsis_jd eq result.ref_days[d],count)
     if count eq 0 then continue
     keep=[keep,p]
     s=sort(tsis_data[p].wavelength)
     q=uniq(tsis_data[p[s]].wavelength)
     if n_elements(q) gt mxw then begin
      mxw=n_elements(q)
      tsis_waves=tsis_data[p[s[q]]].wavelength
     endif
   endfor
   tsis_data=tsis_data[keep]
   
   ;Counting the number of datasets used per wavelength
   tsis_count=intarr(n_elements(tsis_waves))
   for w=0L,n_elements(tsis_waves)-1L do begin
     q=where(tsis_data.wavelength eq tsis_waves[w],count)
     tsis_count[w]=count
   endfor
   

   return, {sorce_count:sorce_count, sorce_waves:result.ref_waves, tsis_count:tsis_count,$
            tsis_waves:tsis_waves}


   
end
