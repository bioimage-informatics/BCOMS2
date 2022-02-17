function h = embryonicRegion(membImg, nucValDir, zRangeDir, embRegDir, volRatioThresh, h)

mkdir(embRegDir);

embRegStackTempDir=[embRegDir, filesep, 'StackTemp'];
mkdir(embRegStackTempDir);
embRegStackDir=[embRegDir, filesep, 'Stack'];
mkdir(embRegStackDir);

% Membrane
memb=oneStackLoad(membImg);

% Nucleus
nuc=oneStackLoad(nucValDir);
nuc = logical(nuc);

% Z range
zrange = oneStackLoad([zRangeDir, filesep, 'zRange.mat']);
zList = zrange(1):zrange(2);

% nuc existing times
nucPix = idxN(nuc);
if ndims(nuc) >= 4
    tList = min(nucPix(:,4)):max(nucPix(:,4));
else
    tList = 1;
end

% size
[r,c,zNum_ori,~]=size(memb);
tNum = max(tList);

% initial contour
for i = 1:10
    sumMemb = sum(memb, 4);
    sumMembDenoise = imgaussfilt(sumMemb, 6);
    meanInt = mean(sumMembDenoise(:));
    mask = sumMembDenoise > meanInt - (meanInt * 0.1*(i-1));

    mask = reshape(mask, [r, c*zNum_ori]);
    imgReshape = reshape(sumMembDenoise, [r, c*zNum_ori]);

    smooth=0.05;
    contBias=0.01;
    repeatTime = 100;

    mask=activecontour(imgReshape, mask,repeatTime,'Chan-Vese' ,'SmoothFactor',smooth, 'ContractionBias',contBias);
    mask = reshape(mask, [r, c, zNum_ori]);
    mask = imdilate(mask, ones(7,7));

    % initial contour evaluation
    outNuc = immultiply(~mask, sum(nuc, 4));
    if max(outNuc(:)) == 0
        break
    end
end
iniReg = repmat(mask, [1 1 1 tNum]);

% Erode nudleus but no nucleus removed totally
nucErd = imerode(nuc, ones(5,5,5));
if ~isequal(unique(nonzeros(nuc)), unique(nonzeros(nucErd)))
    nucErd = imerode(nuc, ones(3,3,3));
    if ~isequal(unique(nonzeros(nuc)), unique(nonzeros(nucErd)))
        nucErd = nuc;
    end
end

% Apply restriction of Z and T
memb = memb(:,:,zList,tList);
nucErd = nucErd(:,:,zList,tList);
iniReg = iniReg(:,:,zList);
iniReg = repmat(iniReg, [1 1 1 length(tList)]);
zNum = length(zList);

if isnan(volRatioThresh)
    filename = [embRegStackDir, filesep, 'embrayonicRegion.mat'];
    parsaveStack(filename, iniReg);
    return
end

% Normalize for score calculation
membNorm = reshape(memb, [r, c, zNum*tNum]);
means = arrayfun(@(x) mean(reshape(membNorm(:,:,x), [r*c, 1])), 1:size(membNorm,3));
means = means / mean(means);
membNorm = arrayfun(@(x) membNorm(:,:,x) / means(x), 1:size(membNorm,3), 'UniformOutput', false);
membNorm = cat(3, membNorm{:});
membNorm = reshape(membNorm, [r, c, zNum, tNum]);
membNorm = membNorm / max(membNorm(:));

% Normalize Z
means = arrayfun(@(x) mean(reshape(memb(:,:,x,:), [r*c*tNum, 1])), 1:size(memb,3));
means = means / mean(means);
means(means==0) = 0.0001;
memb = arrayfun(@(x) memb(:,:,x,:) / means(x), 1:size(memb,3), 'UniformOutput', false);
memb = cat(3, memb{:});
memb = memb / max(memb(:));

vars = arrayfun(@(x) var(reshape(memb(:,:,:,x), [r*c*zNum, 1])), 1:size(memb,4));
vars = vars / mean(vars);
if isnan(vars)
    vars = 1;
end

% Parameters
smooth=0.5;
contBiasFactorA = [0.03 0.05:0.05:0.2];
contBiasFactorB=[4 6 8 10 12];
repeatFactor=100;
erdSz = [1 3 5];
% Score
score = {};
paramLength = length(contBiasFactorA) * length(contBiasFactorB) * length(repeatFactor);

