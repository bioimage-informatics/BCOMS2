function ratio = ratioPrePerPost(arr)
%RATIOPREPERPOST 

len = length(arr);
rat = arr(2:len) ./ arr(1:len-1);
ratio = zeros(size(arr));
ratio(2:end) = rat;
