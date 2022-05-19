pro gf4_datacolle
cd,'g:\GFdata'
;输出角度顺序为e i phi g
;分integrated  得到rad
;resolved-月海、高地-未实现  得到rad
integrated=1;是否运行integrated
resolved=1;是否运行resolved

filename=dialog_pickfile(filter='*RDN*',/read,/multiple);data
filenameg=dialog_pickfile(filter='*geoinfo.img',/read,/multiple);1 个geo
number=size(filename)
num=number[3];

for picn=0,num-1 do begin
  
filename1=filename[picn]
filename2=filenameg[picn]
filepos=strpos(filename1,'-RDN')
filehead=strmid(filename1,0,filepos)
fileout1=strjoin([filehead,'-inte.txt'])


envi_open_file,filename1,r_fid =fid
ENVI_FILE_QUERY,fid,dims= dims,bnames= bnames,nb = nb1,ns = ns, nl = nl
data=dblarr(nb1,ns,nl)
for band=0,nb1-1 do begin
  data[band,*,*]= ENVI_GET_DATA(fid=fid, dims=dims, pos=band)
endfor

envi_open_file,filename2,r_fid =fid
ENVI_FILE_QUERY,fid,dims= dims,bnames= bnames,nb = nb,ns = ns, nl = nl
geo=fltarr(8,ns,nl);lon lat vazi vzen sazi szen g area
for band=0,nb-1 do begin
  geo[band,*,*]= ENVI_GET_DATA(fid=fid, dims=dims, pos=band)
endfor


if nb1 eq 1 then begin
  
  fileout2=strjoin([filehead,'-reso.txt'])
  
  ;integrated
  if integrated then begin
    rad_inte=dblarr(6)
    inte_temp=dblarr(6)
    count1=long(0);月面计数
    count2=long(0);geo计数
    for i=0, ns-1 do begin
      for j=0, nl-1 do begin
        if data[0,i,j] ne 0 then begin
          inte_temp[3]=inte_temp[3]+data[0,i,j];data
          inte_temp[4]=inte_temp[4]+geo[7,i,j];area
          count1=count1+1
        endif
        if geo[3,i,j] ne 999 then begin
          inte_temp[0]=inte_temp[0]+geo[3,i,j];vzen
          inte_temp[1]=inte_temp[1]+geo[5,i,j];szen
          inte_temp[2]=inte_temp[2]+geo[6,i,j];g
          count2=count2+1
        endif
      endfor
    endfor
    rad_inte[3]=inte_temp[3]/count1
    rad_inte[0]=inte_temp[0]/count2;vzen
    rad_inte[1]=inte_temp[1]/count2;szen
    rad_inte[2]=inte_temp[2]/count2;g
    rad_inte[4]=inte_temp[4]/count1;area
    rad_inte[5]=count1

    openw,lun4,fileout1,/get_lun
    printf,lun4,rad_inte,format='(5d)'
    print,fileout1
    free_lun,lun4
  endif
  
  ;resolved
  if resolved then begin
    rad_res=dblarr(5,100000)
    count=double(0)

    for i=0,511 do begin ;无需area
      for j=0,511 do begin
        countin=long(0)
        res_temp=dblarr(5)
        for m=0,19 do begin
          for n=0,19 do begin
            if ((data[0,i*20+m,j*20+n]) ne 0) && ((geo[3,i*20+m,j*20+n]) ne 999)then begin
              countin=countin+1
              phi=abs(geo[2,i*20+m,j*20+n]-geo[4,i*20+m,j*20+n])
              res_temp[4]=res_temp[4]+data[0,i*20+m,j*20+n];data
              ;res_temp[4]=res_temp[4]+geo[7,i*20+m,j*20+n];area
              res_temp[2]=res_temp[2]+phi;phi
              res_temp[0]=res_temp[0]+geo[3,i*20+m,j*20+n];vzen
              res_temp[1]=res_temp[1]+geo[5,i*20+m,j*20+n];szen
              res_temp[3]=res_temp[3]+geo[6,i*20+m,j*20+n];g
            endif
          endfor
        endfor
        if countin gt 10 then begin
          res_temp=res_temp/countin
          rad_res[*,count]=res_temp
          count=count+1
        endif
        ;delvar,res_temp
      endfor
    endfor

    openw,lun4,fileout2,/get_lun
    printf,lun4,rad_res,format='(5d)'
    print,fileout2
    free_lun,lun4

    delvar,rad_res
  endif
  
