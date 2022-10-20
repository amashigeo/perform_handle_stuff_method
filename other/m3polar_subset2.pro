pro m3polar_subset2
;modified20221019 v2.0
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
  filelocdir="C:\Users\lycen\Desktop\m3\loc\"
  fileoutnorthdir="C:\Users\lycen\Desktop\m3\northout\"
  fileoutsouthdir="C:\Users\lycen\Desktop\m3\southout\"

  filepos1=strpos(filename1,'M3G')
  filepos2=strpos(filename1,'_V01_RFL')
  fileleng=filepos2-filepos1
  filetag=strmid(filename1,filepos1,fileleng)
  fileuse=strjoin([filelocdir,filetag,'_V03_LOC.IMG'])
  fileoutn=strjoin([fileoutnorthdir,filetag,'_subset.img'])
  fileoutn2=strjoin([fileoutnorthdir,filetag,'_subsetgeo.img'])
  fileouts=strjoin([fileoutsouthdir,filetag,'_subset.img'])
  fileouts2=strjoin([fileoutsouthdir,filetag,'_subsetgeo.img'])  
  
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
  
  ;新方法
  nline=intarr(nl)
  nnum=0
  sline=intarr(nl)
  snum=0  
  for i=0,nl-1,1 do begin
    if geodata[0,i,1] gt 75 then begin
      nline[nnum]=i
      nnum=nnum+1
    endif
    if geodata[0,i,1] lt -75 then begin
      sline[snum]=i
      snum=snum+1
    endif
  endfor
  nstart=nline[0]
  sstart=sline[0]
  
  if (nnum eq 0) && (snum eq 0) then begin
    print,filename1,"不存在极区"
  endif
  
  if nnum gt 0 then begin
    dataoutn=data[*,nstart:nstart+nnum-1,*]
    dataoutn2=geodata[*,nstart:nstart+nnum-1,*]
    ENVI_WRITE_ENVI_FILE,dataoutn,out_name=fileoutn,NB=12, NL=nnum, NS=ns
    ENVI_WRITE_ENVI_FILE,dataoutn2,out_name=fileoutn2,NB=3, NL=nnum, NS=ns
    print,fileoutn,"完成"
  endif
  
  if snum gt 0 then begin
    dataouts=data[*,sstart:sstart+snum-1,*]
    dataouts2=geodata[*,sstart:sstart+snum-1,*]
    ENVI_WRITE_ENVI_FILE,dataouts,out_name=fileouts,NB=12, NL=snum, NS=ns
    ENVI_WRITE_ENVI_FILE,dataouts2,out_name=fileouts2,NB=3, NL=snum, NS=ns
    print,fileouts,"完成"
  endif
  
  delvar,data,geodata,dataoutn,dataoutn2,dataouts,dataouts2
 
endfor

end