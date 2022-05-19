pro iim_randspectra_extract
  filename=dialog_pickfile(filter='*.img',/read,/multiple)
  number=size(filename)
  num=number[3]
  for picn=0,num-1 do begin
    filenam=filename[picn]
    filepos=strpos(filenam,'.img')
    filepos2=strpos(filenam,'-cali')
    if filepos2 eq -1 then begin
      filepos2=strpos(filenam,'_remove')
    endif
    filen1=strmid(filenam,0,filepos)
    fileori=strmid(filenam,0,filepos2)

    fileout=strjoin([filen1,'-spec.txt'])
    envi_open_file,filenam,r_fid =fid
    ENVI_FILE_QUERY,fid,dims= dims,bnames= bnames,nb = nb,ns = ns, nl = nl
    iimdata = fltarr(ns,nl,nb)
    if nb eq 26 then begin
      for i = 0,nb-1 do begin
        iimdata[*,*,i] = ENVI_GET_DATA(fid=fid,dims=dims,pos=i)
      endfor
    endif else begin
      for i = 5,nb-2 do begin
        iimdata[*,*,i-5] = ENVI_GET_DATA(fid=fid,dims=dims,pos=i)
      endfor
    endelse

    spec=fltarr(26,10)
    d=randomu(seed,10,/normal)
    d=abs(fix(d*nl))
    for i=0,9 do begin
      if d[i] gt nl-128 then begin
        d[i]=nl-128        
      endif
      for n=0,25 do begin
        spec[n,i]=mean(iimdata[*,d[i]:d[i]+127,n])
      endfor
      
    endfor

    openw,lun4,fileout,/get_lun
    printf,lun4,spec,format='(26f)'
    free_lun,lun4
    delvar,iimdata
    print,fileout
  endfor
end