endif




if nb1 ne 1 then begin
  
  fileout2=strjoin([filehead,'-reso.txt'])
      
    ;integrated
    rad_inte=dblarr(10)
    inte_temp=dblarr(10)
    count1=long(0);月面计数
    count2=long(0);geo计数
    for i=0, ns-1 do begin
      for j=0, nl-1 do begin
        if data[0,i,j] ne 0 then begin
          for bandi=0, nb1-1 do begin            
            inte_temp[5+bandi]=inte_temp[5+bandi]+data[bandi,i,j];data
          endfor
          ;inte_temp[3]=inte_temp[3]+geo[7,i,j];area
          count1=count1+1
        endif
        if geo[3,i,j] ne 999 then begin
          inte_temp[0]=inte_temp[0]+geo[3,i,j];vzen
          inte_temp[1]=inte_temp[1]+geo[5,i,j];szen
          inte_temp[2]=inte_temp[2]+geo[6,i,j];g
          count2=count2+1
        endif
      endfor
    endfor
    rad_inte[0]=inte_temp[0]/count2;vzen
    rad_inte[1]=inte_temp[1]/count2;szen
    rad_inte[2]=inte_temp[2]/count2;g
    ;rad_inte[3]=inte_temp[3]/count1;area
    rad_inte[4]=count1
    for bandi=0, nb1-1 do begin
      rad_inte[5+bandi]=inte_temp[5+bandi]/count1;data
    endfor
    
    openw,lun4,fileout1,/get_lun
    printf,lun4,rad_inte,format='(10d)'
    print,fileout1
    free_lun,lun4
    
    
    ;resolved
    rad_res=dblarr(9,100000)
    count=double(0)

    for i=0,511 do begin
      for j=0,511 do begin
        countin=long(0)
        res_temp=dblarr(9)
        for m=0,19 do begin
          for n=0,19 do begin
            if ((data[0,i*20+m,j*20+n]) ne 0) && ((data[1,i*20+m,j*20+n]) ne 0)$
              &&((data[2,i*20+m,j*20+n]) ne 0) &&((data[3,i*20+m,j*20+n]) ne 0) $
              &&((geo[3,i*20+m,j*20+n]) ne 999)then begin              
              countin=countin+1
              phi=abs(geo[2,i*20+m,j*20+n]-geo[4,i*20+m,j*20+n])
              res_temp[2]=res_temp[2]+phi;phi
              res_temp[0]=res_temp[0]+geo[3,i*20+m,j*20+n];vzen
              res_temp[1]=res_temp[1]+geo[5,i*20+m,j*20+n];szen
              res_temp[3]=res_temp[3]+geo[6,i*20+m,j*20+n];g
              for bandi=0, nb1-1 do begin
                res_temp[4+bandi]=res_temp[4+bandi]+data[bandi,i*20+m,j*20+n];data
              endfor
            endif
          endfor
        endfor
        if countin gt 10 then begin
          res_temp=res_temp/countin
          rad_res[*,count]=res_temp
          count=count+1
        endif
        delvar,res_temp
      endfor
    endfor
    openw,lun4,fileout2,/get_lun
    printf,lun4,rad_res,format='(9d)'
    print,fileout2
    free_lun,lun4

    delvar,rad_res
  
endif


delvar,data,geo
endfor
end