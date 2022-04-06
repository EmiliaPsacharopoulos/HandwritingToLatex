cd('/Users/jamesdavid/Downloads/Matlab')
X = load('trainset.mat');
Y = load('trainsetLabels.mat');
labels = [];

% Mdl = fitcknn(X.images,Y.labels,'NumNeighbors',5,'Standardize',1); %works
% Mdl = fitcnb(X.images,Y.labels); % doesn't work probably because sample size too small
Mdl = fitctree(X.images,Y.labels); %works
% Mdl = fitcsvm(X.images,Y.labels); %only works for binary

correct = 0;
for n = 1:length(Y.labels)
    label = predict(Mdl, X.images(n, :));
    labels = [labels ; label];
    if Y.labels(n) == label
       correct = correct + 1; 
    end
    
end

perc = correct / length(Y.labels);

figure;
cm = confusionchart(Y.labels,labels)
title("K-Nearest Neighbor: " + num2str(perc*100) + "% Accuracy");