pro dbl2flt
  filename=dialog_pickfile(filter='*.img',/read,/multiple)
  number=size(filename)
  num=number[3]
  
  for picn=0,num-1 do begin
    filenam=filename[picn]
    filepos=strpos(filenam,'.dat')
    filehead=strmid(filenam,0,filepos-23)
    outfile=strjoin([filehead,'geo.img'])
    envi_open_file,filenam,r_fid =fid
    ENVI_FILE_QUERY,fid,dims= dims,bnames= bnames,nb = nb,ns = ns, nl = nl
    data=dblarr(nb,ns,nl)
    data3=fltarr(ns,nl,nb)
    for i=0,nb-1 do begin
      data[i,*,*]= ENVI_GET_DATA(fid=fid, dims=dims, pos=i)
      data3[*,*,i]=float(data[i,*,*])
    endfor
    ENVI_WRITE_ENVI_FILE,data3,bnames=['longitude','latitude','satellite_azimuth','satellite_zenith','solar_azimuth','solar_zenith','phase_angle','area'],out_name=outfile,NB=nb, NL=nl, NS=ns
    delvar,data,data3
    
  endfor

end