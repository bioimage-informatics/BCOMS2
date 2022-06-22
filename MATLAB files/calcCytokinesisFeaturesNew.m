function [ features ] = calcCytokinesisFeaturesNew( nucSeg, nuc, memb )

% size
[r,c,z,t] = size(nucSeg);


% centroids
nucSeg = bwconncomp(nucSeg, 26);
nucSeg = labelmatrix(nucSeg);
data = regionprops(nucSeg, 'Centroid');
data = round(cat(1, data.Centroid));

%% Time related features
time = 1:size(nucSeg, 4);

%% Membrane features

% ×–EŠj‚ğŒ‹‚Ôü•ªã‚Ì‹P“x’l
upData = data(1:2:end, :);
downData = data(2:2:end, :);
% drawline3D
lineImg = arrayfun(@(x) drawline3D( zeros(r,c,z), upData(upData(:,4)==x, 2), upData(upData(:,4)==x, 1), upData(upData(:,4)==x, 3),...
    downData(downData(:,4)==x, 2), downData(downData(:,4)==x, 1), downData(downData(:,4)==x, 3)), 1:t, 'UniformOutput', false);
% int on line
intOnLine = arrayfun(@(x) immultiply(imdilate(lineImg{x}, ones(3,3,3)), memb(:,:,:,x)), 1:t, 'UniformOutput', false);
intOnLine = cat(4, intOnLine{:});

% max int on line
intOnLineReshape = reshape(intOnLine, [r*c*z, t]);
intOnLineReshape(intOnLineReshape==0) = NaN;
maxIntOnLine = squeeze(nanmax(intOnLineReshape));
maxIntOnLineNorm = mat2gray(maxIntOnLine);
% ratio from pre
maxIntOnLineRatio = ratioPrePerPost(maxIntOnLine);
maxIntOnLineRatioNorm = mat2gray(maxIntOnLineRatio);

% max int unti the time
maxIntPastOnLineNorm = arrayfun(@(x) max(maxIntOnLineNorm(1:x)), 1:t);

% position of max int
maxPos = arrayfun(@(x) findmulti(intOnLine(:,:,:,x)==maxIntOnLine(x)), 1:t, 'UniformOutput', false);%r,c,z
distUp = arrayfun(@(x) sum(sqrt(((upData(upData(:,4)==x, 1:3) - [maxPos{x}(2) maxPos{x}(1) maxPos{x}(3)]).^2))), 1:t);%data‚É‡‚í‚¹‚Ä‡”Ô‚ğ“ü‚ê‘Ö‚¦‚é
distDown = arrayfun(@(x) sum(sqrt(((downData(downData(:,4)==x, 1:3) - [maxPos{x}(2) maxPos{x}(1) maxPos{x}(3)]).^2))), 1:t);%data‚É‡‚í‚¹‚Ä‡”Ô‚ğ“ü‚ê‘Ö‚¦‚é
distMaxCent = min([distUp; distDown]);
distCentCent = arrayfun(@(x) sum(sqrt(((upData(upData(:,4)==x, 1:3) - downData(downData(:,4)==x, 1:3)).^2))), 1:t);% ×–EŠjŠÔ‹——£
posMax = distMaxCent ./ distCentCent;
posMaxNorm = mat2gray(posMax);

%% Nucleus features

% mean int
nucOver = immultiply(nuc, logical(nucSeg));
nucOverReshape = reshape(nucOver, [r*c*z, t]);
nucOverReshape(nucOverReshape==0) = NaN;
meanNuc = squeeze(nanmean(nucOverReshape));
meanNucNorm = mat2gray(meanNuc);
% ratio from pre
meanNucRatio = ratioPrePerPost(meanNuc);
meanNucRatioNorm = mat2gray(meanNucRatio);

% size
nucSegReshape = reshape(logical(nucSeg), [r*c*z, t]);
szNuc = squeeze(sum(nucSegReshape));
szNucNorm = mat2gray(szNuc);
% ratio from pre
szNucRatio = ratioPrePerPost(szNuc);
szNucRatioRatioNorm = mat2gray(szNucRatio);

% distance
distCentCentNorm = mat2gray(distCentCent);
% ratio from pre
distCentCentRatio = ratioPrePerPost(distCentCent);
distCentCentRatioNorm = mat2gray(distCentCentRatio);

% features
features = [time' maxIntOnLineNorm' maxIntOnLineRatioNorm' maxIntPastOnLineNorm' posMaxNorm' meanNucNorm' meanNucRatioNorm' szNucNorm' szNucRatioRatioNorm' distCentCentNorm' distCentCentRatioNorm'];



