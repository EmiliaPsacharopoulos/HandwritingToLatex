% Sathyanarayan Rao (2022). Two dimensional Gaussian Hi-pass and Low pass Image Filter 
% (https://www.mathworks.com/matlabcentral/fileexchange/46812-two-dimensional-gaussian-hi-pass-and-low-pass-image-filter), 
% MATLAB Central File Exchange. Retrieved March 30, 2022. 

% MUST EDIT THIS LINE FOR PROJECT TO WORK
path2project = '/Users/jamesdavid/Documents/Winter2022/EECS 351/project/matlabHandwriting/';
% The above line should be changed to be whatever the path to the project
% is on your system, it MUST include a forwardslash at the end (sorry windows users it kinda assumes a unix file path
% and I'm not terribly familar with windows file paths)
% The folder with the project must include the folders "pdf" and
% "tempFolder" named EXACTLY that way

% Note: much of this could have likely been put in functions but as a
% consequence of the piecemeal way this was written there are duplicate code chunks,
% not wanting to debug anymore than necessary the code was left
% as is, poor practice yes, with a bit more time that would be the first
% major improvement to how this is written

cd(path2project);

math = 0;

close all;
switch math
    case 1
        pic = im2double(imread('math.jpeg')); % import the image and convert to double (for convolution)
    case 0
        pic = im2double(imread('IMG_6782.jpg')); % the two images that work best for this are 6785 and 6782, 6796 also works but spacing is poor
        is96 = 0; % please set this flag if using 6796, this is an issue discussed on the website, different whiteboard
        % qualities require different thresholds
end
pic = im2gray(pic); % convert to grayscale



pic = pic'; %new
pic = flip(pic,1); % these lines rotate the image sideways, since that is how the program was initially written

A = fft2(pic); % lines 22 to 37 are high pass filtering to leave only the edges for better edge detection
% Credit for this method in Matlab given at the top of the file
A1 = fftshift(A);

[M N]=size(A); % image size
R=10; % filter size parameter 
X=0:N-1;
Y=0:M-1;
[X Y]=meshgrid(X,Y);
Cx=0.5*N;
Cy=0.5*M;
Lo=exp(-((X-Cx).^2+(Y-Cy).^2)./(2*R).^2);
Hi=1-Lo;

K=A1.*Hi;
K1=ifftshift(K);
B2=ifft2(K1);

sx = [-1 0 1;-2 0 2;-1 0 1];
sy = [-1 -2 -1;0 0 0;1 2 1];
picx = abs(conv2(B2,sx));
picy = abs(conv2(B2,sy));
eimg = picx+picy; % this chunk is edge detection with the matricies given in HW7
% again we aren't using Matlab's "edge" method because it did not perform
% as well as we needed it to

text = imbinarize(eimg);
text = bwareaopen(imfill(text,"holes"),30);
text = bwpropfilt(text, 'Area', 200); % These lines convert the image to a binary
% representation and fill closed spaces (letters) and remove spaces that
% are particularly small

switch math
    case 1
        minlen = 5;
        collen = 100;
    case 0
        if(is96)
            minlen = 20;
        else
            minlen = 10;
        end
        collen = 750;
end

sw1 = 0; % these two loops are our own filters, remove particularly thin lines (scratches on the board)
nones = 0;
for row = 1:size(text,1)
    sw1 = 0;
    nones = 0;
    for col = 1:size(text,2)
        if(text(row,col))
            sw1 = 1;
            nones = nones + 1;
        elseif(sw1)
            if(nones < minlen) %was 20 10 for certain images
                text(row,col-nones:col) = 0;
            end
            sw1 = 0;
            nones = 0;
        end
    end
end

for col = 1:size(text,2)
    sw1 = 0;
    nones = 0;
    for row = 1:size(text,1)
        if(text(row,col))
            sw1 = 1;
            nones = nones + 1;
        elseif(sw1)
            if(nones < minlen) %was 20 10 for certain images
                text(row-nones:row,col) = 0;
            end
            sw1 = 0;
            nones = 0;
        end
    end
end
