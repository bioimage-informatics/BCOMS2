function [wat, watNoFilled, nucName] = applyCytokinesisFun( nuc, nucName, nucSeg, memb, wat, div, svmModel)
%APPLYCYTOKINESISSVM 

% return not filled as well
watNoFilled = wat;

divNum = size(div, 1);
cytokinesis = div;
score=cell(divNum,1);
for i = 1:divNum

    thisNames = div(i,3:end);
    thisNucReg = ismember(nucName, thisNames);
    thisWat = ismember(wat, thisNames);
    % TPs existing in both
    exT1 = findmulti(wat == thisNames(1));
    exT1 = max(exT1(:,4));
    exT2 = findmulti(wat == thisNames(2));
    exT2 = max(exT2(:,4));
    bothT = min(exT1, exT2);
    
    thisRange = findmulti(thisWat);
    minRange = min(thisRange);
    maxRange = max(thisRange);
    maxRange(4) = max(bothT);
    
    if maxRange(4) - minRange(4) <= 1
        continue
    end
    
    thisWat = thisWat(minRange(1):maxRange(1), minRange(2):maxRange(2), minRange(3):maxRange(3), minRange(4):maxRange(4));
    thisNucReg = thisNucReg(minRange(1):maxRange(1), minRange(2):maxRange(2), minRange(3):maxRange(3), minRange(4):maxRange(4));

    % fill membrane
    thisWat = imclose(thisWat, ones(3,3,3));
    
    % nuc an membrane processing
    thisNuc = nuc(minRange(1):maxRange(1), minRange(2):maxRange(2), minRange(3):maxRange(3), minRange(4):maxRange(4));
    thisNucSeg = nucSeg(minRange(1):maxRange(1), minRange(2):maxRange(2), minRange(3):maxRange(3), minRange(4):maxRange(4));
    thisMemb = memb(minRange(1):maxRange(1), minRange(2):maxRange(2), minRange(3):maxRange(3), minRange(4):maxRange(4));
    thisNuc = immultiply(thisWat, thisNuc);
    thisNucSeg = immultiply(thisNucReg, thisNucSeg);
    thisMemb = immultiply(thisWat, thisMemb);

    % features
    features = calcCytokinesisFeaturesNew(thisNucSeg, thisNuc, thisMemb);
    [label,tempScore] = predict(svmModel,features);
    if isempty(label==1)
        pos=tempScore(:,2)==max(tempScore(:,2));
        label(pos) = 1;
    end
    score{i} = tempScore;
    
    % cytokinesis time
    divTime = find(label==1);
    fusedTime = find(label==-1, 1);
    minPostTime = min(fusedTime);
    fusedLen = divTime(divTime > minPostTime);
    if isempty(fusedLen)
        continue
    end
    fusedLen = fusedLen(1);
    
    cytoTime = minRange(4) -1 + fusedLen;
    cytokinesis(i,1) = cytoTime;
    
    watNoFilled(:,:,:,minRange(4):cytoTime) = tikan(watNoFilled(:,:,:,minRange(4):cytoTime), [div(i,3) div(i,4)], [div(i,2) div(i,2)]);
    
    wat(minRange(1):maxRange(1), minRange(2):maxRange(2), minRange(3):maxRange(3), minRange(4):cytoTime) = ...
        wat(minRange(1):maxRange(1), minRange(2):maxRange(2), minRange(3):maxRange(3), minRange(4):cytoTime) .* ...
        ~thisWat(:,:,:,1:fusedLen) + thisWat(:,:,:,1:fusedLen) * div(i,2);
    
    nucName(:,:,:,minRange(4):cytoTime) = tikan(nucName(:,:,:,minRange(4):cytoTime), [div(i,3) div(i,4)], [div(i,2) div(i,2)]);
end
