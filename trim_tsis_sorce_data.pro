; docformat = 'rst'
;+
;   Providing two IDL save files with the expected format for TSIS-SIM and SORCE-SIM,
;   this routine will organize the data in 2D array corresponding to the days with
;   overlap and re-sampled to a common(SORCE) wavelength grid.
;
; :Author:
;
; :Examples:
; ::
;     sorce_savefile='SORCE_L3_V2703_wjumps_240.sav'
;     tsis_savefile='TSIS_L3_c24h_V04.sav'
;     result=trim_tsis_sorce_data(sorce_savefile, tsis_savefile)
;-

;+
; :Params:
;    sorce_savefile : in, required, type=string
;      The filename of the IDL savefile containing the SORCE L3 data
;    tsis_savefile : in, required, type=string
;      The filename of the IDL savefile containing the TSIS L3 data
;
; :Keywords:
;
; :Returns:
;     A data structure with an array for the wavelength grid (in nm), an array for the overlapping days (in Julian), 
;     a 2D array for the irradiances of TSIS and a 2D array for the irradiances of SORCE.
;
function trim_tsis_sorce_data, sorce_savefile, tsis_savefile, ref_waves_file=ref_waves_file, indata=indata

   if (n_elements(sorce_savefile) eq 0 || strlen(sorce_savefile) eq 0) && n_elements(indata) eq 0 then begin
       doc_library,'trim_tsis_sorce_data'
       print,'*** Missing filenames'
       return,-1
   endif

   ; check if the user passed a data structure as input to avoid a LOT of computational time
   ;***************
   if size(indata,/tname) ne 'STRUCT' then begin
       ; expecting the SORCE data to be store in 4 arrays: UV, VIS, IR and ESR
       restore,sorce_savefile

       ; concatonate the SORCE data in a single array
       sorce_data=[temporary(uv),temporary(vis),temporary(ir),temporary(esr)]

       ; define the start of the TSIS dataset on mission day 100
       tsis_start=100d
       gps0=datetime_adapt(tsis_start, from='tsis',to='ugps')

       ; remove all entries with invalid irradiances
       p=where(sorce_data.irradiance le 0.0 or FINITE(sorce_data.irradiance) eq 0 or $
               sorce_data.nominalgpstimetag lt gps0,count,complement=cp)
       if count gt 0 then sorce_data = sorce_data[cp]
       ; sort sorce_data along timetag
       s=multisort(sorce_data.nominalgpstimetag, sorce_data.minwavelength)
       sorce_data=sorce_data[s]

       ; the TSIS data is expected to be in a single array
       restore,tsis_savefile
       tsis_data=temporary(data)

       ; remove all entries with invalid irradiances
       jd0=datetime_adapt(tsis_start, from='tsis', to='jd')
       p=where(tsis_data.irradiance_1au le 0.0 or FINITE(tsis_data.irradiance_1au) eq 0 or $
               tsis_data.nominal_date_jdn lt jd0,count,complement=cp)
       if count gt 0 then tsis_data = tsis_data[cp]
       s=multisort(tsis_data.nominal_date_jdn, tsis_data.wavelength)
       tsis_data = tsis_data[s]

       ; find the common days between SORCE and TSIS (only keep 1 decimal point to avoid float point errors)
       sorce_jd = round(datetime_adapt(sorce_data.nominalgpstimetag, from='ugps', to='jd') * 10d) / 10d
       sorce_jd_uniq=sorce_jd[uniq(sorce_jd,sort(sorce_jd))]
       tsis_jd = round(tsis_data.nominal_date_jdn * 10d) / 10d
       tsis_jd_uniq=tsis_jd[uniq(tsis_jd,sort(tsis_jd))]
       match,sorce_jd_uniq,tsis_jd_uniq,sa,sb

       ; generate the array for our matching days
       ref_days = sorce_jd_uniq[sa]

       print,n_elements(ref_days),format='(I0," days of overlap")'

       ; get the reference wavelength by looking at the SORCE data during the nominal mission
       ; where we expect to have a complete set of data
       if n_elements(ref_waves_file) eq 0 then begin
           ; find the largest number of unique wavelengths at any one day and use that
           ; as our ref_waves
           qq=[]
           for i=0L,n_elements(ref_days)-1 do begin 
               p=where(sorce_jd eq ref_days[i],count) 
               q=uniq(sorce_data[p].minwavelength,sort(sorce_data[p].minwavelength)) 
               qq=[qq,n_elements(q)]
           endfor
           mx=max(qq,pos)
           p=where(sorce_jd eq ref_days[pos],count) 
           s=sort(sorce_data[p].minwavelength) 
           q=uniq(sorce_data[p[s]].minwavelength)
           ref_waves=sorce_data[p[s[q]]].minwavelength
       endif else begin
           ; it is expected that the IDL save file contains an array named ref_waves
           restore,ref_waves_file
           p=where(ref_waves ge 208.0 and ref_waves lt 2402.0)
           ref_waves=ref_waves[p]
       endelse
       nwaves=n_elements(ref_waves)

       ; fill in the missing data for SORCE by copying the irradiances from the closest day
       ; loop over every day
       print, "filling in SORCE data"
       new_data=list()

       sorce_missing_waves=lonarr(nwaves)
       for day=0L,n_elements(ref_days)-1 do begin
           p=where(sorce_jd eq ref_days[day], count)
           if count eq 0 then begin
               ref_days[day]=-1
               continue
           endif
           waves=sorce_data[p].minwavelength
           waves=waves[uniq(waves,sort(waves))]
           match2,ref_waves,waves,sa,sb
           missing_pos=where(sa eq -1,count)
           if count eq 0 then continue 
           sorce_missing_waves[missing_pos] += 1
           ; if we have too many missing wavelengths ignore that day
           if count lt nwaves/2.0 then begin
               ; loop over every single wavelength and find the closest valid one
               print, day, count, format='("day=",I0," filling in ",I0," SORCE wavelengths")'
               for w=0L,count-1L do begin
                   k=where(sorce_data.minwavelength eq ref_waves[missing_pos[w]])
                   mn=min(abs(sorce_jd[k] - ref_days[day]),pos)
                   ; add an entry in the data array
                   dd = sorce_data[k[pos]]
                   dd.NOMINALGPSTIMETAG = datetime_adapt(ref_days[day],from='jd',to='ugps')
                   new_data.add,dd
               endfor
           endif else begin
               ref_days[day]=-1
           endelse
       endfor
       if n_elements(new_data) gt 0 then begin
           sorce_data=[sorce_data,new_data.toArray(/no_copy)]
           sorce_jd = round(datetime_adapt(sorce_data.nominalgpstimetag, from='ugps', to='jd') * 10d) / 10d
       endif

       ; remove days with too many missing wavelengths
       p=where(ref_days eq -1,count,comp=pp)
       if count gt 0 then ref_days=ref_days[pp]

       ; get the nominal set of wavelengths for TSIS
       qq=[]
       for i=0L,n_elements(ref_days)-1 do begin 
           p=where(tsis_jd eq ref_days[i],count) 
           q=uniq(tsis_data[p].wavelength,sort(tsis_data[p].wavelength)) 
           qq=[qq,n_elements(q)]
       endfor
       mx=max(qq,pos)
       p=where(tsis_jd eq ref_days[pos],count) 
       s=sort(tsis_data[p].wavelength) 
       q=uniq(tsis_data[p[s]].wavelength)
       tsis_waves=tsis_data[p[s[q]]].wavelength
       tsis_nwaves=n_elements(tsis_waves)

       ; fill in the missing data for TSIS by copying the irradiances from the closest day
       ; loop over every day
       print, "filling in TSIS data"
       new_data=list()
       tsis_missing_waves=lonarr(n_elements(tsis_waves))
       for day=0L,n_elements(ref_days)-1 do begin
           p=where(tsis_jd eq ref_days[day], count)
           if count eq 0 then continue
           waves=tsis_data[p].wavelength
           waves=waves[uniq(waves,sort(waves))]
           match2,tsis_waves,waves,sa,sb
           missing_pos=where(sa eq -1,missing_count)
           if missing_count gt 0 then tsis_missing_waves[missing_pos] += 1
           if missing_count eq 0 then continue 
           if missing_count lt tsis_nwaves/2.0 then begin
               ; loop over every single wavelength and find the closest valid one
               print, day, missing_count, format='("day=",I0," filling in ",I0," tsis wavelengths")'
               for w=0L,missing_count-1L do begin
                   k=where(tsis_data.wavelength eq tsis_waves[missing_pos[w]])
                   mn=min(abs(tsis_jd[k] - ref_days[day]),pos)
                   ; add an entry in the data array
                   dd = tsis_data[k[pos]]
                   dd.NOMINAL_DATE_JDN = ref_days[day]
                   dd.NOMINAL_DATE_YYYYMMDD = string(jd2ymd(ref_days[day]),format='(i4,i02,i02)')
                   new_data.Add,dd
               endfor
           endif else begin
               ref_days[day]=-1
           endelse
       endfor
       if n_elements(new_data) gt 0 then begin
           tsis_data=[tsis_data,new_data.toArray(/no_copy)]
           tsis_jd = round(tsis_data.nominal_date_jdn * 10d) / 10d
       endif

       ; remove days with too many missing wavelengths
       p=where(ref_days eq -1,count,comp=pp)
       if count gt 0 then ref_days=ref_days[pp]

       ; fill the array with NaN so the missing data will appear as NaN
       tsis_irrad = dblarr(n_elements(ref_days), n_elements(ref_waves))
       tsis_irrad *= !VALUES.D_NAN
       sorce_irrad = tsis_irrad

       ; loop over every ovelap day
       for day=0L, n_elements(ref_days)-1L do begin

           print,day,format='("day ",I0)'

           ; process SORCE data first
           p=where(sorce_jd eq ref_days[day], count)
           if count eq 0 then continue
           s=sort(sorce_data[p].minwavelength)
           s_wave=sorce_data[p[s]].minwavelength
           s_irrad = sorce_data[p[s]].irradiance
           ; make sure we only fill in the ref_waves
           match, s_wave, ref_waves, sa, sb, epsilon=0.005
           sorce_irrad[day,sb] = s_irrad[sa]

           ; now process TSIS data
           p=where(tsis_jd eq ref_days[day], count)
           if count eq 0 then continue
           s=sort(tsis_data[p].wavelength)
           ; use interp4 since interpol fails from time to time
           interp4, tsis_data[p[s]].wavelength, tsis_data[p[s]].irradiance_1AU, ref_waves, t_irrad
           tsis_irrad[day,*] = t_irrad

       endfor

   endif else begin
       ;********************
       ; a structure was passed in
       sorce_irrad = indata.sorce.irrad
       tsis_irrad = indata.tsis.irrad
       ref_waves=indata.ref_waves
       ref_days=indata.ref_days
       sorce_waves=indata.sorce.wavelength
       sorce_missing_waves=indata.sorce.missing_waves
       tsis_waves=indata.tsis.wavelength
       tsis_missing_waves=indata.tsis.missing_waves
   endelse

   p=where(finite(sorce_irrad) eq 0,count)
   if count ne 0 then sorce_irrad[p]=!VALUES.D_NAN
   p=where(finite(tsis_irrad) eq 0,count)
   if count ne 0 then tsis_irrad[p]=!VALUES.D_NAN

   ; here is an example code to do the resistant_mean one wavelength at a time
   sigma = 2.0
   sorce_mean_irrad = dblarr(n_elements(ref_waves))
   sorce_mean_std = dblarr(n_elements(ref_waves))
   for ww=0L, n_elements(ref_waves)-1L do begin
      resistant_mean,sorce_irrad[*,ww], sigma, mean_irrad, num_rej, good=good
      sorce_mean_irrad[ww] = mean_irrad
      ; ignore the points outside our sigma threshold
      sorce_mean_std[ww] = stddev(sorce_irrad[good,ww])
   endfor

   tsis_mean_irrad = dblarr(n_elements(ref_waves))
   tsis_mean_std = dblarr(n_elements(ref_waves))
   for ww=0L, n_elements(ref_waves)-1L do begin
      resistant_mean,tsis_irrad[*,ww], sigma, mean_irrad, num_rej, good=good
      tsis_mean_irrad[ww] = mean_irrad
      ; ignore the points outside our sigma threshold
      tsis_mean_std[ww] = stddev(tsis_irrad[good,ww])
   endfor

   ; plt=errorplot(result.ref_waves,result.sorce.mean_irrad,result.sorce.mean_std, font_size=14,xtitle='Wavelength (nm)',$
   ;               ytitle='Irradiance',name='SORCE',dimensions=[1200,800],color='r',errorbar_color='grey',errorbar_capsize=0.1,$
   ;               thick=3,/xlog,/xst)

   return, {ref_days:ref_days, ref_waves:ref_waves, $
            sorce:{irrad:sorce_irrad, mean_irrad:sorce_mean_irrad, mean_std:sorce_mean_std, $
                   wavelength:ref_waves, missing_waves:sorce_missing_waves}, $
            tsis:{irrad:tsis_irrad, mean_irrad:tsis_mean_irrad, mean_std:tsis_mean_std, $
                   wavelength: tsis_waves, missing_waves:tsis_missing_waves}}

end
