% Sathyanarayan Rao (2022). Two dimensional Gaussian Hi-pass and Low pass Image Filter 
% (https://www.mathworks.com/matlabcentral/fileexchange/46812-two-dimensional-gaussian-hi-pass-and-low-pass-image-filter), 
% MATLAB Central File Exchange. Retrieved March 30, 2022. 

cd('/Users/jamesdavid/Documents/Winter2022/EECS 351/project/babyProject/');
X = load('Matlab/trainset.mat');
Y = load('Matlab/trainsetLabels.mat');
Mdl = fitctree(X.images,Y.labels); %works
close all;
pic = im2double(imread('IMG_6782.jpg'));
pic = im2gray(pic);

pic = pic'; %new
pic = flip(pic,1);

A = fft2(pic);
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
eimg = picx+picy;


text = imbinarize(eimg);
text = bwareaopen(imfill(text,"holes"),30);
text = bwpropfilt(text, 'Area', 200);

sw1 = 0;
nones = 0;
for row = 1:size(text,1)
    sw1 = 0;
    nones = 0;
    for col = 1:size(text,2)
        if(text(row,col))
            sw1 = 1;
            nones = nones + 1;
        elseif(sw1)
            if(nones < 10) %was 20
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
            if(nones < 10) %was 20
                text(row-nones:row,col) = 0;
            end
            sw1 = 0;
            nones = 0;
        end
    end
end

[B,L,n,A] = bwboundaries(text,'noholes');
setFigure(1,2);

% hold on;
% for i = 1:length(B)
%     bound = B{i};
%     plot(bound(:,2),bound(:,1));
% end
% hold off;
% clf;

alreadyDone = zeros(length(B),1);
aDidex = 1;
endCol = size(L,2);
col = 1;
while(col < endCol)
    col = col + 1;
    colSum = sum(text(:,col-1));
    if(colSum < 1000)
        continue;
    end
    
    maxLets = 0;
    maxCol = col-1;
    minC = col - 1 - 20;
    maxC = col - 1 + 20;
    if(col - 1 - 20 <= 0)
        minC = 1;
    end
    if(col - 1 + 20 > size(L,2))
        maxC = size(L,2);
    end
    for coln = minC:maxC
        lets = L(L(:,coln)~=0,coln);
        lets = unique(lets);
        lets = lets(lets ~= 0);
        if(length(lets) > maxLets)
            maxLets = length(lets);
            maxCol = coln;
        end
    end


    for row = size(L,1):-1:1

        if(L(row,maxCol) ~= 0 && ~ismember(L(row,maxCol),alreadyDone))
            
            bound = B{L(row,maxCol)};
            letter = poly2mask(bound(:,2),bound(:,1),size(pic,1),size(pic,2));
            picNew = pic .* letter;
            imshow(picNew);
%             letter = ~letter;
%             imshow(letter);
            axis([min(bound(:,2)) max(bound(:,2)) min(bound(:,1)) max(bound(:,1))]);
            axis off;
            set(gca,'xdir','reverse');
            set(gca,'view',[90 -90]);
            alreadyDone(aDidex) = L(row,maxCol);
            aDidex = aDidex + 1;
            1;

        end
    end
    col = maxCol;
end

