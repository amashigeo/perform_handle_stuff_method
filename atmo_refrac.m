%每个点共4个位置参数，x，y（地心为0点），r，theta
%按照到地心的距离分层，100m为一层。

%需要修改的参数
wl=400;%光线波长 nm
enterang=80/180*pi();%进入位置角度 从下面逆时针开始算 x为上下，y为左右
enterang2=0/180*pi();%进入速度角度 从上面顺时针开始算 x为上下，y为左右


%初始化大气参数
%global r_earth;
r_earth = 6371000;%m
t_absz=273.15;
%高度->温度 大气压 大气密度(kg/m3)
atmos=zeros(3,851);
atmos(1,1)=15;
atmos(2,1)=101325;
atmos(3,1)=1.225;
%几个分层处
atmsp=[1 111 201 321 471 511 711 851];
atmspvalue=[15	-56.5	-56.5	-44.5	-2.5	-2.5	-58.5	-86.204
101325	22632	5474.9	868.02	110.91	66.939	3.9564	0
1.225	0.3639	0.088	0.0132	0.0014	0.0009	0.0001	0
];%

for spi=1:7
for i=atmsp(spi)+1:atmsp(spi+1)
    sp1=(atmspvalue(1,spi+1)-atmspvalue(1,spi))/(atmsp(spi+1)-atmsp(spi));
    sp2=(atmspvalue(2,spi+1)-atmspvalue(2,spi))/(atmsp(spi+1)-atmsp(spi));
    sp3=(atmspvalue(3,spi+1)-atmspvalue(3,spi))/(atmsp(spi+1)-atmsp(spi));
    atmos(1,i)=atmspvalue(1,spi)+(i-atmsp(spi))*sp1;
    atmos(2,i)=atmspvalue(2,spi)+(i-atmsp(spi))*sp2;
    atmos(3,i)=atmspvalue(3,spi)+(i-atmsp(spi))*sp3;
end
end
atmos=atmos';


%————————————————————————%
%global photon ;
%photon = zeros(6);%坐标x,y,z,方向矢量xyz(归一化到1


wn=1000/wl;%μm^-1
sta_refi=(8342.13+2406030*(130-wn^2)^(-1)+15997*(38.9-wn^2)^(-1))*1e-8;%(n-1) 两倍差0.048e-4，几乎可忽略
atmosrefi=zeros(851,1);
for i=1:851
    atmosrefi(i)=1+atmos(i,2)/133.3223684*sta_refi/720.775*(1+atmos(i,2)*(0.817-0.0133*atmos(i,1))*1e-6)/(1+0.003661*atmos(i,1));
end
%test
% photon=[6372000,500,0.001,1,0.001,0.001];
% photon=refrac(photon,r_earth,atmosrefi);
%
route=zeros(100000,3);%记录路径

phdis=6456000;%高度
h=85000;


enterp=[-phdis*cos(enterang),phdis*sin(enterang),0];%进入位置
enterv=[phdis*cos(enterang2),phdis*sin(enterang2),0];%进入速度
enterv=enterv/norm(enterv);
photon=[enterp,enterv];
count1=1;
while (h <=85000)&&(h >=100)
    
    route(count1,:)=photon(1:3);
    
    lev1=round(h/100);
    photon(1:3)=photon(1:3)+photon(4:6)*100;%每次前进100m
    h=sqrt(photon(1)^2+photon(2)^2+photon(3)^2)-r_earth;
    lev2=round(h/100);
    if lev1 ~= lev2
        photon=refrac(photon,r_earth,atmosrefi);
    end
    count1=count1+1;
    
end




%检测到lev变化时，进行折射
function newphoton = refrac(photon,r_earth,atmosrefi)

    h=sqrt(photon(1)^2+photon(2)^2+photon(3)^2)-r_earth;
    lev=round(h/100);
    cost1=(photon(1)*photon(4)+photon(2)*photon(5)+photon(3)*photon(6))/(sqrt(photon(1)^2+photon(2)^2+photon(3)^2)+sqrt(photon(4)^2+photon(5)^2+photon(6)^2));
    sint1=sqrt(1-cost1^2);
    if cost1 > 0 %离开
        levin=lev;
        levout=lev+1;
    else %进入
        levin=lev+1;
        levout=lev;
    end
    if levin > 851
        levin=851;
    end
    if levout > 851
        levout=851;
    end
    sint2=sint1*atmosrefi(levin)/atmosrefi(levout);
    %cost2=sqrt(1-sint2^2);
    t2=asin(sint2);
    if cost1 < 0
        t2=pi()-t2;
    end
    
    %abcnorm=1
    a=photon(1:3);
    b=photon(4:6);
    axb=cross(photon(1:3),photon(4:6));
    %axc=axb/sint1*sint2;
    h = makehgtform('axisrotate',axb,t2); 
    c = h(1:3,1:3)*a(:);

    c=c';
    c=c/norm(c);
    newphoton=[photon(1:3),c];
end