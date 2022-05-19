pro warp_and_mosaic
;xty 20220510
COMPILE_OPT IDL2
envi
e=envi()

cd,'C:\Users\acer\Desktop\IIM几何配准和镶嵌test数据'
;warp
filegcp=dialog_pickfile(filter='*.pts',/read,/multiple);批量读取GCP文件
fileimg=dialog_pickfile(filter='*.img',/read,/multiple);批量读取img文件//注意需使img和gcp的数量和顺序一致
filebase=dialog_pickfile(filter='*.*',/read,/multiple);base
fileimg2=fileimg
number=size(fileimg)
num=number[3]
allraster=[]

envi_open_file,filebase,r_fid =fidb
fileout2=strjoin([filebase,'-mosaiced']);可更改生成mosaic名称
for picn=0,num-1 do begin
  filegcp1=filegcp[picn]
  fileimg1=fileimg[picn]
  filepos=strpos(fileimg1,'.img')
  filehead=strmid(fileimg1,0,filepos)
  fileout=strjoin([filehead,'-warp.img'])
  
  OPENR, lun, filegcp1, /GET_LUN
  header = STRARR(5)
  READF, lun, header

  nlines = FILE_LINES(filegcp1)
  rows=nlines-5
  datagcp=dblarr(4,rows)

  READF, lun, datagcp
  FREE_LUN, lun
  
  
  envi_open_file,fileimg1,r_fid =fidw
  ENVI_FILE_QUERY,fidw,dims= dims
  ;vector=envi.openvector(fileimg1)
  ;mapi1=vector.coord_sys
  ENVI_DOIT, 'ENVI_REGISTER_DOIT' ,B_FID=fidb, out_name=fileout,pts=datagcp,w_dims=dims,w_fid=fidw,w_pos=lindgen(26)
  
  
;  envi_open_file,fileout,r_fid =fidw1
;  ENVI_FILE_QUERY,fidw1,dims= dims
  raster=e.openraster(fileout)
  ;mapi=raster.spatialref
  ;vector=e.openvector(fileimg2)
  ;mapi=vector.coord_sys

;  ENVI_DOIT, 'MOSAIC_DOIT' ,dims=dims, fid=fidw1, /georef, map_info=mapi, out_dt=4, out_name=fileout2,PIXEL_SIZE=[200, 200], POS=lindgen(26) , USE_SEE_THROUGH=0$
;    ,xsize=200 ,x0=1204, ysize=200, y0=0
    
  allraster=[allraster, raster]
  
endfor

mosaicRaster = ENVIMosaicRaster(allraster, $
  COLOR_MATCHING_METHOD = 'Histogram Matching', $
  COLOR_MATCHING_STATS = 'Entire Scene', $
  FEATHERING_METHOD = 'Edge', $
  FEATHERING_DISTANCE = 15)
  
 mosaicRaster.Export, fileout2,'ENVI'
end