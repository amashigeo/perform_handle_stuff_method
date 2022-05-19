pro gf4_removebg5
  ;5 band
  data=fltarr(5,10240,10240)
  data3=fltarr(10240,10240,5)
  data2=fltarr(20,20)
  count=fltarr(10,2)
  filename=dialog_pickfile(filter='*',/read,/multiple)
  number=size(filename)
  num=number[3]
  for picn=0,num-1 do begin
    filenam=filename[picn]
    filenout=strjoin([filenam,'_remove'])
    envi_open_file,filenam,r_fid =fid
    ENVI_FILE_QUERY,fid,dims= dims,bnames= bnames,nb = nb,ns = ns, nl = nl
    for ba=0,4 do begin
      data[ba,*,*]= ENVI_GET_DATA(fid=fid, dims=dims, pos=ba)
    
    
    data2=data[ba,0:19,0:19]
;    count[0,0]=data2[0,0,0]
;    count[1,0]=data2[0,1,0]
;    count[2,0]=data2[0,2,0]
;    for i=0,19 do begin
;      for j=0,19 do begin
;        if data2[0,i,j] eq count[0,0] then begin
;          count[0,1]=count[0,1]+1
;        endif else if data2[0,i,j] eq count[1,0] then begin
;          count[1,1]=count[1,1]+1
;        endif
;      endfor
;    endfor
;    pos1=0
;    if count[0,1] gt 60 then begin
;      print,count[0,0]
;    endif else if count[1,1] gt 60 then begin
;      print,count[1,0]
;      pos1=1
;    endif else begin
;      print,'error'
;    endelse
;    data[ba,*,*]=data[ba,*,*]-count[pos1,0]
    data[ba,*,*]=data[ba,*,*]-min(data2)
    print,min(data2)
    data3[*,*,ba]=data[ba,*,*]
    endfor
    
    ENVI_WRITE_ENVI_FILE,data3,out_name=filenout,NB=nb, NL=nl, NS=ns
    print,filenout
    
  endfor

end