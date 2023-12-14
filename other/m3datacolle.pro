pro m3datacolle
;把m3数据转成反射率，并收集成相曲线数据点
cd,'F:\M3'

;3数据波长（nm）及对应太阳辐照度（W/m2/um），共85组
wavelengthm3=[460.98999,  500.920013, 540.840027, 580.765015, 620.689941, 660.609985, 700.537537, 730.47998,  750.440002, 770.400024, 790.36499,  810.330017, 830.290039, 850.25, 870.209961, 890.174988, 910.140015, 930.099976, 950.059998, 970.02002,  989.97998,  1009.950012,  1029.910034,  1049.869995,  1069.829956,  1089.790039,  1109.76001, 1129.719971,  1149.679932,  1169.640015,  1189.599976,  1209.570068,  1229.530029,  1249.48999, 1269.449951,  1289.410034,  1309.375, 1329.339966,  1349.300049,  1369.26001, 1389.219971,  1409.185059,  1429.150024,  1449.109985,  1469.070068,  1489.030029,  1508.994995,  1528.959961,  1548.920044,  1578.859985,  1618.787598,  1658.710083,  1698.630005,  1738.560059,  1778.47998, 1818.405029,  1858.330078,  1898.25,  1938.179932,  1978.099976,  2018.022461,  2057.949951,  2097.869873,  2137.797363,  2177.719971,  2217.642578,  2257.570068,  2297.48999, 2337.414795,  2377.340088,  2417.26001, 2457.189941,  2497.109863,  2537.034912,  2576.959961,  2616.879883,  2656.807617,  2696.72998, 2736.652344,  2776.580078,  2816.5, 2856.427246,  2896.350098,  2936.272461,  2976.199951]
solar=[2022.662109, 1934.504639,  1875.621826,  1833.137451,  1689.644409,  1550.267334,  1428.238281,  1324.72168, 1271.074707,  1216.917114,  1162.946045,  1107.837036,  1053.718018,  985.262878, 946.577942, 920.729126, 879.042053, 838.584351, 803.807495, 774.441345, 747.215698, 714.813477, 688.451416, 660.18042,  627.847351, 595.195679, 576.041504, 554.240967, 536.109741, 515.018677, 495.133911, 478.304504, 465.552826, 448.761108, 431.568756, 413.441162, 402.579224, 389.435547, 376.903381, 363.470428, 352.801758, 339.575775, 326.363434, 315.832489, 305.71637,  295.547668, 285.620911, 279.833801, 270.836487, 254.320526, 239.49379,  222.479904, 205.766937, 188.134918, 176.529922, 161.412659, 148.559753, 138.283081, 127.823883, 120.320206, 112.589493, 104.922226, 97.874298,  91.578003,  84.585487,  80.119522,  75.024551,  70.138199,  65.460922,  61.354645,  57.781689,  54.253448,  51.185177,  48.428665,  45.669037,  42.878807,  40.754391,  38.894337,  36.834885,  34.852249,  33.181812,  31.370193,  29.84897, 28.347176,  26.991705]

filename=dialog_pickfile(filter='*RDN.IMG',/read,/multiple)
number=size(filename)
num=number[3]



