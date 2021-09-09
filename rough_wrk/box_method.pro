; 08/06/2020 meeting
; 
; 'Box' method - easier to get an average and std. dev. row by row:
;   Organise data in one big 2D array
;   x = number of overlapping days
;   y = number of wavelengths
;   
;   Two additional arrays:
;     wavelengths for each day
;     julday for each column


;TSIS
st=sort(data.nominal_date_jdn) ;need to sort data before using uniq to find the unique dates
qt=uniq(data[st].nominal_date_jdn) ;data[st].nominal_date_jdn gives back the date values
tsis_jd=data[st[qt]].nominal_date_jdn

;SORCE
data_sorce=[uv,vis,ir,esr] ;concatenating the SORCE detectors 
sorce_jd=datetime_adapt(data_sorce.(1),from='ugps',to='jd') ;data_sorce.(1) specifies the field at index 1
ss=sort(sorce_jd)
qs=uniq(sorce_jd[ss])
sorce_jd=sorce_jd[ss[qs]]

match, tsis_jd, sorce_jd, sa, sb, epsilon=0.01

ref_days=tsis_jd[sa] ;This is the x-dimension of the 2D array (number of overlapping days)
sorce_days=datetime_adapt(data_sorce.(1),from='ugps',to='jd')
p=where(sorce_days eq sorce_jd[1000]) ;1000 as ~ definitely some good data here
;p contains the subscripts 
;1734 wavelengths for SORCE spectra on jd 1000

;plt=plot(data_sorce[p].minwavelength) ;;clearly some funky data

; find corresponding wavelengths
w=sort(data_sorce[p].minwavelength)
qw=uniq(data_sorce[p[w]].minwavelength)
ref_waves=data_sorce[p[w]].minwavelength

;u=where(round(sorce_days) ge min(round(ref_days)) and round(sorce_days) le max(round(ref_days)))

sorce_days=round(sorce_days*10d)/10d 
ref_days=round(ref_days*10d)/10d

new_sorce=[]
for i=0L,n_elements(ref_days)-1L do begin
  m=where(sorce_days eq ref_days[i])
  n=sort(data_sorce[m].minwavelength)
  new_sorce=[new_sorce, data_sorce[m[n]]] ;contains esr/vis/uv/ir data for overlap period
endfor


; Now do same for TSIS, need to interpolate to get TSIS values on a SORCE scale ---> interpolate ref_waves for TSIS

; Getting the TSIS wavelength values corresponding to the overlap period
h=sort(data[p].wavelength)
o=uniq(data[p[h]].wavelength)
ref_waves_t=data[p[h]].wavelength

tsis_days = round(data.(1)*10d)/10d
new_tsis=[]

for i=0L,n_elements(ref_days)-1L do begin
  x=where(tsis_days eq ref_days[i])
  y=sort(data[x].wavelength)
  new_scan=data[x[y]]
  r=where(new_scan.irradiance_1au gt 0.0)
  new_irrad = interpol(new_scan[r].irradiance_1au, new_scan[r].wavelength, ref_waves, /spl)
  new_tsis=[new_tsis,new_scan]
endfor

; Corresponding irradiance values
tsis_irr=data[ref_waves_t].(5)


end