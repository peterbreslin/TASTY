; ESR detector:

; Seems to be an outlier in the data at a wavelength of 2044.3791nm. Data is being sorted by wavelength 
; correctly, but first value is significantly different. This 'outlier' is in the wrong place!

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




; Not working because need to interpolate the TSIS values to a common wavelength grid (to fit SORCE wavelength scale)
  
;esr_refpos_tsis = where((data.nominal_date_jdn ge ref_day) and (data.nominal_date_jdn le last_day) $
;  and (data.wavelength ge 1601.0) and (data.wavelength le 2412.0))
;
;esr_refpos_sorce = where((sorce_esr ge ref_day) and (sorce_esr le last_day) and $
;  (esr_filtered.minwavelength ge 1601.0) and (esr_filtered.maxwavelength le 2412.0), count)
;
;esr_tsis_wv = where((data.wavelength ge 1601.0) and (data.wavelength le 2412.0))
;esr_trange = data[esr_tsis_wv].wavelength
;
;esr_sorce_wv = where((esr_filtered.minwavelength ge 1601.0) and (esr_filtered.maxwavelength le 2412.0))
;esr_srange = esr_filtered[esr_sorce_wv].minwavelength
;
;
;op = where((sorce_esr ge ref_day) and (sorce_esr le last_day)) ; Overlap period
;t_op_wv = esr_trange[op] ; TSIS overlap corresponding wavelengths
;t_op_irr = data[op].irradiance_1au ; TSIS overlap corresponding irradiances
;t_op_days = tsis_jd[op] ; picking out the overlap days from all days
;
;s_op_wv = esr_srange[op] ; SORCE overlap corresponding wavelengths
;s_op_irr = esr_filtered[op] ; SORCE overlap corresponding irradiances
;s_op_days = esr_jd[op] ; picking out the overlap days from all days
;
;interpolated_tsis = interpol(t_op_irr, t_op_wv, s_op_wv)
;
;
;TEST = scatterplot(s_op_wv, interpolated_tsis, symbol='o', sym_size=0.5)


;
;interpolated_tsis = interpol(data[esr_tsis_wv].irradiance_1au, esr_tsis_wv, esr_sorce_wv)




; Now to plot the data
esr_plot_tsis  =  plot(data[esr_refpos_tsis].wavelength, data[esr_refpos_tsis].irradiance_1au, color='b', $
  name='TSIS_data')

esr_plot_sorce =  plot(esr_filtered[esr_refpos_sorce].minwavelength, esr_filtered[esr_refpos_sorce].irradiance, $
  color='k', linestyle='-', title='ESR Detector: 2018-06-01', xtitle='Wavelength (nm)', $
  ytitle='Irradiance (W m$^{-2}$)', name='SORCE data', symbol='o', sym_filled=1, /over)

leg_esr = legend(target=[esr_plot_tsis, esr_plot_sorce], position=[0.45,0.8])


end