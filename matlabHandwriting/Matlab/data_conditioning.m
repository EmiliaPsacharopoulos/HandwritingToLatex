
% function[output]=signature(img)
input_dir = '/Users/mauramulligan/Downloads/Images/'

filenames = dir(fullfile(input_dir));

length(filenames)

images = [];
labels = [];

 
for n = 4:length(filenames)

    filename = fullfile(input_dir, filenames(n).name);
    img = imread(filename);
    img = imresize(img,[50,50]);
    img1=im2bw(img);
    %figure, imshow(img1);title('Selected Image');

    vec = img1(:)';
    images = [images; vec];
    lab = (filename(39))
    labels = [labels; lab];
   
  
end

save('/Users/mauramulligan/Downloads/Classification_of_Fruits_on_the_basis_of_Shape_using_KNN-main/trainset.mat','images');
save('/Users/mauramulligan/Downloads/Classification_of_Fruits_on_the_basis_of_Shape_using_KNN-main/trainsetLabels.mat','labels');    
   

        


    

