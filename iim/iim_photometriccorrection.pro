pro iim_photometriccorrection
  ;将IIM图像进行光度校正 得到radf
  filename=dialog_pickfile(filter='*ff.img',/read,/multiple)
  number=size(filename)
  num=number[3]

  pa=fltarr(9,26);使用参数
  parafile=dialog_pickfile(filter='*.*',/read,/multiple)
  openr,lun1,parafile,/get_lun
  readf,lun1,pa
  free_lun,lun1

  geoto=[0.01,30,0.01];校正的角度
  geoto=geoto/180*!pi
  geo=fltarr(3)
  PTYPE=2
  irradi=[1903.584717, 1920.4646, 1909.970947, 1888.208252, 1871.331787, 1857.649902, 1834.892578, 1796.999634, 1751.149536, 1707.906128, 1666.663208, 1622.91333,  1578.257202, 1534.070435, 1487.466431, 1436.148438, 1378.117676, 1320.209595, 1269.272827, 1209.996704, 1152.953003, 1100.534912, 1039.999268, 986.131897,  940.860229,  883.746948]
  correfa=[1.086674, 1.091509,  1.090131,  0.899843,  0.954924,  1.072369,  1.065095,  0.867045,  0.952112,  0.992657,  1.000957,  0.978243,  1.039928,  0.981593,  1.043024,  1.01067, 1.02006, 1.035991,  1.040135,  0.956926,  1.005518,  0.972622,  0.952207,  1.014962,  0.940861,  1.795692]


  for picn=0,num-1 do begin
    filenam=filename[picn]
    filepos=strpos(filenam,'_remove')
    filen1=strmid(filenam,0,filepos)
    ;print,filen1
    filedir=strmid(filenam,0,filepos-4)
    orbitnum=strmid(filenam,filepos-4,4)
    fsign='*_'+string(orbitnum)+'_A-mirror*'
    rtime=file_search(filedir,fsign,count = rtimenum)
    if rtimenum eq 0 then begin
      print,filenam+'  error'
    endif
    timepos=strpos(rtime[0],orbitnum)
    orbittime=strmid(rtime[0],timepos-30,29)
    filegeo=strjoin([filen1,'-7band.img'])
    filedis=strjoin([filen1,'-sunmoon.img'])
    if strpos(parafile,'hp1.txt') ne -1 then begin
      fileout=strjoin([filen1,'_bp_ff_hpc_'+orbittime+'.img'])
    endif else if strpos(parafile,'mp1.txt') ne -1 then begin
      fileout=strjoin([filen1,'_bp_ff_mpc_'+orbittime+'.img'])
    endif else begin
      print,filenam+'  error'
    endelse
    
    ;iim data
    envi_open_file,filenam,r_fid =fid
    ENVI_FILE_QUERY,fid,dims= dims,bnames= bnames,nb = nb,ns = ns, nl = nl
    iimdata = fltarr(ns,nl,nb)
    for i = 0,nb-1 do begin
      iimdata[*,*,i] = ENVI_GET_DATA(fid=fid,dims=dims,pos=i)
    endfor
    ;geometric data
    envi_open_file,filegeo,r_fid =fid2
    ENVI_FILE_QUERY,fid2,dims= dims,bnames= bnames,nb = 7,ns = ns, nl = nl
    geodata = fltarr(ns,nl,7)
    for i = 0,6 do begin
      geodata[*,*,i] = ENVI_GET_DATA(fid=fid2,dims=dims,pos=i)
    endfor
    ;distance data
    envi_open_file,filedis,r_fid =fid3
    ENVI_FILE_QUERY,fid3,dims= dims,bnames= bnames,nb = 6,ns = ns, nl = nl
    disdata = fltarr(ns,nl)
    disdata[*,*] = ENVI_GET_DATA(fid=fid3,dims=dims,pos=0)

    ;ratio = fltarr(ns,nl)
    ;    for i=0,nl-1,1 do begin
    ;      for j=0,ns-1,1 do begin
    ;
    ;      endfor
    ;    endfor
    for k=5,30,1 do begin
      p=pa[*,k-5]
      r30=Ref(PTYPE,p,geoto)
      for i=0,nl-1,1 do begin
        for j=0,ns-1,1 do begin
          geo[0]=geodata[j,i,0];viewzen
          if geo[0] lt 0.05 then begin
            geo[0]=0.05
          endif
          geo[1]=geodata[j,i,2];sunzen
          geo[2]=abs(geodata[j,i,1]-geodata[j,i,3]);relative azimuth
          if geo[1] lt 0.05 then begin
            geo[1]=0.05
          endif
          if geo[2] lt 0.05 then begin
            geo[2]=0.05
          endif
          if geo[2] gt 180 then begin
            geo[2]=360-geo[2]
          endif
          geo=geo/180*!pi
          iimdata[j,i,k]=iimdata[j,i,k]*r30/Ref(PTYPE,p,geo)*!pi/irradi[k-5]*(disdata[j,i]/149597871)^2*1000*correfa[k-5]

        endfor
      endfor
      print,k
    endfor
    outdata=fltarr(ns,nl,26)
    outdata[*,*,*]=iimdata[*,*,5:30]
    ENVI_WRITE_ENVI_FILE,outdata,out_name=fileout,NB=26, NL=nl, NS=ns
    delvar,iimdata,geodata,outdata
    print,fileout
  endfor
  ;geo=[0.0426919744663128, 0.398711733815995, 1.17770333021812]
  ;p=[0.224730812,  0, 0.008022078, 0.203209432, 0, 0.408407045, 1.25,  1.320295972, 0.205137758]
  ;ptype=2
  ; rraw=Ref(PTYPE,p,geo);
  ; print,rraw
