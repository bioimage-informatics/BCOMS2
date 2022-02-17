function h = waterMembrane( membImgDir, nucValDir, embRegDir, membSegDir, resXY, resZ, h )

%% Folders
% Temp folders
waterStackTempDir = [membSegDir, filesep, 'SegmentationTemp'];
mkdir(waterStackTempDir);
waterScoreTempDir = [membSegDir, filesep, 'ScoreTemp'];
mkdir(waterScoreTempDir);

% Result folders
waterStackDir = [membSegDir, filesep, 'Cell'];
mkdir(waterStackDir);
waterLabelDir = [membSegDir, filesep, 'CellLabel'];
mkdir(waterLabelDir);
waterMembDir = [membSegDir, filesep, 'Membrane'];
mkdir(waterMembDir);
matStackDir = [membSegDir, filesep, 'MatFile'];
mkdir(matStackDir);

% waitbar
waitbar(0.2, h);

%% Load data
memb = oneStackLoad(membImgDir);

nuc = oneStackLoad(nucValDir);
nuc=double(nuc);

embReg=oneStackLoad(embRegDir);
embReg=double(logical(embReg));

% Conditions
ratio=round(resZ/resXY);
[~,~,~,tLen] = size(memb);
tList = 1:tLen;

%% Pre-processing
% label nuc
oriEmbReg = embReg;
% lab = bwconncomp(nuc, 26);
% lab = labelmatrix(lab);
% lab = double(lab);

% All nuclei enclosed in the embryoni region?
if ~isempty(setdiff(nonzeros(nuc), nonzeros(immultiply(nuc, embReg))))
    error('EmbReg is too small')
end

% Size
ind = find(embReg);
[out{1:ndims(embReg)}] = ind2sub(size(embReg), ind);
embInd = cell2mat(out);
embIndMin = min(embInd(:,3));
embIndMax = max(embInd(:,3));

% smallmb
okFlagSmallWhole = 0;
for i=3:-1:1
    smallEmbRegWhole = imerode(embReg,ones(2*i+1, 2*i+1, 2*(i-1)+1));
    smallEmbRegWhole(:,:,embIndMin,:) = 0; % For edge 
    smallEmbRegWhole(:,:,embIndMax,:) = 0; % For edge 
    nucSmall = immultiply(nuc, smallEmbRegWhole);
    if isempty(setdiff(nonzeros(nuc), nonzeros(nucSmall)))
        okFlagSmallWhole = 1;
        break
    end
end
if okFlagSmallWhole
    nucSmall = immultiply(nuc, logical(nucSmall));
else
    nucSmall = nuc;
    smallEmbRegWhole = embReg;
end
% Deeper regions
okFlagSmall = 0;
for i=3:-1:1
    smallEmbReg = smallEmbRegWhole;
    smallEmbReg(:,:,1:7,:) = 0;
    nucSmall = immultiply(nuc, smallEmbReg);
    if isempty(setdiff(nonzeros(nuc), nonzeros(nucSmall)))
        okFlagSmall = 1;
        break
    end
end
if okFlagSmall
    nucSmall = immultiply(nucSmall, logical(nucSmall));
else
    smallEmbReg = smallEmbRegWhole;
end

% Remove rubbish
gomiT = min(10, tLen);
sampleStack = embReg(:,:,:,1:gomiT);
embArea = sum(sampleStack(:)) / gomiT;
embReg = bwareaopen(embReg, round(embArea*0.1), 26);
smallEmbReg = bwareaopen(smallEmbReg, round(embArea*0.1),26);

% Distance transform
dNuc = ratioDst( logical(nuc), ratio, 3 );
dNuc(isinf(dNuc))=1;
dNuc=immultiply(double(dNuc),smallEmbReg);
dNuc=mat2gray(dNuc);

waitbar(0.3, h);

%% Watershed

% alphas=0:0.1:0.3; % if alphas are evaluated
alphas=0;

