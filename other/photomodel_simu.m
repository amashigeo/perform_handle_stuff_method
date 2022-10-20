%模拟不同g下，月盘的亮度情况
g=0; %phase
model='ls';

disk=zeros(1001,1001);
geo=zeros(1001,1001,2);
wid=zeros(1001,1);
wid2=wid;
lati=wid;
emis=disk;
inci=disk;
for i=1:1001
    theta=acos((501-i)/500);
    wid(i)=sin(theta)*500;
    wid2(i)=wid(i)*abs(cos(g/180*pi));
    lati(i)=90-theta/pi*180;
end

if g <= 90
    for j=1:500 %x
        for i=1:1001 %y
            if (501-j) <= wid2(i)
                emis(i,j)=pi/2-acos(sqrt((501-i)^2+(501-j)^2)/500);
                lon1=asin((501-j)/wid(i));
                apa=lon1+g/180*pi;
                inci(i,j)=acos(cos(apa)*cos(lati(i)/180*pi));
                miu=cos(emis(i,j));
                miu0=cos(inci(i,j));
                disk(i,j)=reflec(miu,miu0,model);
            end
        end
    end
    for j=501:1001 %x
        for i=1:1001 %y        
            if (j-501) <= wid(i)
                emis(i,j)=pi/2-acos(sqrt((501-i)^2+(501-j)^2)/500);
                lon1=asin((j-501)/wid(i));
                apa=abs(lon1-g/180*pi);
                inci(i,j)=acos(cos(apa)*cos(lati(i)/180*pi));
                miu=cos(emis(i,j));
                miu0=cos(inci(i,j));
                disk(i,j)=reflec(miu,miu0,model);
            end
        end
    end
    
else
    
   for j=501:1001 %x
        for i=1:1001 %y        
            if ((j-501) >= wid2(i)) & ((j-501) <= wid(i))
                emis(i,j)=pi/2-acos(sqrt((501-i)^2+(501-j)^2)/500);
                lon1=asin((j-501)/wid(i));
                apa=abs(lon1-g/180*pi);
                inci(i,j)=acos(cos(apa)*cos(lati(i)/180*pi));
                miu=cos(emis(i,j));
                miu0=cos(inci(i,j));
                disk(i,j)=reflec(miu,miu0,model);
            end
        end
    end 
end



mymap1=0:0.8/256:0.8;
mymap2=0:0.9/256:0.9;
mymap3=0:1/256:1;
mymap=[mymap1;mymap2;mymap3];
mymap=mymap';

% 
imagesc(disk);
colorbar;
colormap(mymap);
axis image;
a=sum(disk,'omitnan');
%a=a';
b=sum(a)
function r=reflec(miu,miu0,model)
    if model == 'ls'
        %LS MODEL
        pg=1;
        w=1;
        r=miu0/(miu0+miu)*pg*w;
    end
end