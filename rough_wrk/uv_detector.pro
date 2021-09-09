; UV detector:

uv_jd = datetime_adapt(uv.nominalgpstimetag, from='ugps', to='jd')
sorce_uv_0 = uniq(uv_jd)

match, data[tsis_jd].nominal_date_jdn, uv_jd[sorce_uv_0], tsispos, sorcepos_uv, epsilon=0.01

; Now using reference day:
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



end