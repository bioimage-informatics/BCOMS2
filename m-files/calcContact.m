function contactTable = calcContact(seg, morphDir, resXY, resZ)

%% Folders
contactDataTempDir = [morphDir, 'Temp'];
mkdir(contactDataTempDir);

%% Detect contacts
% parfor t=1:size(seg,4)
for t=1:size(seg,4)
    thisStack=seg(:,:,:,t);
    uniId=nonzeros(unique(thisStack));
    allId = 1:max(uniId);
    
    if length(uniId)<2
        continue
    end
    
    % cell id along the 4th axis
    idStack = arrayfun(@(x) thisStack == x, allId, 'UniformOutput', false);
    idStack = cat(4, idStack{:});
    
    % dilation
    idDilStack = imdilate(idStack, ones(3,3,3));
    
    for u=1:length(uniId)
        % overlapping
        thisId=uniId(u);
        reg = idDilStack(:,:,:,thisId);
        over = immultiply(idDilStack, repmat(reg, [1 1 1 max(uniId)]));
        over(:,:,:,thisId) = over(:,:,:,thisId) * 0;

        % number of overlapping pixels
        overPix = arrayfun(@(x) sum(sum(sum(over(:,:,:,x), 1), 2), 3), allId);
        overVol = overPix .* resXY .* resXY .* resZ;
        
        % overlapping id
        overID = (allId(logical(overVol)))';
        overPix = nonzeros(overPix);
        overVol = nonzeros(overVol);
        
        % t -> sec
        resT = 1;% For GUI
        sec = t * resT;
        
        % renewal contacts
        n=length(overID);
        thisContactData=[repmat(t, [n,1]) repmat(sec, [n,1]) repmat(thisId, [n,1]) overID...
            overPix overVol repmat(length(uniId), [n,1])];
        
        % save temporally
        filename=[contactDataTempDir, '\T', num2str(t), '-ID', num2str(thisId), '.mat'];
        parsaveData(filename, thisContactData);
    end
end
%}

%% Data gathering
contactData=[];
idList = nonzeros(unique(seg))';
for i = idList
    for t=1:size(seg,4)
        % stack
        filename=[contactDataTempDir, '\T', num2str(t), '-ID', num2str(i), '.mat'];
        try
            thisData = oneStackLoad(filename);
        catch
            continue
        end
        contactData = [contactData; thisData];
    end
end
rmdir(contactDataTempDir, 's');

%% Add cell cycle time
uniID = unique(contactData(:, 3));
firstTime = arrayfun(@(x) min(contactData(ismember(contactData(:,3), x), 1)), uniID);
cycleTime = arrayfun(@(x) contactData(ismember(contactData(:,3), uniID(x,:)), 1) - firstTime(x) + 1,...
    1:length(uniID), 'UniformOutput', false);
normCycleTime = cellfun(@(x) x./max(x), cycleTime, 'UniformOutput', false);
normCycleTime = cat(1, normCycleTime{:});
contactData = [contactData normCycleTime];

%% Instant contact table
ContactingCell1 = contactData(:,3);
ContactingCell2 = contactData(:,4);
Timepoints = contactData(:,1);
ContactPixels = contactData(:,5);
ContactVolume = contactData(:,6);
Stage = contactData(:,7);

contactTable = table(ContactingCell1, ContactingCell2, Timepoints, ContactPixels, ContactVolume, Stage);






    