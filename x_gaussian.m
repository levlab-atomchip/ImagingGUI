function z = x_gaussian(beta,xdata)
x = 1:length(xdata);
if iscolumn(xdata)
    x = x';
end

A = beta(1);
x0 = beta(2);
sigmax = beta(3);
c = beta(4);

gaussian = A*exp(-(x-x0).^2/(2*sigmax^2));

z = gaussian + c;