% parfor t=1:tNum
for t=1:tNum
    thisMemb = memb(:,:,:,t);
    % Gaussian filter
    thisMemb=imgaussfilt3(thisMemb, 1);
    tempScore = zeros(paramLength, 8);
    repeatFactorUpdated = repeatFactor;
    thisMembNorm = membNorm(:,:,:,t);
    thisNucErd = nucErd(:,:,:,t);
    i = 0;
    for ca=contBiasFactorA
        for cb=contBiasFactorB
            contBias = ca * vars(t).^cb;
            for rf = repeatFactorUpdated
                membReg = zeros(r,c,zNum);
                parfor z = 1:zNum
%                 for z = 1:zNum % if parfor is not available
                    thisMemb2D = thisMemb(:,:,z);
                    thisIniReg2D = iniReg(:,:,z,t);
                    thisMean = mean(thisMemb2D(:));
                    thisStd = std(thisMemb2D(:));
                    thisCC = thisStd / thisMean;
                    if isnan(thisCC)
                        thisCC = 1;
                    end
                    thisSmooth = smooth / thisCC^2;
                    thisContBias = contBias / thisCC^2;
                    thisRf = round(rf * thisCC);
                    % Level set
                    membReg2D=activecontour(thisMemb2D, thisIniReg2D,thisRf,'Chan-Vese' ,'SmoothFactor',thisSmooth, 'ContractionBias',thisContBias);
                    membReg(:,:,z) = membReg2D;
                end
                for er = erdSz
                    i = i + 1;
                    membReg = imerode(membReg, ones(er, er));
                    % optimization
                    peri = bwperim(logical(membReg), 8);
                    if max(peri(:)) == 0
                        overVal = 0;
                    else
                        embRegOver=immultiply(thisMembNorm, peri);%Evaluation on the original image
                        overVal = mean(nonzeros(embRegOver));
                    end
                    % vol
                    vol = sum(membReg(:));
                    % 1 if all nuclei enclosed
                    membReg = reshape(membReg, r, c, zNum);
                    nucOver = immultiply(thisNucErd, ~membReg);
                    if max(nucOver(:)) == 1
                        nucCoveredFlag = 0;
                    else
                        nucCoveredFlag = 1;
                    end

                    % Score
                    tempScore(i, :) = [t ca cb rf er overVal vol nucCoveredFlag];
                    % save
                    filename = [embRegStackTempDir, filesep, 'T', num2str(t), 'CA', num2str(ca), 'CB', num2str(cb), 'RF', num2str(rf), 'ER', num2str(er), '.mat'];
                    parsaveStack(filename, membReg);
                end
            end
        end
        score{t} = tempScore;
    end
    waitbar(0.1 + 0.8*t/tNum, h);
end

%% Find optimal parameters
% Average through the time
scoreStack = cat(3, score{:});
meanScore = mean(scoreStack, 3);
minScore = min(scoreStack, [], 3);
maxScore = max(scoreStack, [], 3);
ratioScore = minScore ./ maxScore;

% Constraints
% Volume consistency
volRatioCol = 7;
meanScore = meanScore(ratioScore(:,volRatioCol) >= volRatioThresh,:);

objCol = 6;
meanScore = sortrows(meanScore, objCol, 'descend' );

% Finish if no satisaction
if isempty(meanScore)
    h = msgbox('No segmentation result satisfied the volume ratio constraint');
    return
end

%% Recalculation on the optimal parameters
% Parameters
caOpt=meanScore(1,2);
cbOpt=meanScore(1,3);
rfOpt=meanScore(1,4);
optEr=meanScore(1,5);

embOpt = zeros(r,c,zNum_ori, tNum);
for t = 1:tNum
    filename = [embRegStackTempDir, filesep, 'T', num2str(t), 'CA', num2str(caOpt), 'CB', num2str(cbOpt), 'RF', num2str(rfOpt), 'ER', num2str(optEr), '.mat'];
    embOpt(:,:,zList,t) = oneStackLoad(filename);
end

% waitbar
waitbar(0.9, h);

% save
filename = [embRegStackDir, filesep, 'embrayonicRegion.mat'];
parsaveStack(filename, embOpt);

rmdir(embRegStackTempDir, 's')

