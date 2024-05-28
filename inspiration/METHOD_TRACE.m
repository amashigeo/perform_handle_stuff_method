%根据一个光子的位置、速度，计算最后到达的月面平面位置和其强度

function destin = METHOD_TRACE(photon,atmosrefi,resolution,atmossact)
% track=zeros(100000,3);
% tracki=1;
    r_earth = 6371000;
    h=sqrt(photon(1)^2+photon(2)^2+photon(3)^2)-r_earth;
    while (h >85000)&&(photon(1) <0)%未到大气层前先飞
        photon(1:3)=photon(1:3)+photon(4:6)*resolution;
        h=sqrt(photon(1)^2+photon(2)^2+photon(3)^2)-r_earth;
    end
    if h >85000%错过了
        photon(2)=photon(2)+photon(5)/photon(4)*(384400000-photon(1));
        photon(3)=photon(3)+photon(6)/photon(4)*(384400000-photon(1));
        destin=[photon(2:3),1];
    else%折射
        while (h <=85000)&&(h >=resolution*1.5)
            lev1=round(h/resolution);
            photon(1:3)=photon(1:3)+photon(4:6)*resolution;
            h=sqrt(photon(1)^2+photon(2)^2+photon(3)^2)-r_earth;
            lev2=round(h/resolution);
            photon(7)=photon(7)*(1-atmossact(lev1+1));
            if lev1 ~= lev2
                photon=METHOD_REFLACT(photon,atmosrefi,resolution);
            end  
% track(tracki,:)=    photon(1:3);
% tracki=tracki+1;
        end
        if h < resolution%撞地
            destin=[0 0 0];
        else%走吧
            photon(2)=photon(2)+photon(5)/photon(4)*(384400000-photon(1));
            photon(3)=photon(3)+photon(6)/photon(4)*(384400000-photon(1));
            destin=[photon(2:3),photon(7)];
        end
    end
end