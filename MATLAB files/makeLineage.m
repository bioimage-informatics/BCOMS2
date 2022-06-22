function [ data ] = makeLineage( data )
% function [ data, divIDs, divNames, divDists ] = makeLineage( data )
%{
ƒalgorithm„
for t 
    copy NAME of preID

ƒdata type„
Input
data: c, r, z, t, 5:ID, 6:PreID, 7:dist, 8:PostID, 9:dist

Output
data: c, r, z, t, 5:ID, 6:PreID, 7:dist, 8:PostID, 9:dist, 10:Name
divIDs: t, motherID, daughterID1, daughterID2, daughterID3, ...
divNames: t, motherName, daughterName1, daughterName2, daughterName3, ...
DivisionDist: t, moterhID, dist1, dist2, dist3, ...

%}

% add NAME
data=[data, zeros([size(data,1),1])];
data(data(:,4)==1,10)=data(data(:,4)==1,5);%T=1


for t=2:max(data(:,4))
    
    % pre in thisT
    preIDCands=data(data(:,4)==t,6);
    
    % thresholding
    preIDs = preIDCands(ismember(preIDCands, data(:,5)));
    rmvdPreIDs = setdiff(preIDCands, preIDs);
    data(ismember(data(:,6), rmvdPreIDs),:)=[];
    
    % find divisions
    uniPreIDs=unique(preIDs);
    numPreIDs=arrayfun(@(x) sum(preIDs==x), uniPreIDs);
    divPreIDs=uniPreIDs(numPreIDs>=2);
    nondivPreIDs=setdiff(uniPreIDs, divPreIDs);
    
    % copy ID when no divisions
    [nowA, nowB]=ismember(data(:,6), nondivPreIDs);
    
    [preA, preB]=ismember(data(:,5), nondivPreIDs);
    nondivNameLines = data(preA,10);
    nondivNameLines = nondivNameLines(preB(preA));
    data(nowA,10)=nondivNameLines(nowB(nowA));
    
    
    % update ID when divisions
    if any(divPreIDs)
        maxPreName=max(data(:,10));
        for thisPreID=divPreIDs'
            % New ID for newly born nuclei
            divLines=ismember(data(:,6), thisPreID);
            data(divLines,10)=(maxPreName+1:maxPreName+sum(divLines))';
            
            % update maxPreName
            maxPreName=maxPreName+sum(divLines);
        end
    end
    
end


