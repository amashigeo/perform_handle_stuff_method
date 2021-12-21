filename = 'C:\Users\Amairo\Desktop\Pi\Pi - Hex.txt';
mk=(fileread(filename)); 
L = strlength(mk);

ctable=zeros(16,10);
for i=1:8
    dow=(i-1)*1e8+3;
    up=(i)*1e8+2;
    mk3=mk(dow:up);
    
    ctable(1,i)=count(mk3,'0');
    ctable(2,i)=count(mk3,'1');
    ctable(3,i)=count(mk3,'2');
    ctable(4,i)=count(mk3,'3');
    ctable(5,i)=count(mk3,'4');
    ctable(6,i)=count(mk3,'5');
    ctable(7,i)=count(mk3,'6');
    ctable(8,i)=count(mk3,'7');
    ctable(9,i)=count(mk3,'8');
    ctable(10,i)=count(mk3,'9');
    ctable(11,i)=count(mk3,'a');
    ctable(12,i)=count(mk3,'b');
    ctable(13,i)=count(mk3,'c');
    ctable(14,i)=count(mk3,'d');
    ctable(15,i)=count(mk3,'e');
    ctable(16,i)=count(mk3,'f');
end
clearvars mk mk3