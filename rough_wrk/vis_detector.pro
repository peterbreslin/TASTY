; VIS detector:

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



end