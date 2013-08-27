function sigma = toftemp(beta,tof)

sigma_0 = beta(1);
sigma_v = beta(2);

sigma = (sigma_0^2 + sigma_v^2.*tof.^2).^.5;