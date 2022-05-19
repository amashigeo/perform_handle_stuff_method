pro gf4_rad2dn
  cd,'G:\GF-4 Radiance\archive'
  filename1=dialog_pickfile(filter='*.*',/read,/multiple)
  
  number=size(filename1)
  num=number[3]
  
  for picn=0,num-1 do begin
    filenam=filename1[picn]
    filepos=strpos(filenam,'-RDN')
    filehead=strmid(filenam,0,filepos)
    ;outfile=strjoin([filehead,'geo.img'])
    fileout=strjoin([filehead,'-DN'])
    envi_open_file,filenam,r_fid =fid
    ENVI_FILE_QUERY,fid,dims= dims,bnames= bnames,nb = nb,ns = ns, nl = nl
    data=fltarr(ns,nl,nb)

    for i=0,nb-1 do begin
      data[*,*,i]= ENVI_GET_DATA(fid=fid, dims=dims, pos=i)     
    endfor
    if nb eq 5 then begin
      data[*,*,0]=(data[*,*,0]-5.4476)/0.0023
      data[*,*,1]=(data[*,*,1]-9.5943)/0.0039
      data[*,*,2]=(data[*,*,2]-5.4985)/0.0027
      data[*,*,3]=(data[*,*,3]-5.8824)/0.0031
      data[*,*,4]=(data[*,*,4]-4.8976)/0.0022
    endif
    if nb eq 4 then begin
      data[*,*,0]=(data[*,*,0]-5.4476)/0.0023
      data[*,*,1]=(data[*,*,1]-9.5943)/0.0039
      
      data[*,*,2]=(data[*,*,2]-5.8824)/0.0031
      data[*,*,3]=(data[*,*,3]-4.8976)/0.0022
    endif
    if nb eq 1 then begin
      if strpos(filenam,'-B1') ne -1 then begin
        data[*,*,0]=(data[*,*,0]-5.4476)/0.0023
      endif
      if strpos(filenam,'-B2') ne -1 then begin
        ;data[*,*,0]=(data[*,*,0]-9.5943)/0.0039
        data[*,*,0]=(data[*,*,0]-6.68)/0.0041
      endif
      if strpos(filenam,'-B3') ne -1 then begin
        data[*,*,0]=(data[*,*,0]-5.4985)/0.0027
      endif
      if strpos(filenam,'-B4') ne -1 then begin
        data[*,*,0]=(data[*,*,0]-5.8824)/0.0031
      endif
      if strpos(filenam,'-B5') ne -1 then begin
        data[*,*,0]=(data[*,*,0]-4.8976)/0.0022
      endif
    endif
    ENVI_WRITE_ENVI_FILE,data,out_name=fileout,NB=nb, NL=nl, NS=ns
    delvar,data
  endfor

end