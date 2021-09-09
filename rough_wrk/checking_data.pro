; SORCE file: SORCE_L3_V2703_wjumps_208
; TSIS file:  TSIS_L3_c24h_V04

; These contain data for the whole mission -> only need the overlap period


; ------ Quick look at the data sets:

;; Plotting SORCE irradiances
;p = where(vis.minwavelength eq 311.89d)
;sorce_plt = plot(gps2jd(vis[p].NOMINALGPSTIMETAG/1d6), vis[p].irradiance, color='blue', title = 'SORCE', $
;  xtitle = 'Time (julday)', ytitle = 'Irradiance (W m$^{-2}$)')
;
;; Plotting TSIS irradiances
;d = where(data.wavelength eq 200.015, count)
;tsis_plt = plot(data[d].NOMINAL_DATE_JDN, data[d].irradiance_1au, color='green', title = 'TSIS', $
;  xtitle = 'Time (julday)', ytitle = 'Irradiance (W m$^{-2}$)')
;  
;
;; ------ Finding the unique days for both SORCE and TSIS:
;
; Converting the ugps time in SORCE file to Julian Day
gps_vis     =     vis.NOMINALGPSTIMETAG
gps_ir      =     ir.NOMINALGPSTIMETAG
gps_uv      =     uv.NOMINALGPSTIMETAG
gps_esr     =     esr.NOMINALGPSTIMETAG

sorce_vis   =     datetime_adapt(gps_vis, from='ugps',  to='jd') 
sorce_ir    =     datetime_adapt(gps_ir,  from='ugps',  to='jd')
sorce_uv    =     datetime_adapt(gps_uv,  from='ugps',  to='jd')
sorce_esr   =     datetime_adapt(gps_esr, from='ugps',  to='jd')

sorce = [sorce_vis, sorce_ir, sorce_uv, sorce_esr]
tsis  = data.NOMINAL_DATE_JDN

q0_i = uniq(tsis)     ; array with the indicies that are not duplicates
q1_i = uniq(sorce)

q0 = tsis[q0_i]
q1 = sorce[q1_i]

unique_days = create_struct('gps_vis', gps_vis, 'gps_ir', gps_ir, 'gps_uv', gps_uv, $
  'gps_esr', gps_esr, 'sorce_vis', sorce_vis, 'sorce_ir', sorce_ir, 'sorce_uv', sorce_uv, $
  'sorce_esr', sorce_esr, 'sorce', sorce, 'tsis', tsis, 'q0', q0, 'q1', q1)





end
