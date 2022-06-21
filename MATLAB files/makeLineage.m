function [ data ] = makeLineage( data )
% function [ data, divIDs, divNames, divDists ] = makeLineage( data )
%MAKELINEAGE この関数の概要をここに記述
%{
＜アルゴリズム＞
for t でpreIDのNameをコピーする

＜データ型＞
Input
TrackData昔: c, r, z, t, 5:ID, 6:PreID, 7:dist
TrackData今: c, r, z, t, 5:ID, 6:PreID, 7:dist, 8:PostID, 9:dist

Output
TrackData昔: c, r, z, t, 5:ID, 6:PreID, 7:dist, 8:Name
TrackData昔: c, r, z, t, 5:ID, 6:PreID, 7:dist, 8:PostID, 9:dist, 10:Name
Division昔: t, motherID, daughterID1, daughterID2
divIDs: t, motherID, daughterID1, daughterID2, daughterID3, ...
divNames: t, motherName, daughterName1, daughterName2, daughterName3, ...
DivisionDist: t, moterhID, dist1, dist2, dist3, ...

＜ToDo＞
T=6→7でColor3→4、4→2になてしまう→解決！
%}

% dataにName列を作成
data=[data, zeros([size(data,1),1])];
data(data(:,4)==1,10)=data(data(:,4)==1,5);%T=1はIDと同じName

% divIDs=[];
% divNames=[];
% divDists=[];
for t=2:max(data(:,4))
%     if t==102
%         t
%     end
    
    % thisTのpreを調べる
    preIDCands=data(data(:,4)==t,6);
    
    % preIDのうち、ID行に含まれていないものは、距離の閾値で除去されたので、取り除く
    preIDs = preIDCands(ismember(preIDCands, data(:,5)));
    rmvdPreIDs = setdiff(preIDCands, preIDs);
    data(ismember(data(:,6), rmvdPreIDs),:)=[];
    
    % 分裂の検出
    uniPreIDs=unique(preIDs);
    numPreIDs=arrayfun(@(x) sum(preIDs==x), uniPreIDs);
    divPreIDs=uniPreIDs(numPreIDs>=2);
    nondivPreIDs=setdiff(uniPreIDs, divPreIDs);
    
    % 分裂していない場合、IDをコピー
    [nowA, nowB]=ismember(data(:,6), nondivPreIDs);%分裂していない核がPre列に含まれるLines（Post time）
    
    [preA, preB]=ismember(data(:,5), nondivPreIDs);%分裂していない核がID列に含まれるLines（Pre time）
    nondivNameLines = data(preA,10);
    nondivNameLines = nondivNameLines(preB(preA));
    data(nowA,10)=nondivNameLines(nowB(nowA));%順番を維持して置き換えするので複雑になる
    
    
    % 分裂した場合、IDを更新する
    if any(divPreIDs)
        maxPreName=max(data(:,10));
        for thisPreID=divPreIDs'
            % 分裂後の核に新しいIDを与える
            divLines=ismember(data(:,6), thisPreID);%thisPreにつながれたLines
            data(divLines,10)=(maxPreName+1:maxPreName+sum(divLines))';
            
            % maxPreNameの更新
            maxPreName=maxPreName+sum(divLines);
        end
    end
    
end


