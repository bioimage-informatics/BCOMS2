function h = morphologicalFeatures( segDir, morphDir, resXY, resZ, h )

% Res
matDir = [morphDir, filesep, 'MatFiles'];
mkdir(matDir);

% Load
seg = oneStackLoad(segDir);
[id, name] = cellname;

waitbar(0.2, h);

%% Single cell features
dynamicFeatureTable = calcFeatures( seg, resXY, resZ );

% Cell names
CellName = tikan(cellstr(num2str(dynamicFeatureTable.Label, '%05i')), cellstr(num2str(id, '%05i')), name);
dynamicFeatureTable = addvars(dynamicFeatureTable, CellName, 'After','Label');

% Save
savenameDynamic=[matDir, filesep, 'single_cell_features.mat'];
parsaveData(savenameDynamic, dynamicFeatureTable);

% table write
filename = [morphDir, filesep, 'single_cell_features.xlsx'];
writetable(dynamicFeatureTable, filename);

waitbar(0.5, h);

%% Inter-cell features
contactTable = calcContact(seg, morphDir, resXY, resZ);
CellName1 = tikan(cellstr(num2str(contactTable.ContactingCell1, '%05i')), cellstr(num2str(id, '%05i')), name);
CellName2 = tikan(cellstr(num2str(contactTable.ContactingCell2, '%05i')), cellstr(num2str(id, '%05i')), name);
contactTable = addvars(contactTable, CellName1, 'After','ContactingCell2');
contactTable = addvars(contactTable, CellName2, 'After','CellName1');

% Save
savenameDynamic=[matDir, filesep, 'inter_cell_features.mat'];
parsaveData(savenameDynamic, contactTable);

% table write
filename = [morphDir, filesep, 'inter_cell_features.xlsx'];
writetable(contactTable, filename);

waitbar(0.8, h);













