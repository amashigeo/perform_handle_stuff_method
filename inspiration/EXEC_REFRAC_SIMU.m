%模拟折射主程序2
%MC 月球分块统计 瑞利散射

%需要修改的参数
num=100;%MC次数

wl=800;%光线波长 nm
resolution=100;%大气分层分辨率 m

photon=zeros(7,1);
photon=photon';
%坐标x,y,z,方向矢量xyz(归一化到1,强度（一开始为1）
disk=zeros(4001,4001);%km


%%初始化大气参数————————————————————————————————
r_earth = 6371000;%m
t_absz=273.15;

sea_scatnum=2548761.55;%每1m碰撞次数
%高度->温度 大气压 大气密度(kg/m3)
levels=85000/resolution+1;
atmos=zeros(3,levels);
atmos(1,1)=15;
atmos(2,1)=101325;
atmos(3,1)=1.225;
%几个分层处
atmsp=[1 11000/resolution+1 20000/resolution+1 32000/resolution+1 47000/resolution+1 51000/resolution+1 71000/resolution+1 85000/resolution+1];
atmspvalue=[15	-56.5	-56.5	-44.5	-2.5	-2.5	-58.5	-86.204
101325	22632	5474.9	868.02	110.91	66.939	3.9564	0
1.225	0.3639	0.088	0.0132	0.0014	0.0009	0.0001	0 %kg/m3
];
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
%计算折射率owens1967
wn=1000/wl;%μm^-1
vbar=1/wl*1e7;%cm-1
fkv=1.34+3.17e-12*vbar;

atmos(:,1)=atmos(:,1)+t_absz;%K millibar
atmos(:,2)=atmos(:,2)/100;
atmosrefi=zeros(levels,1);
atmossact=zeros(levels,1);%一个单位折射衰减
for i=1:levels
    ds=atmos(i,2)/atmos(i,1)*(1+atmos(i,2)*(57.9e-8-9.325e-4/atmos(i,1)+0.25844/(atmos(i,1))^2));
    atmosrefi(i)=1+(2371.34+683939.7/(130-wn^2)+4547.3/(38.9-wn^2))*ds*1e-8;
    atmos(i,3)=atmos(i,3)*1000/29*6.022*1e17;%molenum 个/cm3
    
    atmossact(i)=24*pi()^3*(vbar^4)/atmos(i,3)*((atmosrefi(i)^2-1)/(atmosrefi(i)^2+2))^2*fkv;%cm-1 吸收
    atmossact(i)=1-(1-atmossact(i))^(100*resolution);%每resolution（当前100m）吸收
end
%——————————————————————————————————————————————
incirange=0.004652439;%rad
for incii=1:num 
    %随机入射方向
    tempi=rand(1,4)*2-1;%前两个为入射位置，6500±3000，后两个为方向
    if tempi(3)^2+tempi(4)^2 <=1
        photon(5:6)=tempi(3:4)*incirange;
        photon(4)=1;
        photon(2)=6500000+tempi(1)*3000000;
        photon(3)=tempi(2)*3000000;
        photon(1)=-6500000;
        photon(7)=1;

        destin=METHOD_TRACE(photon,atmosrefi,resolution,atmossact);%destin的1，2分别为y，z
        if abs(destin(1)-6500000) <=2000000 && abs(destin(2)) <=2000000
            destx=fix((destin(1)-6500000)/1000)+2001;
            desty=fix(destin(2)/1000)+2001;
            disk(destx,desty)=disk(destx,desty)+destin(3);
        end
    end   
end

surf(disk);
shading flat
view(0,90);
colorbar;
% axis([1 xnum 1 ynum])
% axis off