for picn=0,num-1 do begin
  rstm=[]
  rsth=[]
  
  filenam=filename[picn]
  filepos=strpos(filenam,'_RDN')
  filen=strmid(filenam,0,filepos)
  filegeo=strjoin([filen,'_OBS.IMG'])
  
  fileout1=strjoin([filen,'_iof.img'])
  fileout2=strjoin([filen,'_corgeo.img'])
  fileoutm=strjoin([filen,'_stam.txt'])
  fileouth=strjoin([filen,'_stah.txt'])
  
  envi_open_file,filegeo,r_fid =fid
  ENVI_FILE_QUERY,fid,dims= dims,bnames= bnames1,nb = nb1,ns = ns, nl = nl,wl=wavelength1
  obsdata=fltarr(ns,nl,nb1)
  for band=0,nb1-1 do begin
    obsdata[*,*,band]= ENVI_GET_DATA(fid=fid, dims=dims, pos=band)
  endfor
  icorrect=fltarr(ns,nl,1)
  ecorrect=fltarr(ns,nl,1)
  phi=fltarr(ns,nl,1)
  icorrect[*,*,0]=acos((cos(obsdata[*,*,1]*!pi/180))*(cos(obsdata[*,*,7]*!pi/180))+(sin(obsdata[*,*,1]*!pi/180))*(sin(obsdata[*,*,7]*!pi/180))*(cos((obsdata[*,*,0]-obsdata[*,*,8])*!pi/180)))
  ecorrect[*,*,0]=acos((cos(obsdata[*,*,3]*!pi/180))*(cos(obsdata[*,*,7]*!pi/180))+(sin(obsdata[*,*,3]*!pi/180))*(sin(obsdata[*,*,7]*!pi/180))*(cos((obsdata[*,*,2]-obsdata[*,*,8])*!pi/180)))
  obsdata[*,*,1]=icorrect[*,*,0]*180/(!pi)
  obsdata[*,*,3]=ecorrect[*,*,0]*180/(!pi)
  ;1=i 3=e 0,2=phi 4=g,但这个g没校准，暂时不能用

  
  for i=0,ns-1,1 do begin; 替换不合理i,e值
    for j=0,nl-1,1 do begin
      if obsdata[i,j,1] ge 90 then begin
        obsdata[i,j,1]=89.9
      endif
      if obsdata[i,j,3] ge 90 then begin
        obsdata[i,j,3]=89.9
      endif
      phi[i,j,0]=abs(obsdata[i,j,0]-obsdata[i,j,2])
      if phi[i,j,0] gt 180 then begin
        phi[i,j,0]=360-phi[i,j,0]
      endif
      phi[i,j,0]=phi[i,j,0]
    endfor
  endfor
  obsdata[*,*,4] = acos(cos(icorrect[*,*,0])*cos(ecorrect[*,*,0])+sin(icorrect[*,*,0])*sin(ecorrect[*,*,0])*cos(phi[*,*,0]*!pi/180))*180/(!pi)
  obsdata=[[[obsdata]],[[phi]]]
  bnames1=[bnames1,'relative azimuth (deg)']
  ;修改了g，并最后加上phi
  
  dname=bnames1[5]
  length=strmid(dname,23,14)
  dnum=double(length)
  
  envi_open_file,filenam,r_fid =fid
  ENVI_FILE_QUERY,fid,dims= dims,bnames= bnames2,nb = nb2,ns = ns, nl = nl,wl=wavelength2
  data=fltarr(ns,nl,nb2)
  for band=0,nb2-1 do begin
    data[*,*,band]= ENVI_GET_DATA(fid=fid, dims=dims, pos=band)
  endfor
  
  for band=0,nb2-1,1 do begin
    data[*,*,band]=data[*,*,band]*!pi/solar[band]*dnum^2
  endfor
  ENVI_WRITE_ENVI_FILE,data,out_name=fileout1,NB=nb2, NL=nl, NS=ns,bnames= bnames2,wl=wavelength2
  ENVI_WRITE_ENVI_FILE,obsdata,out_name=fileout2,NB=nb1+1, NL=nl, NS=ns,bnames= bnames1,wl=wavelength1
  
  ;g e i phi spectra
  rst1=fltarr(nb2+4)

  
  jnum=floor(nl/76)
  for i=0,3,1 do begin
    for j=0,jnum-1,1 do begin
      rst1[0]=mean(obsdata[i*76:i*76+75,j*76:j*76+75,4]);g
      rst1[1]=mean(obsdata[i*76:i*76+75,j*76:j*76+75,3]);e
      rst1[2]=mean(obsdata[i*76:i*76+75,j*76:j*76+75,1]);i
      rst1[3]=mean(obsdata[i*76:i*76+75,j*76:j*76+75,10]);phi
      for bandi=0,nb2-1 do begin
        rst1[4+bandi]=mean(data[i*76:i*76+75,j*76:j*76+75,bandi])
      endfor
      ;rst1[4:nb2+3]=mean(data[i*76:i*76+75,j*76:j*76+75,0:nb2-1])
      
      ;大致的校正函数  月海高地阈值 ;b3 560nm
      appr=rst1[7]*(rst1[0]*0.0192+0.3904)
      ;radiance界限约25，换成iof为0.043
      if appr gt 0.043 then begin
        rsth=[[rsth],[rst1]]
      endif else if appr gt 0 then begin
        rstm=[[rstm],[rst1]]
      endif
    endfor
  endfor

  
  
  
  openw,lun4,fileouth,/get_lun
  printf,lun4,rsth,format='(89f)'
  free_lun,lun4
  print,fileouth
  openw,lun4,fileoutm,/get_lun
  printf,lun4,rstm,format='(89f)'
  free_lun,lun4
  print,fileoutm
  
  
endfor

end