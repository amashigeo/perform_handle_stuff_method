pro gf4_sum
cd,'M:\GF\1'
filename1=dialog_pickfile(filter='*RDN',/read,/multiple)
number=size(filename1)
num=number[3]
for picn=0,num-1 do begin
  filenam=filename1[picn]
  envi_open_file,filenam,r_fid =fid
  ENVI_FILE_QUERY,fid,dims= dims,bnames= bnames,nb = nb,ns = ns, nl = nl
  f=dblarr(ns,nl,nb)
  sum=dblarr(nb)
  for bandn=0,nb-1 do begin
    f[*,*,bandn]= ENVI_GET_DATA(fid=fid, dims=dims, pos=bandn)
    sum[bandn]=total(f[*,*,bandn])
  endfor
  print,sum
endfor

end