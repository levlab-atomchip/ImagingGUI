function z = x_gaussianbec(beta,xdata)
x = 1:length(xdata);
if iscolumn(xdata)
    x = x';
end

A = beta(1);
x0 = beta(2);
sigmax = beta(3);

B = beta(4);
b = beta(5);
c = beta(6);

gaussian = A*exp(-(x-x0).^2/(2*sigmax^2));

bec = (B - b*(x-x0).^2);
bec(bec<0) = 0;
bec = bec.^2;

z = gaussian + bec + c;