function [ data ] = nnOneMul( data, threDist )
% Nearest neighbor from post to pre


point1=double(data);
point2=double(data);

point1R = point1(:,1);
point1C = point1(:,2);
point1Z = point1(:,3);
point1T = point1(:,4);
point2R = point2(:,1);
point2C = point2(:,2);
point2Z = point2(:,3);
point2T = point2(:,4);

[mesh1R,mesh2R]=meshgrid(point1R,point2R);
[mesh1C,mesh2C]=meshgrid(point1C,point2C);
[mesh1Z,mesh2Z]=meshgrid(point1Z,point2Z);


diffR = (mesh1R - mesh2R).^2;
diffC = (mesh1C - mesh2C).^2;
diffZ = (mesh1Z - mesh2Z).^2;

diff = sqrt(diffR + diffC + diffZ);
% diff matrix is 
%           point1
%         ---------->
%        |
% point2 |
%        |
%        V

% INF for different TPs
% from post to pre
point2Tsub = point2T -1;
[mesh1T,mesh2T]=meshgrid(point1T,point2Tsub);
diff21T = (mesh1T - mesh2T).^2;
diff21T(diff21T~=0)=Inf;
diff21T(diff21T==0)=1;

diff21 = diff .* diff21T;
diff21(logical(eye(size(diff21)))) = Inf;

diff21(diff21>threDist) = Inf;

% from pre to post
point1Tsub = point1T -1;
[mesh1T,mesh2T]=meshgrid(point1Tsub,point2T);
diff12T = (mesh2T - mesh1T).^2;
diff12T(diff12T~=0)=Inf;
diff12T(diff12T==0)=1;

diff12 = diff .* diff12T;
diff12(logical(eye(size(diff12)))) = Inf;

diff12(diff12>threDist) = Inf;

% nearest21: point2 -> point1
[val21,r] = min(diff21,[],2);%c is the column position of minimum value in each row.
oriPoint1Id = point1(:,5);
data=[data, oriPoint1Id(r), val21];
% thresholding
withinThresh = ~isinf(val21);
timeOneLines = data(:,4) == min(data(:,4));
okLines = logical(withinThresh + timeOneLines);
data = data(okLines,:);
% T=1
data(data(:,4)==1,6)=0;
data(data(:,4)==1,7)=0;

% nearest12: point1 -> point2
[val21,r] = min(diff12,[],2);%c is the column position of minimum value in each row.
oriPoint1Id = point1(:,5);
data=[data, oriPoint1Id(r), val21];
% thresholding
withinThresh = ~isinf(val21);
timeEndLines = data(:,4) == max(data(:,4));
okLines = logical(withinThresh + timeEndLines);
data = data(okLines,:);
% T=1‚Ìˆ—
data(data(:,4)==max(data(:,4)),8)=0;
data(data(:,4)==max(data(:,4)),9)=0;
