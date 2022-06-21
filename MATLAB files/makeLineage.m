function [ data ] = makeLineage( data )
% function [ data, divIDs, divNames, divDists ] = makeLineage( data )
%MAKELINEAGE ���̊֐��̊T�v�������ɋL�q
%{
���A���S���Y����
for t ��preID��Name���R�s�[����

���f�[�^�^��
Input
TrackData��: c, r, z, t, 5:ID, 6:PreID, 7:dist
TrackData��: c, r, z, t, 5:ID, 6:PreID, 7:dist, 8:PostID, 9:dist

Output
TrackData��: c, r, z, t, 5:ID, 6:PreID, 7:dist, 8:Name
TrackData��: c, r, z, t, 5:ID, 6:PreID, 7:dist, 8:PostID, 9:dist, 10:Name
Division��: t, motherID, daughterID1, daughterID2
divIDs: t, motherID, daughterID1, daughterID2, daughterID3, ...
divNames: t, motherName, daughterName1, daughterName2, daughterName3, ...
DivisionDist: t, moterhID, dist1, dist2, dist3, ...

��ToDo��
T=6��7��Color3��4�A4��2�ɂȂĂ��܂��������I
%}

% data��Name����쐬
data=[data, zeros([size(data,1),1])];
data(data(:,4)==1,10)=data(data(:,4)==1,5);%T=1��ID�Ɠ���Name

% divIDs=[];
% divNames=[];
% divDists=[];
for t=2:max(data(:,4))
%     if t==102
%         t
%     end
    
    % thisT��pre�𒲂ׂ�
    preIDCands=data(data(:,4)==t,6);
    
    % preID�̂����AID�s�Ɋ܂܂�Ă��Ȃ����̂́A������臒l�ŏ������ꂽ�̂ŁA��菜��
    preIDs = preIDCands(ismember(preIDCands, data(:,5)));
    rmvdPreIDs = setdiff(preIDCands, preIDs);
    data(ismember(data(:,6), rmvdPreIDs),:)=[];
    
    % ����̌��o
    uniPreIDs=unique(preIDs);
    numPreIDs=arrayfun(@(x) sum(preIDs==x), uniPreIDs);
    divPreIDs=uniPreIDs(numPreIDs>=2);
    nondivPreIDs=setdiff(uniPreIDs, divPreIDs);
    
    % ���􂵂Ă��Ȃ��ꍇ�AID���R�s�[
    [nowA, nowB]=ismember(data(:,6), nondivPreIDs);%���􂵂Ă��Ȃ��j��Pre��Ɋ܂܂��Lines�iPost time�j
    
    [preA, preB]=ismember(data(:,5), nondivPreIDs);%���􂵂Ă��Ȃ��j��ID��Ɋ܂܂��Lines�iPre time�j
    nondivNameLines = data(preA,10);
    nondivNameLines = nondivNameLines(preB(preA));
    data(nowA,10)=nondivNameLines(nowB(nowA));%���Ԃ��ێ����Ēu����������̂ŕ��G�ɂȂ�
    
    
    % ���􂵂��ꍇ�AID���X�V����
    if any(divPreIDs)
        maxPreName=max(data(:,10));
        for thisPreID=divPreIDs'
            % �����̊j�ɐV����ID��^����
            divLines=ismember(data(:,6), thisPreID);%thisPre�ɂȂ��ꂽLines
            data(divLines,10)=(maxPreName+1:maxPreName+sum(divLines))';
            
            % maxPreName�̍X�V
            maxPreName=maxPreName+sum(divLines);
        end
    end
    
end


