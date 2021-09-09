; Plotting and cleaning up data files ------> VERSION 2 
; SORCE file: SORCE_L3_V2703_wjumps_208
; TSIS file:  TSIS_L3_c24h_V04
; These files contain data for the whole mission -> only need the overlap period

; Tasks:
;   1) Determine the unique days for both SORCE (for each detector) and TSIS
;   2) Determine which days MATCH
;   3) Pick a reference day and plot each spectra

; Note: Need to remove zero values from data and sort by wavelength


; Firstly, pick a reference day from TSIS to use ---> picking June 1 2018
ref_day = datetime_adapt([2018d, 6, 1], from='ymd', to='jd') + 0.5d  ;adding 0.5 to round day up
last_day = 2458904.50 +0.5d ;2020-02-25
tsis_jd = uniq(data.nominal_date_jdn)  ;contains all wavelengths for TSIS



; ----> Beginning with UV detector:

uv_jd = datetime_adapt(uv.nominalgpstimetag, from='ugps', to='jd')
sorce_uv_0 = uniq(uv_jd)

match, data[tsis_jd].nominal_date_jdn, uv_jd[sorce_uv_0], tsispos, sorcepos_uv, epsilon=0.01

sorce_uv = round(uv_jd*10d)/10d
uv_refpos_tsis  =  where(data.nominal_date_jdn eq ref_day and data.wavelength ge 208.0 and data.wavelength le 310.0)
uv_refpos_sorce =  where(sorce_uv eq ref_day and uv.minwavelength ge 208.0 and uv.maxwavelength le 310.0, count)

; Now to plot the data
uv_plot_tsis  =  plot(data[uv_refpos_tsis].wavelength, data[uv_refpos_tsis].irradiance_1au, color='violet', $
  name='TSIS_data')

uv_plot_sorce =  plot(uv[uv_refpos_sorce].minwavelength, uv[uv_refpos_sorce].irradiance, color='k',$
  linestyle='-.', title='Ultraviolet Detector: 2018-06-01', xtitle='Wavelength (nm)', $
  ytitle='Irradiance (W m$^{-2}$)', name='SORCE data', /over)

leg_uv = legend(target=[uv_plot_tsis, uv_plot_sorce], position=[0.45,0.8])



; ----> IR detector:

ir_jd = datetime_adapt(ir.nominalgpstimetag, from='ugps', to='jd')
sorce_ir_0 = uniq(ir_jd)

match, data[tsis_jd].nominal_date_jdn, ir_jd[sorce_ir_0], tsispos, sorcepos_ir, epsilon=0.01

; sorting by wavelength
ir_minwv_sort = sort(ir.minwavelength)
ir_maxwv_sort = sort(ir.maxwavelength)

sorce_ir = round(ir_jd*10d)/10d
ir_refpos_tsis  =  where(data.nominal_date_jdn eq ref_day and data.wavelength ge 952.0 and data.wavelength le 1598.0)
ir_refpos_sorce =  where(sorce_ir eq ref_day and ir[ir_minwv_sort].minwavelength ge 952.0 and ir[ir_maxwv_sort].maxwavelength le 1598.0, count)

; Now to plot the data
ir_plot_tsis  =  plot(data[ir_refpos_tsis].wavelength, data[ir_refpos_tsis].irradiance_1au, color='r', $
  name='TSIS_data')

ir_plot_sorce =  plot(ir[ir_refpos_sorce].minwavelength, ir[ir_refpos_sorce].irradiance, color='k',$
  linestyle='-', title='Infrared Detector: 2018-06-01', xtitle='Wavelength (nm)', $
  ytitle='Irradiance (W m$^{-2}$)', name='SORCE data', /over)

leg_ir = legend(target=[ir_plot_tsis, ir_plot_sorce], position=[0.45,0.8])



; ----> VIS detector:

vis_jd = datetime_adapt(vis.nominalgpstimetag, from='ugps', to='jd')
sorce_vis_0 = uniq(vis_jd)

match, data[tsis_jd].nominal_date_jdn, vis_jd[sorce_vis_0], tsispos, sorcepos_vis, epsilon=0.01

