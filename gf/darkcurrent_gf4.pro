pro darkcurrent_gf4
;根据黑空去暗电流，并转为radiance——未完成
cd,'G:\GF-4 Radiance\月蚀'
filename1=dialog_pickfile(filter='*.*',/read,/multiple)
filename2=dialog_pickfile(filter='*.*',/read,/multiple)
filenam1=filename2[0]
filenam2=filename2[1]
filepos=strpos(filename1,'-new')
filehead=strmid(filename1,0,filepos)
;outfile=strjoin([filehead,'geo.img'])
filen=strjoin([filehead,'bp_rad.img'])

envi_open_file,filename1,r_fid =fid
ENVI_FILE_QUERY,fid,dims= dims,bnames= bnames,nb = nb,ns = ns, nl = nl
f=lonarr(nb,ns,nl)
f[0,*,*]= ENVI_GET_DATA(fid=fid, dims=dims, pos=0)
envi_open_file,filename2[0],r_fid =fid
ENVI_FILE_QUERY,fid,dims= dims,bnames= bnames,nb = nb,ns = ns, nl = nl
f1=lonarr(nb,ns,nl)
f1[0,*,*]= ENVI_GET_DATA(fid=fid, dims=dims, pos=0)
envi_open_file,filename2[1],r_fid =fid
ENVI_FILE_QUERY,fid,dims= dims,bnames= bnames,nb = nb,ns = ns, nl = nl
f2=lonarr(nb,ns,nl)
f2[0,*,*]= ENVI_GET_DATA(fid=fid, dims=dims, pos=0)
f4=fltarr(1,ns,nl)
for i=0,nl-1,1 do begin
  for j=0,ns-1,1 do begin
    ave=(f1[0,j,i]+f2[0,j,i])/2
    if f[0,j,i] lt ave then begin
      f[0,j,i]=0
    endif else begin
      f[0,j,i]=f[0,j,i]-ave
    endelse
    f4[0,j,i]=f[0,j,i]*0.033613531+6.263812189;b1
;    f4[0,j,i]=f[0,j,i]*0.064+11.42;b2
;    f4[0,j,i]=f[0,j,i]*0.044+7.69;b3
;    f4[0,j,i]=f[0,j,i]*0.056+10.56;b4
;    f4[0,j,i]=f[0,j,i]*0.042+6.51;b5

  endfor
endfor    
ENVI_WRITE_ENVI_FILE,f4,out_name=filen,NB=nb, NL=nl, NS=ns
end