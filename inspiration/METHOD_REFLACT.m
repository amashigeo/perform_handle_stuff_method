function newphoton = METHOD_REFLACT(photon,atmosrefi,resolution)
    r_earth = 6371000;
    h=sqrt(photon(1)^2+photon(2)^2+photon(3)^2)-r_earth;
    levels=85000/resolution+1;
    lev=round(h/resolution);
    cost1=(photon(1)*photon(4)+photon(2)*photon(5)+photon(3)*photon(6))/(sqrt(photon(1)^2+photon(2)^2+photon(3)^2)+sqrt(photon(4)^2+photon(5)^2+photon(6)^2));
    sint1=sqrt(1-cost1^2);
    if cost1 > 0 %离开
        levin=lev;
        levout=lev+1;
    else %进入
        levin=lev+1;
        levout=lev;
    end
    if levin > levels
        levin=levels;
    end
    if levout > levels
        levout=levels;
    end
    sint2=sint1*atmosrefi(levin)/atmosrefi(levout);
    %cost2=sqrt(1-sint2^2);
    t2=asin(sint2);
    if cost1 < 0
        t2=pi()-t2;
    end
    
    %abcnorm=1
    a=photon(1:3);
    %b=photon(4:6);
    axb=cross(photon(1:3),photon(4:6));
    %axc=axb/sint1*sint2;
    h = makehgtform('axisrotate',axb,t2); 
    c = h(1:3,1:3)*a(:);

    c=c';
    c=c/norm(c);
    newphoton=[real(photon(1:3)),real(c),photon(7)];
end