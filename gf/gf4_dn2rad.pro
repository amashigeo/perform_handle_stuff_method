pro gf4_dn2rad
;文件要求见下方注释
  cd,'g:\GFdata'
  filename1=dialog_pickfile(filter='*masked.img',/read,/multiple)

  number=size(filename1)
  num=number[3]
  ;输入参数矩阵
  ;两段阈值，a,b,slope,intercept
  ;b1-b5
  calipara=[[2000,-0.0011,7.5158,2.2774,6062],$
    [800,-0.0055,18,4.05,7500],$
    ;[1500,-0.00514,19.05,3.7195,11543],$
    [1500,-0.00165,8.9,2.48,5800],$
    [2000,-0.002,10.13,3.0909,6196],$
    [2500,-0.001,6.8,2.203,5404]]
  
  for picn=0,num-1 do begin
    filenam=filename1[picn]
    ;需要文件名中带有‘-DN’标识符，或者根据文件名修改下方‘-DN’
    ;可选中多个文件，文件应有1，4或5个band
    ;若文件仅有1个band，文件名需带有‘-B1’或'-B5'等标识
    filepos=strpos(filenam,'-masked')
    filehead=strmid(filenam,0,filepos)
    ;outfile=strjoin([filehead,'geo.img'])
    fileout=strjoin([filehead,'-RDN'])
    envi_open_file,filenam,r_fid =fid
    ENVI_FILE_QUERY,fid,dims= dims,bnames= bnames,nb = nb,ns = ns, nl = nl
    data=fltarr(ns,nl,nb)

    for i=0,nb-1 do begin
      data[*,*,i]= ENVI_GET_DATA(fid=fid, dims=dims, pos=i)
    endfor
    if nb eq 5 then begin
      for bandi=0,4 do begin
      for j=0,ns-1 do begin
        for i=0,nl-1 do begin
          if data[j,i,bandi] lt calipara[0,bandi] then begin
            data[j,i,bandi]=data[j,i,bandi]^2*calipara[1,bandi]+data[j,i,bandi]*calipara[2,bandi]
          endif else begin
            data[j,i,bandi]=data[j,i,bandi]*calipara[3,bandi]+calipara[4,bandi]
          endelse
        endfor
      endfor
      endfor
    endif
    if nb eq 4 then begin
      for bandi=0,1 do begin
        for j=0,ns-1 do begin
          for i=0,nl-1 do begin
            if data[j,i,bandi] lt calipara[0,bandi] then begin
              data[j,i,bandi]=data[j,i,bandi]^2*calipara[1,bandi]+data[j,i,bandi]*calipara[2,bandi]
            endif else begin
              data[j,i,bandi]=data[j,i,bandi]*calipara[3,bandi]+calipara[4,bandi]
            endelse
          endfor
        endfor
      endfor
      for bandi=2,3 do begin
        for j=0,ns-1 do begin
          for i=0,nl-1 do begin
            if data[j,i,bandi] lt calipara[0,bandi+1] then begin
              data[j,i,bandi]=data[j,i,bandi]^2*calipara[1,bandi+1]+data[j,i,bandi]*calipara[2,bandi+1]
            endif else begin
              data[j,i,bandi]=data[j,i,bandi]*calipara[3,bandi+1]+calipara[4,bandi+1]
            endelse
          endfor
        endfor
      endfor
    endif
    if nb eq 1 then begin
      if strpos(filenam,'-B1') ne -1 then begin
        bandi=0
        for j=0,ns-1 do begin
          for i=0,nl-1 do begin
            if data[j,i,0] lt calipara[0,bandi] then begin
              data[j,i,0]=data[j,i,0]^2*calipara[1,bandi]+data[j,i,0]*calipara[2,bandi]
            endif else begin
              data[j,i,0]=data[j,i,0]*calipara[3,bandi]+calipara[4,bandi]
            endelse
          endfor
        endfor
      endif
      if strpos(filenam,'-B2') ne -1 then begin
        bandi=1
        for j=0,ns-1 do begin
          for i=0,nl-1 do begin
            if data[j,i,0] lt calipara[0,bandi] then begin
              data[j,i,0]=data[j,i,0]^2*calipara[1,bandi]+data[j,i,0]*calipara[2,bandi]
            endif else begin
              data[j,i,0]=data[j,i,0]*calipara[3,bandi]+calipara[4,bandi]
            endelse
          endfor
        endfor
      endif
      if strpos(filenam,'-B3') ne -1 then begin
        bandi=2
        for j=0,ns-1 do begin
          for i=0,nl-1 do begin
            if data[j,i,0] lt calipara[0,bandi] then begin
              data[j,i,0]=data[j,i,0]^2*calipara[1,bandi]+data[j,i,0]*calipara[2,bandi]
            endif else begin
              data[j,i,0]=data[j,i,0]*calipara[3,bandi]+calipara[4,bandi]
            endelse
          endfor
        endfor
      endif
      if strpos(filenam,'-B4') ne -1 then begin
        bandi=3
        for j=0,ns-1 do begin
          for i=0,nl-1 do begin
            if data[j,i,0] lt calipara[0,bandi] then begin
              data[j,i,0]=data[j,i,0]^2*calipara[1,bandi]+data[j,i,0]*calipara[2,bandi]
            endif else begin
              data[j,i,0]=data[j,i,0]*calipara[3,bandi]+calipara[4,bandi]
            endelse
          endfor
        endfor
      endif
      if strpos(filenam,'-B5') ne -1 then begin
        bandi=4
        for j=0,ns-1 do begin
          for i=0,nl-1 do begin
            if data[j,i,0] lt calipara[0,bandi] then begin
              data[j,i,0]=data[j,i,0]^2*calipara[1,bandi]+data[j,i,0]*calipara[2,bandi]
            endif else begin
              data[j,i,0]=data[j,i,0]*calipara[3,bandi]+calipara[4,bandi]
            endelse
          endfor
        endfor
      endif
    endif
    data=data/1000
    ENVI_WRITE_ENVI_FILE,data,out_name=fileout,NB=nb, NL=nl, NS=ns
    delvar,data
  endfor

end