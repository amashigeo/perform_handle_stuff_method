pro gf4_extractmoon
cd,'g:\GFdata'
  filename=dialog_pickfile(filter='*DN',/read,/multiple);data-1 or 5band
  filenameg=dialog_pickfile(filter='*geoinfo.img',/read,/multiple);1个geo
  ;参数设定
  condi = 1;1=full 2=half
  ;————————————
  ; previous para: 12500 6000 10000 10000 12500
  ; 2500 1000 2000 2000 2200
  
  number1=size(filename)
  num1=number1[3];几个几何信息
  
  for picn=0,num1-1 do begin
  filename1=filename[picn]
  filename2=filenameg[picn]
  filepos=strpos(filename1,'-DN')
  filehead=strmid(filename1,0,filepos)
  fileout1=strjoin([filehead,'-mask.img'])
  fileout2=strjoin([filehead,'-masked.img'])
  
  envi_open_file,filename1,r_fid =fid
  ENVI_FILE_QUERY,fid,dims= dims,bnames= bnames,nb = nb1,ns = ns, nl = nl
  data=fltarr(ns,nl,nb1)
  for band=0,nb1-1 do begin
    data[*,*,band]= ENVI_GET_DATA(fid=fid, dims=dims, pos=band)
  endfor
  
  if nb1 eq 1 then begin
    if strpos(filename1,'-B1') ne -1 then begin
      if condi eq 1 then begin
        thres1=800
      endif
      if condi eq 2 then begin
        thres1=2500
      endif      
      thres2=130
    endif
    if strpos(filename1,'-B2') ne -1 then begin
      if condi eq 1 then begin
        thres1=513
      endif
      if condi eq 2 then begin
        thres1=1000
      endif
      thres2=130
    endif
    if strpos(filename1,'-B3') ne -1 then begin
      if condi eq 1 then begin
        thres1=513
      endif
      if condi eq 2 then begin
        thres1=2000
      endif
      thres2=130
    endif
    if strpos(filename1,'-B4') ne -1 then begin
      if condi eq 1 then begin
        thres1=513
      endif
      if condi eq 2 then begin
        thres1=2000
      endif
      thres2=130
    endif
    if strpos(filename1,'-B5') ne -1 then begin
      if condi eq 1 then begin
        thres1=513
      endif
      if condi eq 2 then begin
        thres1=350
      endif
      thres2=130
    endif
    
    envi_open_file,filename2,r_fid =fid
    ENVI_FILE_QUERY,fid,dims= dims,bnames= bnames,nb = nb,ns = ns, nl = nl
    geo=fltarr(1,ns,nl);lon lat vazi vzen sazi szen g area

    geo[0,*,*]= ENVI_GET_DATA(fid=fid, dims=dims, pos=5)
    mask1=intarr(1,ns,nl)
    
    for i=0,ns-1 do begin
      for j=0, nl-1 do begin
        if geo[0,i,j] lt 93 then begin
          mask1[0,i,j]=2
        endif
      endfor
    endfor

    mask3=intarr(1,ns,nl)
    
    for i=0,ns-1 do begin
      for j=0, nl-1 do begin
        if mask1[0,i,j] eq 0 && data[i,j,0] ge thres1 then begin
          mask3[0,i,j]=1
        endif
        if mask1[0,i,j] eq 2 && data[i,j,0] ge thres2 then begin
          mask3[0,i,j]=1
        endif
      endfor
    endfor
    data=data*mask3
    ENVI_WRITE_ENVI_FILE,mask3,out_name=fileout1,NB=1, NL=nl, NS=ns
    ENVI_WRITE_ENVI_FILE,data,out_name=fileout2,NB=1, NL=nl, NS=ns
    delvar,mask1,mask3,data,geo
  endif
  
  if nb1 ne 1 then begin
    
    if condi eq 1 then begin
      thres1=12500
    endif
    if condi eq 2 then begin
      thres1=2500
    endif
    thres2=65
    envi_open_file,filename2,r_fid =fid
    ENVI_FILE_QUERY,fid,dims= dims,bnames= bnames,nb = nb,ns = ns, nl = nl
    geo=fltarr(1,ns,nl);lon lat vazi vzen sazi szen g area

    geo[0,*,*]= ENVI_GET_DATA(fid=fid, dims=dims, pos=5)
    mask1=intarr(1,ns,nl)

    for i=0,ns-1 do begin
      for j=0, nl-1 do begin
        if geo[0,i,j] lt 93 then begin
          mask1[0,i,j]=2
        endif
      endfor
    endfor

    mask3=intarr(1,ns,nl)

    for i=0,ns-1 do begin
      for j=0, nl-1 do begin
        if mask1[0,i,j] eq 0 && data[i,j,0] ge thres1 then begin
          mask3[0,i,j]=1
        endif
        if mask1[0,i,j] eq 2 && data[i,j,0] ge thres2 then begin
          mask3[0,i,j]=1
        endif
      endfor
    endfor
    for bandi=0,nb1-1 do begin
      data[*,*,bandi]=data[*,*,bandi]*mask3
    endfor
    
    ENVI_WRITE_ENVI_FILE,mask3,out_name=fileout1,NB=1, NL=nl, NS=ns
    ENVI_WRITE_ENVI_FILE,data,out_name=fileout2,NB=nb1, NL=nl, NS=ns
    delvar,mask1,mask3,data,geo
  endif
  endfor
end