pro gf4_removebg
;1 band
  data=dblarr(1,10240,10240)
  data2=dblarr(20,20)
  count=dblarr(10,2)
  filename=dialog_pickfile(filter='*',/read,/multiple)
  number=size(filename)
  num=number[3]
  for picn=0,num-1 do begin
    filenam=filename[picn]
    filenout=strjoin([filenam,'_remove'])
    envi_open_file,filenam,r_fid =fid
    ENVI_FILE_QUERY,fid,dims= dims,bnames= bnames,nb = nb,ns = ns, nl = nl
    data[0,*,*]= ENVI_GET_DATA(fid=fid, dims=dims, pos=0)
    data2=data[0,0:19,0:19]
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
;    print,'error'
;    endelse

    
;    data=data-count[pos1,0]
    data=data-min(data2)
    print,min(data2)
    ENVI_WRITE_ENVI_FILE,data,out_name=filenout,NB=nb, NL=nl, NS=ns
    print,filenout
  endfor

end