; docformat = 'rst'
;+
;   Providing the save file for the results obtained from trim_tsis_sorce_data.pro, this routine will 
;   determine both the median and mean solar irradiance during the solar minimum period and compare
;   both averaging methods against each other.
;
; :Author:
;     Peter Breslin
;     
; :Examples:
; ::
;     result_savefile='result_20200703.sav'
;     solmin_mm=tasty_solmin_med_mean(result_savefile)
;-

;+
; :Params:
;    result_savefile : in, required, type=string
;      The filename of the IDL savefile containing the output from the function trim_tsis_sorce_data.pro
;
; :Keywords:
;
; :Returns:
;     An array with the solar minimum period in julian date
;     Plots of the mean and median irradiance for comparisons
;     Two data structures (one for SORCE, one for TSIS) containing:
;      - An array for the irradiance for each day of the solar min period
;      - An array for the mean irradiance at each wavelength over this period
;      - An array for the standard deviation of the irradiance over this period
;      - An array for the median of the irradiance at each wavelength over this period
;
;
function tasty_solmin_med_mean, result_savefile

  if (n_elements(result_savefile) eq 0 && strlen(result_savefile) eq 0) then begin
    doc_library,'tasty_solmin_med_mean'
    print,'*** Missing filenames'
    return,-1
  endif

  restore, result_savefile
  
  ;Using tsis_sorce_solar_min.pro to get irradiance and resistant mean for solar min
  q=tasty_solar_min(result_savefile, [2458732.50,2458794.50])

  ;Finding the median
  med_sorce=median(q.sorce.irrad, dim=1)
  med_tsis=median(q.tsis.irrad, dim=1)
  
  ;Comparing the median to the resistant mean
  s=plot(result.ref_waves, med_sorce/med_tsis, name='Median: SORCE$\div$TSIS', /xst)
  s.color='r'
  s.yticklen=0.02
  s.title='Solar Minimum Period (2019-09-06 to 2019-12-13) - Median vs. Mean'
  s.xtitle='Wavelength nm'
  s.ytitle='Ratio'
  s.xminor=3
  s.xticklen=0.03
  s.xtickvalues=[400:2400:400]
  s.font_size=18

  t=plot(result.ref_waves, q.sorce.mean_irrad/q.tsis.mean_irrad, name='Mean: SORCE$\div$TSIS', /over)
  t.color='b'
  
  leg=legend(target=[s,t], font_size=16)
  
  r=plot(result.ref_waves, med_sorce/med_tsis, name='Median: SORCE$\div$TSIS', /xst)
  r.xrange=[208,350]
  r.color='r'
  r.xticklen=0.03
  r.title='Solar Minimum (Median vs. Mean) - UV'
  r.xtitle='Wavelength nm'
  r.ytitle='Ratio'
  r.yticklen=0.02
  ;s.xtickvalues=
  r.font_size=18

  u=plot(result.ref_waves, q.sorce.mean_irrad/q.tsis.mean_irrad, name='Mean: SORCE$\div$TSIS', /over)
  u.xrange=[208,350]
  u.color='b'

  leg=legend(target=[r,u], font_size=16)
  
  w=plot(result.ref_waves, med_sorce/med_tsis, name='Median: SORCE$\div$TSIS', /xst)
  w.xrange=[1500,2400]
  w.yticklen=0.02
  w.xticklen=0.03
  w.yrange=[1.00,1.20]
  w.color='r'
  w.title='Solar Minimum (Median vs. Mean) - IR'
  w.xtitle='Wavelength nm'
  w.ytitle='Ratio'
  ;s.xtickvalues=
  w.font_size=18

  v=plot(result.ref_waves, q.sorce.mean_irrad/q.tsis.mean_irrad, name='Mean: SORCE$\div$TSIS', /over)
  v.xrange=[1500,2400]
  v.color='b'

  leg=legend(target=[w,v], font_size=16)
  
  a=plot(result.ref_waves, abs((1.0-(med_sorce/q.sorce.mean_irrad))*100), /xst)
  a.color='r'
  a.yticklen=0.02
  a.yminor=3
  a.ylog=1
  a.xticklen=0.03
  a.title='SORCE: Percentage difference between Median and Mean'
  a.xtitle='Wavelength nm'
  a.ytitle='Percentage (%)'
  a.xtickvalues=[400:2400:400]
  a.font_size=18
  
  b=plot(result.ref_waves, abs((1.0-(med_tsis/q.tsis.mean_irrad))*100), /xst)
  b.color='b'
  b.xminor=4
  b.ylog=1
  b.yticklen=0.02
  b.xticklen=0.03
  b.title='TSIS: Percentage difference between Median and Mean'
  b.xtitle='Wavelength nm'
  b.ytitle='Percentage (%)'
  b.xtickvalues=[400:2400:400]
  b.font_size=18


  
  return, {period:q.period, full:s, uv:r, ir:w, sorce_ratio:a, tsis_ratio:b, $
           sorce:{median:med_sorce, irrad:q.sorce.irrad, mean_irrad:q.sorce.mean_irrad, mean_sdev:q.sorce.mean_sdev}, $
           tsis:{median:med_tsis, irrad:q.tsis.irrad, mean_irrad:q.tsis.mean_irrad, mean_sdev:q.tsis.mean_sdev}}  

  
  
  
  
end