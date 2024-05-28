%load('C:\Users\fiola\Desktop\月食\disk.mat')
%之前的实在太慢，没法用

%自定义大小
xnum=650;
ynum=xnum*2;

sz = size(destins);
xreso=6500000/xnum;
yreso=13000000/ynum;

densi=zeros(xnum,ynum);

x=reshape(destins(:,:,1),[1,84500000]);
y=reshape(destins(:,:,2),[1,84500000]);

%-65000000~65000000
for i=1:84500000
    if x(i) ~= 0 && y(i) ~=0
    
        xpos=max(ceil(real(x(i))/xreso),1);
        ypos=max(ceil(real(y(i))/xreso)+xnum,1);
        densi(xpos,ypos)=densi(xpos,ypos)+1;
    end
end
densi=densi';
surf(densi);
shading flat
% mesh(densi); %只有网格
% shading interp
view(0,90);
colorbar;
axis([1 xnum 1 ynum])
axis off