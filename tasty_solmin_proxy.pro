; docformat = 'rst'
;+
;   This routine will plot a number of solar proxies over a time range hypothesised to contain the solar minimum
;   of Solar Cycle 24.
;
; :Author:
;     Peter Breslin
;
; :Examples:
; ::
;     restore, visa_sorce_tsis_temperature.sav
;     proxy_plots=tasty_solmin_proxy(visa_temp_savefile)
;-

;+
; :Params:
;     visa_temp_savefile : in, required, type=string
;       The filename of the IDL savefile containing the VISA diode temperatures for SORCE and TSIS during the
;       overlap period.
;
; :Keywords:
;
; :Returns:
;     Time series plots of the following proxies:
;       - International Sunspot Number 
;       - Penticton Solar Radio Flux at 10.7cm 
;       - Total Solar Irradiance - Daily Average
;       - Composite Solar Lyman-alpha
;       - SORCE Diode Temperature - VISA
;       - TSIS Diode Temperature - VISA
;       - Overplots of the above
;
function tasty_solmin_proxy, visa_temp_savefile

  if (n_elements(visa_temp_savefile) eq 0 || strlen(visa_temp_savefile) eq 0) then begin
    doc_library,'tasty_solmin_proxy'
    print,'*** Missing filename'
    return,-1
  endif
  
  restore, visa_temp_savefile


  ;Reading in the proxy data from Lisird
  sunspots = read_csv('C:\Users\Peter\Desktop\project_data\lisird_data\international_sunspot_number.csv')
  radio_flux = read_csv('C:\Users\Peter\Desktop\project_data\lisird_data\penticton_radio_flux.csv')
  total_irrad = read_csv('C:\Users\Peter\Desktop\project_data\lisird_data\sorce_tsi.csv')
  lyman_alpha = read_csv('C:\Users\Peter\Desktop\project_data\lisird_data\composite_lyman_alpha.csv')
  
  ;Converting time to Julian Date
  sunspots_jd = datetime_adapt(sunspots.field1, from='iso', to='jd')
  radio_flux_jd = datetime_adapt(radio_flux.field1, from='iso', to='jd')
  total_irrad_jd = datetime_adapt(total_irrad.field1, from='iso', to='jd')
  lyman_alpha_jd = datetime_adapt(lyman_alpha.field1, from='iso', to='jd')
  
  
  ;Plotting the LISIRD proxies separately
  
  ;Sunspots
  a=plot(sunspots_jd, sunspots.field2, /xst)
  a.color='deep sky blue'
  a.xtitle='Date'
  a.xtickformat='(C(CYI,"-",CMOI2.2,"-",CDI2.2))'
  a.ytitle='Number'
  a.title='International Sunspot Number - Daily'
  a.xmajor=9
  a.xminor=3
  a.yticklen=0.02
  a.symbol='circle'
  a.sym_size=0.3
  a.font_size=18
  
  u1=plot([2458802.5,2458802.5], a.yrange, /over, linestyle='--')
  u2=plot([2458831.0,2458831.0], a.yrange, /over, linestyle='--')
  
  ;Radio flux
  b=plot(radio_flux_jd, radio_flux.field2, /xst)
  b.yrange=[60,80]
  b.color='medium orchid'
  b.xtitle='Date'
  b.xtickformat='(C(CYI,"-",CMOI2.2,"-",CDI2.2))'
  b.ytitle='Adjusted Flux (SFU)'
  b.title='Penticton Solar Radio Flux at 10.7cm, Time Series'
  b.xmajor=9
  b.xminor=3
  b.yticklen=0.02
  b.symbol='circle'
  b.sym_size=0.3
  b.yminor=4
  b.font_size=18

  u1=plot([2458802.5,2458802.5], b.yrange, /over, linestyle='--')
  u2=plot([2458831.0,2458831.0], b.yrange, /over, linestyle='--')  
  
  ;Total Irradiance
  c=plot(total_irrad_jd, total_irrad.field2, /xst)
  c.color='chocolate'
  c.yrange=[1360.5,1360.9]
  c.xtitle='Date'
  c.xtickformat='(C(CYI,"-",CMOI2.2,"-",CDI2.2))'
  c.ytitle='TSI_1AU (W/m$^2$)'
  c.title='SORCE Total Solar Irradiance - Daily Average, Time Series'
  c.xmajor=9
  c.xminor=3
  c.yticklen=0.02
  c.symbol='circle'
  c.sym_size=0.3
  c.yminor=4
  c.font_size=18

  u1=plot([2458802.5,2458802.5], c.yrange, /over, linestyle='--')
  u2=plot([2458831.0,2458831.0], c.yrange, /over, linestyle='--')
  
  ;Lyman-Alpha
  d=plot(lyman_alpha_jd, lyman_alpha.field2, /xst)
  d.color='green'
  d.xtitle='Date'
  d.xtickformat='(C(CYI,"-",CMOI2.2,"-",CDI2.2))'
  d.ytitle='Irradiance (W/m$^2$)'
  d.title='Composite Solar Lyman-alpha, Time Series'
  d.xmajor=9
  d.xminor=3
  d.yticklen=0.02
  d.symbol='circle'
  d.sym_size=0.3
  d.yminor=4
  d.font_size=18

  u1=plot([2458802.5,2458802.5], d.yrange, /over, linestyle='--')
  u2=plot([2458831.0,2458831.0], d.yrange, /over, linestyle='--')
  
  
  ;Overplotting all proxies
  p=datetime_adapt('01-Jul-2019 00:00:00.00', from='vms', to='jd')
  q=datetime_adapt('01-Mar-2020 00:00:00.00', from='vms', to='jd')
  
  sorce_temp_jd=round(datetime_adapt(sorce_visa_temp.microsecondssincegpsepoch, from='ugps', to='jd')* 10d) / 10d
  tsis_temp_jd=round(datetime_adapt(tsis_visa_temp.microsecondssincegpsepoch, from='ugps', to='jd')* 10d) / 10d
  
  ;Diode Temperatures
  r=plot(sorce_temp_jd, sorce_visa_temp.temperature, /xst)
  r.color='r'
  r.xrange=[p,q]
  r.yticklen=0.02
  r.ytickformat='(A1)'
  r.xtickunits='year'
  r.xtickformat='(C(CYI,"-",CMOI2.2,"-",CDI2.2))'
  r.xtitle='Date'
  r.name='SORCE Diode Temp - VISA'
  r.xmajor=9
  r.xminor=3
  r.yminor=0
  r.ymajor=0
  r.yrange=[0,50]
  r.title='Solar Minimum Proxies'
  r.font_size=20

  t=plot(tsis_temp_jd, tsis_visa_temp.temperature, overplot=r)
  t.color='b'
  t.name='TSIS Diode Temp - VISA'
  
  ;Old solar minimum prediction
  v1=plot([2458802.5,2458802.5], r.yrange, /over, linestyle='--')
  v2=plot([2458831.0,2458831.0], r.yrange, /over, linestyle='--')
  
  ;Sunspots
  ss=plot(sunspots_jd, sunspots.field2, overplot=r)
  ss.color='deep sky blue'
  ss.name='Sunspot Number'
  
  ;Radio Flux
  rf=plot(radio_flux_jd, radio_flux.field2-60, overplot=r)
  rf.color='medium orchid'
  rf.name='F10.7 Solar Radio Flux'
  
  ;TSI
  tsi=plot(total_irrad_jd, (total_irrad.field2*100)-1.36035e5, overplot=r)
  tsi.color='chocolate'
  tsi.name='Total Solar Irradiance'
  
  ;Lyman-alpha
  la=plot(lyman_alpha_jd, ((lyman_alpha.field2*100000)-500)/2.5, overplot=r)
  la.color='g'
  la.name='Composite Solar Lyman-alpha'
  
  leg=legend(target=[r,t,ss,rf,tsi,la], font_size=16)
