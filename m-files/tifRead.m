function [ output_args ] = tifRead( filename, zNum, tNum, resDir )
%TIFREAD この関数の概要をここに記述
%   詳細説明をここに記述

info = imfinfo(filename);
num_images = numel(info);
r = info(1).Height;
c = info(1).Width;
imageStack = zeros(r, c, num_images);
for k = 1:num_images
    imageStack(:,:,k) = imread(filename, k);
    % ... Do something with image A ...
end
imageStack = reshape(imageStack, [r,c,zNum, tNum]);
mkdir(resDir);
imageFilename = [resDir, '\stack.mat'];
parsaveStack(imageFilename, imageStack);