end





function Ref,PTYPE,p,geo

  to=geo(0); % e the emission angle
  ts=geo(1); % i the incidence angle
  if ts ge !pi/2 then begin
    r = 0;
    return, 0;
  endif


  psi=geo(2);% psi
  if (to eq 0) or (ts eq 0)  then begin
    psi = 0;
  endif


  w=p(0);
  if w gt 1 then begin
    w = 0.9999998;
  endif


  h=p(1);
  b=p(2);
  c=p(3);

  B0=p(4);

  theta = p(5);
  if theta lt 0 then begin
    theta = 0;
  endif


  if theta gt 1.4 then begin
    theta = 1.4;
  endif

  K= p(6);
  Bc0= p(7);
  hc= p(8);

  cos_ts=cos(ts);
  cos_to=cos(to);
  sin_ts=sin(acos(cos_ts));
  sin_to=sin(acos(cos_to));

  cos_g = cos_ts*cos_to+sin_ts*sin_to*cos(psi);
  Pg = PG(PTYPE,b,c,cos_g);

  g = acos(cos_g); % calculate g
  if h eq 0 then begin
    Bg = 0;
  endif


  if abs(g) lt 0.001 then begin
    Bg = B0/(1+g/(2*h)); % B(g) function
  endif else begin
    Bg = B0/(1+tan(g/2)/h); % B(g) function
  endelse


  if abs(psi) lt 3.1 then begin
    f_psi = exp(-2*tan(psi/2.)); % f(psi) function
  endif else begin
    f_psi = 0;
  endelse

  zeta=tan(g/2)/hc;

  Bcg=Bc0*(1+(1-exp(-zeta))/zeta)/2/(1+zeta)^2;

  if theta eq 0 then begin
    S = 1;
    u0e = cos_ts;
    ue = cos_to;
  endif else begin
    Chi_theta = 1/sqrt( 1.+!pi* tan(theta)^2 ); % Chi(theta) function
    if abs(sin_to) lt 0.0001 then begin
      E1_to = 0;
      E2_to = 0;
    endif else begin
      E1_to = -2/tan(theta)/tan(to)/!pi;
      E2_to = -(1/tan(theta)^2)*(1/tan(to)^2)/!pi;
    endelse
    if E1_to gt 88 then begin
      E1_to = 88;
    endif
    if E2_to gt 88 then begin
      E2_to = 88;
    endif
    if abs(sin_ts) lt 0.0001 then begin
      E1_ts = 0;
      E2_ts = 0;
    endif else begin
      E1_ts = -2/tan(theta)/tan(ts)/!pi;
      E2_ts = -(1/tan(theta)^2)*(1/tan(ts)^2)/!pi;
    endelse
    if E1_ts gt 88 then begin
      E1_ts = 88;
    endif
    if E2_ts gt 88 then begin
      E2_ts = 88;
    endif
    E1_to = exp(E1_to); % E1(e) function
    if E1_to gt 1.0E20 then begin
      E1_to = 1.0E20;
    endif
    E2_to = exp(E2_to); % E2(e) function
    if E2_to gt 100 then begin
      E2_to = 100;
    endif
    E1_ts = exp(E1_ts); % E1(i) function
    if E1_ts gt 1.0E20 then begin
      E1_ts = 1.0E20;
    endif
    E2_ts = exp(E2_ts); % E2(i) function
    if E2_ts gt 1.0E20 then begin
      E2_ts = 1.0E20;
    endif
  endelse
  ;% ----------------------calculate the u0e(0) and ue(0) value --------------------------------
  if ( 2-E1_ts eq 0 ) then begin
    ;warning('u0e_0 becomes infinite,because the denominator is zero.')
  endif
  u0e_0 = Chi_theta*(cos_ts+sin_ts*tan(theta)*E2_ts/(2-E1_ts)); % u0e(0)
  if ( 2-E1_to eq 0 ) then begin
    ;warning('ue_0 becomes infinite,because the denominator is zero.')
  endif
  ue_0 = Chi_theta*(cos_to+sin_to*tan(theta)*E2_to/(2-E1_to)); % ue(0)
  if( ts le to ) then begin
    u0e = Chi_theta*(cos_ts+sin_ts*tan(theta)*(cos(psi)*E2_to+(sin(psi/2.)^2)*E2_ts)/(2-E1_to-(psi/!pi)*E1_ts)); % u0e function
    ue = Chi_theta*(cos_to+sin_to*tan(theta)*(E2_to-(sin(psi/2.)^2)*E2_ts)/(2-E1_to-(psi/!pi)*E1_ts)); % ue function
    S = (ue/ue_0)*(cos_ts/u0e_0)*Chi_theta/(1-f_psi+f_psi*Chi_theta*(cos_ts/u0e_0)); % S(i,e,psi) function
    if  ((ue_0 eq 0) || (u0e_0 eq 0) || (1-f_psi+f_psi*Chi_theta*cos_ts eq 0) ) then begin
      ;warning('S(i,e,psi) function becomes infinite,because the denominator is zero.');
    endif
  endif else begin;% ts > te
    u0e = Chi_theta*(cos_ts+sin_ts*tan(theta)*(E2_ts-(sin(psi/2.)^2)*E2_to)/(2-E1_ts-(psi/!pi)*E1_to)); % u0e function
    ue = Chi_theta*(cos_to+sin_to*tan(theta)*(cos(psi)*E2_ts+(sin(psi/2.)^2)*E2_to)/(2-E1_ts-(psi/!pi)*E1_to)); % ue function
    S = (ue/ue_0)*(cos_ts/u0e_0)*Chi_theta/(1-f_psi+f_psi*Chi_theta*(cos_to/ue_0)); % S(i,e,psi) function
    if ( ue_0 eq 0 || u0e_0 eq 0 || 1-f_psi+f_psi*Chi_theta*cos_to eq 0 ) then begin
      ;warning('S(i,e,psi) function becomes infinite,because the denominator is zero.');
    endif
  endelse


  r0=(1-sqrt(1-w))/(1+sqrt(1-w));
  ie2=cos(u0e)/K;
  ee2=cos(ue)/K;
  Hie=1/(1-w*ie2*(r0+(0.5-r0*ie2)*alog((1+ie2)/ie2)));
  Hee=1/(1-w*ee2*(r0+(0.5-r0*ee2)*alog((1+ee2)/ee2)));
  M = Hie*Hee-1;
  r = u0e/(u0e+ue)*w*K*((1.+Bg)*Pg+M)*(1+Bcg)*S/4;
  return,r
end

function PG,FTYPE,b,c,cosx


  NUM = 1-b^2;
  DEN1 = (1+2*b*cosx+b^2)^1.5;
  DEN2 = (1-2*b*cosx+b^2)^1.5;
  pg = (1+c)*0.5*NUM/DEN2+(1-c)*0.5*NUM/DEN1;
  return,pg
end

