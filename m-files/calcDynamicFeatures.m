function featureTable = calcDynamicFeatures( seg, resXY, resZ )
%CELLSHAPEFEATURES

magMemb = double(seg) * 1000;
tStack = arrayfun(@(x) x * ones(size(seg,1),size(seg,2),size(seg,3)), 1:size(seg,4), 'UniformOutput', false);
tStack = cat(4, tStack{:});
tStack = immultiply(tStack, logical(magMemb));
lab3 = double(magMemb) + tStack;
uniLab = unique(nonzeros(lab3(:)));
lab3 = tikan(lab3, uniLab, 1:length(uniLab));

cent = regionprops(lab3, 'Centroid');
cent = cat(1, cent.Centroid);

% Correspondance with ID
lab3Memb = [lab3(:), seg(:)];
lab3MembNum = sum(logical(lab3Memb),2);
lab3Memb = lab3Memb(lab3MembNum==2,:);
Label = unique(lab3Memb, 'rows');
Label = Label(:,2);

%% 3D shape features
[r,c,z,t] = size(lab3);
lab3 = reshape(lab3, r,c,z*t);
stats = regionprops3(lab3, 'Volume', 'SurfaceArea', 'PrincipalAxisLength', 'Solidity');

% Vol
VolumeOri = cat(1, stats.Volume);
Volume = cat(1, stats.Volume) * (resXY * resXY * resZ);
SurfaceAreaOri = cat(1, stats.SurfaceArea);
SurfaceArea = cat(1, stats.SurfaceArea) * (resXY * resXY * resZ);
PrincipalAxisLength = cat(1, stats.PrincipalAxisLength);
PrincipalAxisLengthFirst = PrincipalAxisLength(:,1) * (resXY * resXY * resZ)^(1/3);
PrincipalAxisLengthSecond = PrincipalAxisLength(:,2) * (resXY * resXY * resZ)^(1/3);
PrincipalAxisLengthThird = PrincipalAxisLength(:,3) * (resXY * resXY * resZ)^(1/3);
Solidity = cat(1, stats.Solidity);
SAtoV = SurfaceAreaOri ./ VolumeOri;

% Centroids
CentroidX = cent(:,1) * resXY;
CentroidY = cent(:,2) * resXY;
CentroidZ = cent(:,3) * resZ;
CentroidT = cent(:,4);

% Sphericity
Sphericity = pi^(1/3) * ((6 * VolumeOri).^(2/3)) ./ SurfaceAreaOri;

%% table
featureTable = table(Label, CentroidX, CentroidY, CentroidZ, CentroidT, Volume, SurfaceArea, SAtoV, Solidity, ...
                      PrincipalAxisLengthFirst, PrincipalAxisLengthSecond, PrincipalAxisLengthThird, Sphericity);