;  leg1=legend(target=[r,t,ss], font_size=16, linestyle='')
;  leg2=legend(target=[rf,tsi,la], font_size=16, linestyle='')
  
  
  ;Plotting with more space
  
  ;Diode Temperatures
  r=plot(sorce_temp_jd, sorce_visa_temp.temperature*2, /xst)
  r.color='r'
  r.xrange=[p,q]
  r.yticklen=0.02
  r.ytickformat='(A1)'
  r.xtickunits='year'
  r.xtickformat='(C(CYI,"-",CMOI2.2,"-",CDI2.2))'
  r.xtitle='Date'
  r.name='SORCE Diode Temp - VISA'
  r.xmajor=9
  r.xminor=3
  r.yminor=0
  r.ymajor=0
  r.yrange=[0,95]
  r.title='Solar Minimum Proxies'
  r.font_size=20
  ;r.symbol='circle'
  ;r.sym_size=0.3

  t=plot(tsis_temp_jd, tsis_visa_temp.temperature*2, overplot=r)
  t.color='b'
  t.name='TSIS Diode Temp - VISA'
  ;t.symbol='circle'
  ;t.sym_size=0.3

  ;Old solar minimum prediction
  new_start=datetime_adapt('2019-09-06T00:00:00.000', from='iso', to='jd')
  v1=plot([new_start,new_start], r.yrange, linestyle='--', color='m', thick=2, /over)
  ;v2=plot([2458802.5,2458802.5], r.yrange, /over, linestyle='--')
  v3=plot([2458794.5,2458794.5], r.yrange, linestyle='--', color='m', thick=2, /over)
 

  ;Sunspots
  ss=plot(sunspots_jd, sunspots.field2, overplot=r)
  ss.color='deep sky blue'
  ss.name='Sunspot Number'
  ss.symbol='circle'
  ss.sym_size=0.3

  ;Radio Flux
  rf=plot(radio_flux_jd, radio_flux.field2-10, overplot=r)
  rf.color='medium orchid'
  rf.name='F10.7 Solar Radio Flux'
  rf.symbol='circle'
  rf.sym_size=0.3

  ;TSI
  tsi=plot(total_irrad_jd, (total_irrad.field2*100)-1.36045e5, overplot=r)
  tsi.color='chocolate'
  tsi.name='Total Solar Irradiance'
  tsi.symbol='circle'
  tsi.sym_size=0.3

  ;Lyman-alpha
  la=plot(lyman_alpha_jd, ((lyman_alpha.field2*100000)-500)/1.3, overplot=r)
  la.color='g'
  la.name='Composite Solar Lyman-alpha'
  la.symbol='circle'
  la.sym_size=0.3

  leg=legend(target=[r,t,ss,rf,tsi,la], font_size=16)
  
  
  return, {solmin:r, $
           proxies:{sunspots:a, radio_flux:b, total_irrad:c, lymna_alpha:d}}
  

  
end