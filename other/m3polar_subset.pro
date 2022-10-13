pro m3polar_subset
;modified20221013
filename=dialog_pickfile(filter='*RFL.IMG',/read,/multiple);
number1=size(filename)
num1=number1[3]

for picn=0,num1-1 do begin
  filename1=filename[picn]

;  filepos=strpos(filename1,'_V01_RFL')
;  filehead=strmid(filename1,0,filepos)
;  fileuse=strjoin([filehead,'_V03_LOC.IMG'])
;  fileout=strjoin([filehead,'_subset.img'])
;  fileout2=strjoin([filehead,'_subsetgeo.img'])
  filelocdir="C:\Users\Administrator\Desktop\m3\loc\"
  fileoutdir="C:\Users\Administrator\Desktop\m3\out\"

  filepos1=strpos(filename1,'M3G')
  filepos2=strpos(filename1,'_V01_RFL')
  fileleng=filepos2-filepos1
  filetag=strmid(filename1,filepos1,fileleng)
  fileuse=strjoin([filelocdir,filetag,'_V03_LOC.IMG'])
  fileout=strjoin([fileoutdir,filetag,'_subset.img'])
  fileout2=strjoin([fileoutdir,filetag,'_subsetgeo.img'])
  
  
  envi_open_file,filename1,r_fid =fid
  ENVI_FILE_QUERY,fid,dims= dims,bnames= bnames,nb = nb,ns = ns, nl = nl
  data=fltarr(ns,nl,12)
  for band=nb-12,nb-1 do begin;只取最后12个
    data[*,*,band-nb+12]= ENVI_GET_DATA(fid=fid, dims=dims, pos=band)
  endfor
  
  envi_open_file,fileuse,r_fid =fid
  ENVI_FILE_QUERY,fid,dims= dims,bnames= bnames,nb = nb1,ns = ns, nl = nl
  geodata=fltarr(ns,nl,nb1)
  for band=0,nb1-1 do begin
    geodata[*,*,band]= ENVI_GET_DATA(fid=fid, dims=dims, pos=band)
  endfor
  
  if mean(geodata[0:10,0:10,1]) gt 0 then begin
    ;北半球
    for i=nl-1,0,-1 do begin
      if geodata[0,i,1] gt 75 then break
    endfor
    if i gt 0 then begin
      border=i     
      dataout=data[*,0:border,*]
      dataout2=geodata[*,0:border,*]
      ENVI_WRITE_ENVI_FILE,dataout,out_name=fileout,NB=12, NL=border+1, NS=ns
      ENVI_WRITE_ENVI_FILE,dataout2,out_name=fileout2,NB=3, NL=border+1, NS=ns
      print,fileout,"完成"
    endif
   
  endif else begin
    ;南半球
    for i=0,nl-1,1 do begin
      if geodata[0,i,1] lt -75 then break
    endfor
    if i lt nl-1 then begin
      border=i
      dataout=data[*,border:nl-1,*]
      dataout2=geodata[*,border:nl-1,*]
      ENVI_WRITE_ENVI_FILE,dataout,out_name=fileout,NB=12, NL=nl-border+1, NS=ns
      ENVI_WRITE_ENVI_FILE,dataout2,out_name=fileout2,NB=3, NL=nl-border+1, NS=ns
      print,fileout,"完成"
    endif
  endelse
  
endfor

end
