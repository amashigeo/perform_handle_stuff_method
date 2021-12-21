filename = 'C:\Users\Amairo\Desktop\10pi.txt';
mk=(fileread(filename));
char2asc2=abs(mk);%转ascii码
char2asc2(char2asc2==13)=[];%删除回车行
char2asc2(char2asc2==10)=[];%删除换行符
mk=char(char2asc2);

L = strlength(mk);
mk2=zeros(L,1);
resi=0;
car=0;
for i=L:-1:2
    mk2(i,1)=str2double(mk(i));
end

mk4=mk;
for j=2:1:L
    mk3=mk2;
    for i=L:-1:2
    mk2(i,1)=mod(mk3(i,1)*16+car,10);
    car=(fix((mk3(i,1)*16+car)/10));
    end
    mk4(j)=dec2hex(car);
    car=0;
end
filename =fopen( 'C:\Users\Amairo\Desktop\1.txt','w');
fprintf(filename,mk4);
fclose(filename);