% parfor a=1:length(alphas)
for a=1:length(alphas)
    alpha=alphas(a);
    
    % sum with distTransform
    merge=memb;
    merge=mat2gray(merge);
    merge=merge+alpha*dNuc;
    merge=mat2gray(merge);
    
    % 1st trial with the small embReg ----------
    range = getrangefromclass(merge);
    merge(~smallEmbReg)=range(2);
    % nucleui as minimums
    merge=imimposemin(merge,logical(nucSmall),26);
    % watershed
    watSmall=watershed(merge,26);
    watSmall=immultiply(double(watSmall),smallEmbReg);
    
    waitbar(0.4, h);
    
    % Re-try with the actual embReg ---------
    dStack = ratioDst( watSmall, ratio, 3 );
    dStack=mat2gray(dStack);
    dStack(~embReg)=range(2);
    % nucleui as minimums
    dStack=imimposemin(dStack,logical(watSmall),26);
    % watershed
    watTrue=watershed(dStack,26);
    watTrue=immultiply(double(watTrue),embReg);
    
    waitbar(0.5, h);
    
    % Nucleus IDs (colors) are used for those of cells
    conv = unique([watTrue(logical(nucSmall)) nucSmall(logical(nucSmall))], 'rows');
    zeroLines = any(conv==0, 2);
    conv = conv(~zeroLines, :);
    if ~isequal(unique(nonzeros(watTrue(logical(nucSmall)))), conv(:,1))
        error
    end
    seg=tikan(watTrue, conv(:,1), conv(:,2));
    
%     % Apply cytokinesis % if needed
%     if ~isempty(varargin)
%         [seg, noFilled, newNuc] = applyCytokinesisFun( nucImg, nuc, nucSeg, oriMemb, seg, div, svmModel);
%     else
%         newNuc = nuc;
%         noFilled = seg;
%     end
    
    membStack = logical(imdilate(logical(seg),ones(3,3,3)) - logical(seg));
    membOver=immultiply(memb, membStack);
    membRevOver=immultiply(memb, ~membStack);
    
    % Average of non-zero pixels
    membOverMean = arrayfun(@(x) mean(nonzeros(membOver(:,:,:,x))), 1:size(membOver, 4));
    memRevbOverMean = arrayfun(@(x) mean(nonzeros(membRevOver(:,:,:,x))), 1:size(membRevOver, 4));
    
    % s/n
    membOverSN = membOverMean./memRevbOverMean;
    
    % Number of missed nuclei
    missedNum = arrayfun(@(x) length(setdiff(unique(nonzeros(nuc(:,:,:,x))), unique(nonzeros(seg(:,:,:,x))))), 1:tLen);
    
    % score
    score =  [tList', repmat(alpha, [length(membOverSN) 1]), membOverSN', missedNum'];
    
    % save
    filename = [waterStackTempDir, filesep, num2str(alpha), '.mat'];
    parsaveStack(filename, seg);
    filename = [waterScoreTempDir, filesep, num2str(alpha), '.mat'];
    parsaveScore(filename, score);
end

%% Score load
score = [];
for a=1:length(alphas)
    alpha=alphas(a);
    filename = [waterScoreTempDir, filesep, num2str(alpha), '.mat'];
    thisScore = load(filename);
    thisScore = thisScore.score;
    alpha = thisScore(1,2);
    meanOver = mean(thisScore(:,3));
    numMissed = sum(thisScore(:,4));

    score = [score; alpha, meanOver, numMissed];
end

%% Apply constraints
% missed nuclei
numMissedThre = 0;
score = score(score(:,3) == numMissedThre,:);

%% Evaluate the objective function
% Optimal alpha
objCol = 2;
score = sortrows(score, objCol, 'descend');
minAlpha = score(end,1);

% Load
filename = [waterStackTempDir, filesep, num2str(minAlpha), '.mat'];
stack = oneStackLoad(filename);

rmdir(waterStackTempDir, 's');
rmdir(waterScoreTempDir, 's');

% waitbar
waitbar(0.9, h);

%% Save
stackWrite(stack, waterLabelDir);
stackWrite(logical(stack), waterStackDir);

filename = [matStackDir, filesep, 'cell.mat'];
parsaveStack(filename, stack)

% Only Membrane
stack = imerode(stack, ones(3,3,3));
memb = logical(immultiply(oriEmbReg, ~logical(stack)));
memb(:,:,1,:) = bwperim(memb(:,:,1,:), 8);
memb(:,:,end,:) = bwperim(memb(:,:,end,:), 8);
memb(:,:,1,:) = memb(:,:,1,:) * 0;
memb(:,:,end,:) = memb(:,:,end,:) * 0;
stackWrite(memb, waterMembDir);

