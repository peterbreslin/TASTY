; IR detector:

; Seems to be an outlier in the data at a wavelength of 1271.20nm. Data is being sorted by wavelength correctly,
; but first value is significantly different. This 'outlier' is in the wrong place!

ir_jd = datetime_adapt(ir.nominalgpstimetag, from='ugps', to='jd')

ir_jd = ir_jd[sort(ir_jd)]

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
  ytitle='Irradiance (W m$^{-2}$)', name='SORCE data', symbol='o', sym_filled=1, /over)

leg_ir = legend(target=[ir_plot_tsis, ir_plot_sorce], position=[0.45,0.8])


end