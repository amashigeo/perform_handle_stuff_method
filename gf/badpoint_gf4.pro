pro badpoint_gf4

  filename=dialog_pickfile(filter='*.*',/read,/multiple)
  number=size(filename)
  num=number[3]
  gro=intarr(6)

  for picn=0,num-1 do begin
    filenam=filename[picn]
    filen=strjoin([filenam,'bp.img'])

    envi_open_file,filenam,r_fid =fid
    ENVI_FILE_QUERY,fid,dims= dims,bnames= bnames,nb = nb,ns = ns, nl = nl
    f=uintarr(nb,ns,nl)
    f[0,*,*]= ENVI_GET_DATA(fid=fid, dims=dims, pos=0)
    
    disk=1000
    for i=0,nl-4,1 do begin
      for j=0,ns-4,1 do begin
        if (i ne 0)&&(j ne 0)&&(i ne nl-1)&&(j ne ns-1)then begin
          ;if (f[0,j,i-1] gt disk)&&(f[0,j-1,i-1] gt disk)&&(f[0,j-1,i] gt disk) then begin
          gro=[f[0,j-1,i-1],f[0,j,i-1],f[0,j+1,i-1],f[0,j-1,i+1],f[0,j,i+1],f[0,j+1,i+1],f[0,j+1,i],f[0,j-1,i]]
          gro2=[f[0,j-1,i-1],f[0,j,i-1],f[0,j-1,i]]
          ave=mean(gro)
          ave2=mean(gro2)
          if (abs(f[0,j,i]) lt ave*0.7) ||(abs(f[0,j,i]) gt ave*1.5) then begin
            if (f[0,j+1,i+1] gt disk) ||(f[0,j+2,i+2] gt disk) ||(f[0,j+3,i+3] gt disk) then begin
            f[0,j,i]=ave2
            endif
          endif
          ;endif
        endif


      endfor
    endfor

    ;ENVI_ENTER_DATA, f, r_fid = rFid

    ENVI_WRITE_ENVI_FILE,f,out_name=filen,NB=nb, NL=nl, NS=ns

  endfor
end
