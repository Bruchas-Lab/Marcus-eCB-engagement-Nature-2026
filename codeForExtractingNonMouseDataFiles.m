
mkdir('CellRegData');
cd('CellRegData');

%%

A = neuron.reshape(neuron.A,2);
allFiltersMat = permute(A,[3,1,2]);
save(name,'allFiltersMat');
%mkdir(name);

clear %name neuron A allFiltersMat Cn Coor center PNR



% %% for summing up matched cells
% 
sum(~isnan(cell_registered_struct.true_positive_scores));

clear