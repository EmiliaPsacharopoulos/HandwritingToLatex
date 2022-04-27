function [prediction1, prediction2] = predict_letter(image1, image2)

    % NEURAL NETWORK (87% accuracy)
    % format: [28x28], inverted grayscale (white writing on black background)
    % file(s): nnpredict.py, lenet.py, model.pth in same directory
    % python setup: (1) pyenv("ExecutionMode","OutOfProcess")
    %               (2) py.importlib.import_module('nnpredict')
    %               * run this before running or calling the function 
    
    image1 = image1/max(image1(:));    % normalize
    image2 = image2/max(image2(:));    % normalize
%     imshow(image);
    image2 = image2';                 % transpose
    
    py.importlib.import_module('numpy');
    prediction1 = py.nnpredict_hasy.predict_letter(py.numpy.array(image1));
    prediction2 = py.nnpredict.predict_letter(py.numpy.array(image2));
    
    
%     % DECISION TREE MODEL (67% accuracy at best)
%     % format: [1 x 784 double] (28x28 unwraped), inverted grayscale
%
%     % check if loads already exist
%     if exist('emnist', 'var') == 0    
%         emnist = load('matlab/emnist-byclass.mat');
%         disp('reloading emnist')
%     end
%     
%     if exist('model', 'var') == 0  
%         model = load('tree_emnist.mat');
%         disp('reloading model')
%     end
%     
%     pred = predict(model.Mdl, image);
%     prediction = char(emnist.dataset.mapping(pred+1,2));
    
end

