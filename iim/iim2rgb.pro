pro iim2rgb
  filename=dialog_pickfile(filter='*.img',/read,/multiple)
  number=size(filename)
  num=number[3]


  for picn=0,num-1 do begin
    filenam=filename[picn]
    filepos=strpos(filenam,'.img')
    filehead=strmid(filenam,0,filepos)
    outfile1=strjoin([filehead,'-1.jpg'])
    outfile2=strjoin([filehead,'-2.jpg'])
    outfile3=strjoin([filehead,'-3.jpg'])
    outfile4=strjoin([filehead,'-4.jpg'])
    outfile5=strjoin([filehead,'-5.jpg'])
    envi_open_file,filenam,r_fid =fid
    ENVI_FILE_QUERY,fid,dims= dims,bnames= bnames,nb = nb,ns = ns, nl = nl
    data=dblarr(ns,nl,26)
    data2=bytarr(ns,nl,26)
    data4=bytarr(ns,1000,26)
    if nb eq 26 then begin
      for i = 0,nb-1 do begin
        data[*,*,i] = ENVI_GET_DATA(fid=fid,dims=dims,pos=i)
      endfor
    endif else begin
      for i = 5,nb-2 do begin
        data[*,*,i-5] = ENVI_GET_DATA(fid=fid,dims=dims,pos=i)
      endfor
    endelse
    
    

    for i=0,25 do begin
    limup=max(data[*,*,i])
    limdo=min(data[*,*,i])
    for j=0,ns-1 do begin
      for k=0,nl-1 do begin
        data2[j,k,i]=uint((data[j,k,i]-limdo)*float(255)/(limup-limdo))
      endfor
    endfor
    endfor
    
    start=long(nl/3)
    data4[*,*,*]=data2[*,start:start+999,*]

    
    
    data3=bytarr(3,ns,1000)
    
    data3[0,*,*]=data4[*,*,25]
    data3[1,*,*]=data4[*,*,20]
    data3[2,*,*]=data4[*,*,9]
    WRITE_JPEG, outfile1, data3, /ORDER, QUALITY=75, /TRUE
    
    data3[0,*,*]=data4[*,*,24]
    data3[1,*,*]=data4[*,*,18]
    data3[2,*,*]=data4[*,*,7]
    WRITE_JPEG, outfile2, data3, /ORDER, QUALITY=75, /TRUE
    
    data3[0,*,*]=data4[*,*,22]
    data3[1,*,*]=data4[*,*,16]
    data3[2,*,*]=data4[*,*,5]
    WRITE_JPEG, outfile3, data3, /ORDER, QUALITY=75, /TRUE
    
    data3[0,*,*]=data4[*,*,20]
    data3[1,*,*]=data4[*,*,13]
    data3[2,*,*]=data4[*,*,3]
    WRITE_JPEG, outfile4, data3, /ORDER, QUALITY=75, /TRUE
    
    data3[0,*,*]=data4[*,*,19]
    data3[1,*,*]=data4[*,*,10]
    data3[2,*,*]=data4[*,*,1]
    WRITE_JPEG, outfile5, data3, /ORDER, QUALITY=75, /TRUE
  endfor


end