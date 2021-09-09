; docformat = 'rst'
;+
;   Providing the save file containing the VISA SORCE and VISA TSIS diode temperatures, this 
;   routine will plot the diode temperatures as a function of time.
;
; :Examples:
; ::
;     result_savefile='result_20200703.sav'
;     restore, visa_sorce_tsis_temperature.sav
;     temp_plots=tsis_sorce_diode_temp(result_savefile, sorce_visa_temp, tsis_visa_temp)
;-

;+
; :Params:
;    visa_temp_savefile : in, required, type=string
;      The filename of the IDL savefile containing the VISA diode temperatures for SORCE and TSIS during the
;      overlap period
;
; :Keywords:
;
; :Returns:
;     - A plot of diode temperature as a function of time for the SORCE and TSIS overlap period and for the 
;       hypothesised solar minimum period
;
function tsis_sorce_diode_temp, visa_temp_savefile

   if (n_elements(visa_temp_savefile) eq 0 || strlen(visa_temp_savefile) eq 0) then begin
     doc_library,'tsis_sorce_diode_temp'
     print,'*** Missing filename'
     return,-1
   endif
  
   restore, visa_temp_savefile
 
   sorce_temp_jd=round(datetime_adapt(sorce_visa_temp.microsecondssincegpsepoch, from='ugps', to='jd')* 10d) / 10d
   tsis_temp_jd=round(datetime_adapt(tsis_visa_temp.microsecondssincegpsepoch, from='ugps', to='jd')* 10d) / 10d
   
   ;Solar Minimum Period
   start=2458732.50
   finish=2458794.50
   
   ;Plotting the diode temperature for entire overlap
   s=plot(sorce_temp_jd, sorce_visa_temp.temperature, /xst)
   s.color='r'
   s.yrange=[10,30]
   s.xtickunits='year'
   s.xtickformat='(C(CYI,"-",CMOI2.2,"-",CDI2.2))'
   s.xtitle='Date'
   s.ytitle='Temperature ($^\circ$C)'
   s.title='SORCE, TSIS Diode Temperature'
   s.name='SORCE - VISA'
   s.font_size=18
   
   t=plot(tsis_temp_jd, tsis_visa_temp.temperature, overplot=s)
   t.color='b'
   t.name='TSIS - VISA'
   
   v1=plot([start,start], s.yrange, /over, linestyle='--', name='Solar Minimum')
   v2=plot([finish,finish], s.yrange, /over, linestyle='--')
   
   leg=legend(target=[s,t,v1], font_size=14)
   
   
   ;Plotting the diode temperature for solar minimum portion
   p=datetime_adapt('01-Jul-2019 00:00:00.00', from='vms', to='jd')
   q=datetime_adapt('01-Mar-2020 00:00:00.00', from='vms', to='jd')
   
   r=plot(sorce_temp_jd, sorce_visa_temp.temperature, /xst)
   r.color='r'
   r.yrange=[10,30]
   r.xrange=[p,q]
   r.xtickunits='year'
   r.xtickformat='(C(CYI,"-",CMOI2.2,"-",CDI2.2))'
   r.xtitle='Date'
   r.ytitle='Temperature ($^\circ$C)'
   r.title='SORCE, TSIS Diode Temperature'
   r.name='SORCE - VISA'
   r.xmajor=9
   r.xminor=3   
   r.font_size=18

   u=plot(tsis_temp_jd, tsis_visa_temp.temperature, overplot=r)
   u.color='b'
   u.name='TSIS - VISA'

   u1=plot([start,start], r.yrange, /over, linestyle='--', name='Solar Minimum')
   u2=plot([finish,finish], r.yrange, /over, linestyle='--')

   leg1=legend(target=[r,u,u1], font_size=14)
   
   
   return, {s:r, t:u, leg:leg1, v1:u1, v2:u2, full_overlap:s}
   
  
end