pro rad2iof4_5band
;未乘d2
filenam=dialog_pickfile(filter='*RDN',/read,/multiple)
filepos=strpos(filenam,'-RDN')
filehead=strmid(filenam,0,filepos)
fileout=strjoin([filehead,'-iof'])
envi_open_file,filenam,r_fid =fid
ENVI_FILE_QUERY,fid,dims= dims,bnames= bnames,nb = nb,ns = ns, nl = nl
data=dblarr(ns,nl,nb)
for i=0,nb-1 do begin
  data[*,*,i]= ENVI_GET_DATA(fid=fid, dims=dims, pos=i)
endfor
irra=[1606.496902, 1968.21716,  1832.738105, 1546.548651, 1097.858725]
for bandi=0,4 do begin
  data[*,*,bandi]=data[*,*,bandi]*!pi/irra[bandi]
endfor
ENVI_WRITE_ENVI_FILE,data,out_name=fileout,NB=nb, NL=nl, NS=ns, wl=[611.9316115, 491.1674811, 560.5780218, 653.5251451, 809.425661]
delvar,data
end
