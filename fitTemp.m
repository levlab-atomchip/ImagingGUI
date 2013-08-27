function fitTemp(tempInfo)
global hfig_main

tofs = tempInfo(:,1)*10^-3;
N = mean(tempInfo(:,2));
sx = tempInfo(:,3);
sy = tempInfo(:,4);

options = optimset('Display','off','MaxIter',40);

fittedx = nlinfit(tofs,sx,@toftemp,[sx(1) .002],options);
sigma_x0 = fittedx(1)*sqrt(2);
sigma_xv = fittedx(2);
Tx = hfig_main.calculation.atomicMass*1.67e-27/1.38e-23*sigma_xv^2;

fittedy = nlinfit(tofs,sy,@toftemp,[sy(1) .002],options);
sigma_y0 = fittedy(1);
sigma_yv = fittedy(2);
Ty = hfig_main.calculation.atomicMass*1.67e-27/1.38e-23*sigma_yv^2;

sigma_z0 = sigma_y0*3;%mean([ sigma_x0 sigma_y0])*1.5;
V_bar = (2*pi)^1.5*sigma_x0*sigma_y0*sigma_z0;
n = N/V_bar;

psd_x = n*(2*pi*(1.05e-34)^2/(hfig_main.calculation.atomicMass*1.67e-27*1.38e-23*Tx))^1.5;
psd_y = n*(2*pi*(1.05e-34)^2/(hfig_main.calculation.atomicMass*1.67e-27*1.38e-23*Ty))^1.5;

strPSD_x = sprintf('%.2e', psd_x);
strPSD_y = sprintf('%.2e', psd_y);

disp(['T_x: ' num2str(Tx)])
disp(['PSD_x: ' strPSD_x])
disp(['T_y: ' num2str(Ty)])
disp(['PSD_y: ' strPSD_y])

if get(hfig_main.tempx_on,'value') || get(hfig_main.tempy_on,'value') || get(hfig_main.tempxy_on,'value')
    figure(161)
    set(gcf,'name','Temperature','NumberTitle','off','tag','Temperature')
    if get(hfig_main.tempxy_on,'value')
        sp = 2;
    else
        sp = 1;
    end
%     if get(hfig_main.tempx_on,'value') || get(hfig_main.tempxy_on,'value')
%         subplot(sp,1,1)
%         title('x-temp')
%         plot(tofs,sx,'.b',0:tofs(end)/20:tofs(end),toftemp(fittedx,0:tofs(end)/20:tofs(end)),'-r')
%     end
%     if get(hfig_main.tempy_on,'value') || get(hfig_main.tempxy_on,'value')
%         subplot(sp,1,sp)
%         title('y-temp')
%         plot(tofs,sy,'.b',0:tofs(end)/20:tofs(end),toftemp(fittedy,0:tofs(end)/20:tofs(end)),'-r')
%     end

    if get(hfig_main.tempx_on,'value') || get(hfig_main.tempxy_on,'value')
        subplot(sp,1,1)
        title('x-temp')
        plot(tofs,sx,'.b',0:max(tofs)/20:max(tofs),toftemp(fittedx,0:max(tofs)/20:max(tofs)),'-r')
    end
    if get(hfig_main.tempy_on,'value') || get(hfig_main.tempxy_on,'value')
        subplot(sp,1,sp)
        title('y-temp')
        plot(tofs,sy,'.b',0:max(tofs)/20:max(tofs),toftemp(fittedy,0:max(tofs)/20:max(tofs)),'-r')
    end
end