function cent = stack2Cent( segStack, resXY, resZ )
%STACK2CENT stack��cent�̃f�[�^�ɂ���

% ���S���W�̌��o
s=regionprops(segStack,'Centroid');
cent = cat(1, s.Centroid);%c, r, z, t
if size(cent, 2)==4
    % cent=[cent(:,1)*resXY,cent(:,2)*resXY,cent(:,3)*resZ,cent(:,4), (1:size(cent,1))', (1:size(cent,1))'];%c, r, z, t, id, id(NewId)
    cent=[cent(:,1)*resXY,cent(:,2)*resXY,cent(:,3)*resZ,cent(:,4), (1:size(cent,1))'];%�ύX20150712 c, r, z, t, id
elseif size(cent, 2)==3
    cent=[cent(:,1)*resXY,cent(:,2)*resXY,cent(:,3)*resZ, (1:size(cent,1))'];%�ύX20150805 c, r, z, id
end
%�������ꂽ�j��ID��NaN�ɂȂ��Ă���̂ŁA���̍s������
nanLines=logical(sum(isnan(cent),2));
cent(nanLines, :)=[];

