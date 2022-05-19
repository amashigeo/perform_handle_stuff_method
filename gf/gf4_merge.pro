pro gf4_merge
cd,'D:\GF-4 Radiance'
data=fltarr(10240,10240,5)
filename=dialog_pickfile(filter='*',/read,/multiple)
number=size(filename)
num=number[3]
for picn=0,num-1 do begin
  filenam=filename[picn]
  envi_open_file,filenam,r_fid =fid
  ENVI_FILE_QUERY,fid,dims= dims,bnames= bnames,nb = nb,ns = ns, nl = nl
  data[*,*,picn]= ENVI_GET_DATA(fid=fid, dims=dims, pos=0)
endfor
filepos=strpos(filename[0],'-RDN')
filehead=strmid(filename[0],0,filepos)
filenout=strjoin([filehead,'-B5-RDN'])
ENVI_WRITE_ENVI_FILE,data,out_name=filenout,NB=5, NL=nl, NS=ns
print,filenout
end