function z_range = zRange(membImgDir, zRangeDir)

%% Load
memb=oneStackLoad(membImgDir);

%% Upper
thisMemb = sum(memb, 4);

membSum = squeeze(sum(sum(thisMemb, 1), 2));
upper = find(membSum == max(membSum));

%% Lower
thisMemb = sum(memb, 4);

thisMemb = imgaussfilt3(thisMemb, 1);
[r,c,z] = size(thisMemb);

% Binarize
bw1 = arrayfun(@(x) thisMemb(:,:,x) > mean(reshape(thisMemb(:,:,x), [r*c, 1])) + std(reshape(thisMemb(:,:,x), [r*c, 1])), 1:z, 'UniformOutput', false);
bw1 = cat(3, bw1{:});

% Area
area1 = sum(reshape(bw1, [r*c, z]));
area1 = area1(1:upper);

% Peaks
lower = imregionalmin(area1);
lower(1) = 0;
lower(end) = 0;
lower = find(lower, 1, 'first' );

%% Save
z_range = [lower' upper'];
filename = [zRangeDir, filesep, 'zRange.mat'];
parsaveData(filename, z_range);

