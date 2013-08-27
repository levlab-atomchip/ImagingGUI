function z = xy_gaussian(beta,xdata,extra)
if nargin == 2
    extra = 1;
end
[m,n] = size(xdata);
[x,y] = meshgrid(1:1/extra:n,1:1/extra:m);

A = beta(1);
x0 = beta(2);
y0 = beta(3);
sigmax = beta(4);
sigmay = beta(5);
c = beta(6);
theta = beta(7);

x2 = x*cos(theta) + y*sin(theta);
y2 = -x*sin(theta) + y*cos(theta);

x20 = x0*cos(theta) + y0*sin(theta);
y20 = -x0*sin(theta) + y0*cos(theta);

gaussian = A*exp(-(y2-y20).^2/(2*sigmay^2) - (x2-x20).^2/(2*sigmax^2));

z = gaussian + c;