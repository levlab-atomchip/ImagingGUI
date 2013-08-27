function boxdisp(string, linesize)
if ~ischar(string)
    disp('First input must be a string!')
    return
end
if ~exist('linesize','var') || linesize < length(string)+4
    linesize = length(string)+4;
end
pads = linesize-length(string)-2;
pad1 = round(pads/2);
pad2 = floor(pads/2);
topbottom = strrep(blanks(linesize),' ','*');
middle = [strrep(blanks(pad1),' ','*') ' ' string ' ' strrep(blanks(pad2),' ','*')];
disp(topbottom)
disp(middle)
disp(topbottom)
