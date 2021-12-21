digit=100000;
h=digit/5;
a=100000;
c=h*14;
e=0;
f=ones(c+1,1)*200000;
h2=1;
f2=zeros(h,1);
while (c > 0)
    d=0;
    g=c*2;
    b=c;
    while (1)
        d=d+f(b+1,1)*a;
        g=g-1;
        f(b+1,1)=mod(d,g);
        d=fix(d/g);
        g=g-1;
        b=b-1;
        if (b==0)
            break;
        end
        d=d*b;
    end
    c=c-14;
    f2(h2,1)=e+fix(d/a);
    e=mod(d,a);
    h2=h2+1;
end
filename =fopen( 'C:\Users\Amairo\Desktop\1.txt','w');
fprintf(filename,'%05u\r\n',round(f2));
fclose(filename);