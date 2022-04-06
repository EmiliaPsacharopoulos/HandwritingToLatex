
% insert folder path containing handwriting data
input_dir = '/Users/mauramulligan/Downloads/Images/'

filenames = dir(fullfile(input_dir));

length(filenames)

images = [];
labels = [];

% condition and resize each image 
for n = 4:length(filenames)

    filename = fullfile(input_dir, filenames(n).name);
    img = imread(filename);
    img = imresize(img,[50,50]);
    img1=im2bw(img);
    %figure, imshow(img1);title('Selected Image');

    % unwrap image and append to data matrices
    vec = img1(:)';
    images = [images; vec];
    lab = (filename(39))
    labels = [labels; lab];
   
  
end

% save the data to be accessed in other scripts
save('/Users/mauramulligan/Downloads/trainset.mat','images');
save('/Users/mauramulligan/Downloads/trainsetLabels.mat','labels');    
   

        


    

