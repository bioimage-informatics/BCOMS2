function [divIDs, divNames, divDists] = divFind(data)
%DIVFIND find divisions from data

% find divisions
uniPre = unique(nonzeros(data(:,6)));
numPre = arrayfun(@(x) sum(ismember(data(:,6), x)), uniPre);

% find pre names for each ID
preIDs = uniPre(numPre>1);
if isempty(preIDs)
    divIDs = [];
    divNames = [];
    divDists = [];
    return
end
preNames = arrayfun(@(x) data(data(:,5)==x, 10), preIDs);

% for each pre ID
postIDs = arrayfun(@(x) data(data(:,6)==x, 5)', preIDs, 'UniformOutput', false);
postNames = arrayfun(@(x) data(data(:,6)==x, 10)', preIDs, 'UniformOutput', false);
postDists = arrayfun(@(x) data(data(:,6)==x, 7)', preIDs, 'UniformOutput', false);
divTimes = arrayfun(@(x) unique(data(data(:,6)==x, 4)), preIDs);

% concatenate
if length(postIDs) > 1
    postIDs = zerocat(postIDs{:});
    postNames = zerocat(postNames{:});
    postDists = zerocat(postDists{:});
else
    postIDs = postIDs{:};
    postNames = postNames{:};
    postDists = postDists{:};
end

% divIDs, divNames, divDists
divIDs = [divTimes, preIDs, postIDs];
divNames = [divTimes, preNames, postNames];
divDists = [divTimes, preIDs, postDists];


