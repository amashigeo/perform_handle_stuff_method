pro txtdata2img_gf4
  resolution=10240
  bandnum=8
  
  filename=dialog_pickfile(filter='*.*',/read,/multiple)
  number=size(filename)
  num=number[3]
  
  data=fltarr(bandnum+2,resolution,resolution)
  data2=fltarr(resolution,resolution,bandnum)
  for picn=0,num-1 do begin
    filenam=filename[picn]
    ;namelen=strlen(filenam)
    ;filen1=strmid(filenam,0,60)
    filenuse=strjoin([filenam,'geoinfo'])
    filen=strjoin([filenuse,'.img'])

    openr,lun,filenam,/get_lun
    readf,lun,data
    free_lun,lun

    
    for i=0,bandnum-1 do begin
      for j=0,resolution-1 do begin
        for k=0,resolution-1 do begin
          data2(j,k,i)=data[i+2,j,k]
        endfor
      endfor
    endfor

    ENVI_WRITE_ENVI_FILE,data2,bnames=['longitude','latitude','satellite_azimuth','satellite_zenith','solar_azimuth','solar_zenith','phase_angle','area'],out_name=filen,NB=nb, NL=nl, NS=ns


  endfor

end
