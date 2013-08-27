function varargout = findvalue(array,value,center)
numdims = ndims(array);

c = abs(array-value);
for i = numdims:-1:1
    c = min(c,[],i);
end

if nargin == 2
    ind = find(abs(array-value)==c,1);
else
    ind = find(abs(array-value)==c);
end

if numdims == 2 && sum(size(array)==1)
    t = cell(1);
else
    t = cell(1,numdims);
end
[t{:}] = ind2sub(numdims,ind);

if nargin == 3
    T = [t{:}];
    d = T;
    for i = 1:size(T,1)
        d(i,:) = (T(i,:)-center);
    end
    s = sum(d.^2,2);
    i = find(s==min(s),1);
    t = num2cell(T(i,:));
end

if nargout~=length(t)
    error('Not enough output arguments.')
end
varargout = t;

