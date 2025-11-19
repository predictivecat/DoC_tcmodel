y_list = [ 0  -40    0   -40     0    0.075   0  0   -1   0;...
          20    0   40    0     40   0.14   1  1   1   1];
y_name = {'Gee' 'Gei' 'Gese' 'Gesre' 'Gsrs' 'alpha' 'beta' 'cortico-thalamic delay' 'EMG' 'X' 'Y' 'Z' 'chi-square'};

options.bandNames = {''};
options.groupNames = {'HC', 'MCS','UWS'};
options.comparisonType = 2;
options.normalize = 0;

for j =1:13
    options.measureName = y_name{j};
    displayDistributionPlots(options,fit_param(:,j),fit_param_mcs(:,j),fit_param_uws(:,j))
end

%%

% Get group 1 from the matrix
group1 = liber(indicesuws, [9:19]);

% Get the indices for group 2 by excluding group1_indices
group2_indices = setdiff(1:size(liber, 1), indicesuws);

% Get group 2 from the matrix
group2 = liber(group2_indices, [9:19]);

options.bandNames = {'x', 'y', 'z' ,'x-y','x+y'};
options.groupNames = {'suc', 'fail','hc'};
options.comparisonType = 2;
options.normalize = 0;
displayDistributionPlots(options,group1,group2,xyz);

for i=1:10
    figure; loglog(f_real,fitlin(i,:));
end