sorce_vis = round(vis_jd*10d)/10d
vis_refpos_tsis  =  where(data.nominal_date_jdn eq ref_day and data.wavelength ge 310.0 and data.wavelength le 947.0)
vis_refpos_sorce =  where(sorce_vis eq ref_day and vis.minwavelength ge 310.0 and vis.maxwavelength le 947.0, count)

; Now to plot the data
vis_plot_tsis  =  plot(data[vis_refpos_tsis].wavelength, data[vis_refpos_tsis].irradiance_1au, color='g', $
  name='TSIS_data')

vis_plot_sorce =  plot(vis[vis_refpos_sorce].minwavelength, vis[vis_refpos_sorce].irradiance, color='k',$
  linestyle='-.', title='Visible Detector: 2018-06-01', xtitle='Wavelength (nm)', ytitle='Irradiance (W m$^{-2}$)', $
  name='SORCE data', /over)

leg_vis = legend(target=[vis_plot_tsis, vis_plot_sorce], position=[0.45,0.8])



; ----> ESR detector:

; Need to filter out the zero's in the irradiance values (and have the correct corresponding values for everything else)
esr_good = where(esr.irradiance gt 0)
esr_filtered = esr[esr_good]

; sorting by wavelength
esr_minwv_sort = sort(esr.minwavelength)
esr_maxwv_sort = sort(esr.maxwavelength)

esr_jd = datetime_adapt(esr_filtered.nominalgpstimetag, from='ugps', to='jd')
sorce_esr_0 = uniq(esr_jd)

match, data[tsis_jd].nominal_date_jdn, esr_jd[sorce_esr_0], tsispos, sorcepos_esr, epsilon=0.01

sorce_esr = round(esr_jd*10d)/10d
esr_refpos_tsis  =  where(data.nominal_date_jdn eq ref_day and data.wavelength ge 1601.0 and data.wavelength le 2412.0)
esr_refpos_sorce =  where(sorce_esr eq ref_day and esr_filtered.minwavelength ge 1601.0 and esr_filtered.maxwavelength le 2412.0, count)

; Now to plot the data
esr_plot_tsis  =  plot(data[esr_refpos_tsis].wavelength, data[esr_refpos_tsis].irradiance_1au, color='b', $
  name='TSIS_data')

esr_plot_sorce =  plot(esr_filtered[esr_refpos_sorce].minwavelength, esr_filtered[esr_refpos_sorce].irradiance, $
  color='k', linestyle='-', title='ESR Detector: 2018-06-01', xtitle='Wavelength (nm)', $
  ytitle='Irradiance (W m$^{-2}$)', name='SORCE data', /over)

leg_esr = legend(target=[esr_plot_tsis, esr_plot_sorce], position=[0.45,0.8])



; -----> Combining the detectors:

full_plot  =  plot(data[uv_refpos_tsis].wavelength, data[uv_refpos_tsis].irradiance_1au, color='r', $
  title='Full Captured Spectrum: 2018-06-01', xtitle='Wavelength (nm)', ytitle='Irradiance (W m$^{-2}$)',$
  name='TSIS Data')
A =  plot(uv[uv_refpos_sorce].minwavelength, uv[uv_refpos_sorce].irradiance, color='b',$
  linestyle='-.', name='SORCE Data', /over)

B  =  plot(data[ir_refpos_tsis].wavelength, data[ir_refpos_tsis].irradiance_1au, color='r', /over)
C  =  plot(ir[ir_refpos_sorce].minwavelength, ir[ir_refpos_sorce].irradiance, color='b',$
  linestyle='-.', /over)

D  =  plot(data[vis_refpos_tsis].wavelength, data[vis_refpos_tsis].irradiance_1au, color='r', /over)
E  =  plot(vis[vis_refpos_sorce].minwavelength, vis[vis_refpos_sorce].irradiance, color='b',$
  linestyle='-.', /over)

F  =  plot(data[esr_refpos_tsis].wavelength, data[esr_refpos_tsis].irradiance_1au, color='r', /over)
G  =  plot(esr_filtered[esr_refpos_sorce].minwavelength, esr_filtered[esr_refpos_sorce].irradiance, color='b',$
  linestyle='-.', /over)

full_leg = legend(target=[full_plot, A])




end