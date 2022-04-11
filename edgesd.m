% Sathyanarayan Rao (2022). Two dimensional Gaussian Hi-pass and Low pass Image Filter 
% (https://www.mathworks.com/matlabcentral/fileexchange/46812-two-dimensional-gaussian-hi-pass-and-low-pass-image-filter), 
% MATLAB Central File Exchange. Retrieved March 30, 2022. 

cd('/Users/jamesdavid/Documents/Winter2022/EECS 351/project/matlabHandwriting/');

% emnist = load('Matlab/emnist-byclass.mat');
% model = load('Matlab/tree_emnist.mat');

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
outputString = "";
while(col < endCol)
    col = col + 1;
    colSum = sum(text(:,col));
    if(colSum < 750)
        continue;
    end
    maxLets = 0;
    maxCol = col;
    minC = col - 0;
    maxC = col + 50;
    if(col - 0 <= 0)
        minC = 1;
    end
    if(col + 20 > size(L,2))
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
    
    firstLet = 1;
    prevRow = size(L,1);
    for row = size(L,1):-1:1

        if(L(row,maxCol) ~= 0 && ~ismember(L(row,maxCol),alreadyDone))
            if(firstLet)
                outputString = append(outputString," \\newline ");
            end
            bound = B{L(row,maxCol)};
            letter = poly2mask(bound(:,2),bound(:,1),size(pic,1),size(pic,2));
            picNew = pic .* letter;
            picNew(picNew == 0) = 0.75;
            imshow(picNew);
%             letter = ~letter;
%             imshow(letter);
            axis([min(bound(:,2)) max(bound(:,2)) min(bound(:,1)) max(bound(:,1))]);
            axis off;
            set(gca,'xdir','reverse');
            set(gca,'view',[90 -90]);
            alreadyDone(aDidex) = L(row,maxCol);
            aDidex = aDidex + 1;
            saveas(gcf,'/Users/jamesdavid/Documents/Winter2022/EECS 351/project/matlabHandwriting/tempFolder/current.png');
            let = im2gray(im2double(imread('/Users/jamesdavid/Documents/Winter2022/EECS 351/project/matlabHandwriting/tempFolder/current.png')));
            let(let == 1) = 0.75;
            let = imcomplement(let);
            let = imresize(let,[28 28]);
            let = let(:)';
%             pred = predict(model.Mdl, let);
%             label = char(emnist.dataset.mapping(pred+1,2));
            label = py.nnpredict.predict(let);
            outputString = append(outputString,label);
            if(prevRow - row > 250)
                outputString = append(outputString," ");
            end
            prevRow = row;
            firstLet = 0;
            1;
            
        end
    end
    col = maxCol;
end
outputString = extractBetween(outputString,12,strlength(outputString));

study_home = '/Users/jamesdavid/Documents/Winter2022/EECS 351/project/matlabHandwriting/pdf/';


cd(study_home);


SAVE_FIGURES = 2;
OPEN_FIGURES = 0;

this_latex_file_namepath = [study_home,'output.tex'];
outputLatex = fopen(this_latex_file_namepath,'w');
if outputLatex>2

    fprintf(outputLatex, '\\documentclass[11pt]{article}\n');
    fprintf(outputLatex, '\\usepackage[margin=0.5in]{geometry}\n');
    fprintf(outputLatex, '\\geometry{letterpaper}\n');
    fprintf(outputLatex, '%%\\geometry{showframe}\n');
    fprintf(outputLatex, '\\usepackage[parfill]{parskip}    %% Activate to begin paragraphs with an empty line\n');
    fprintf(outputLatex, '\\usepackage{graphicx}\n');
    fprintf(outputLatex, '\\usepackage{xcolor}\n');
    fprintf(outputLatex, '\\usepackage{amssymb}\n');
    fprintf(outputLatex, '\\usepackage{float}\n');
    fprintf(outputLatex, '\\usepackage{epstopdf}\n');
    fprintf(outputLatex, '\\usepackage{hyperref}\n');
    fprintf(outputLatex, '\\hypersetup{\n');
    fprintf(outputLatex, '    colorlinks=true, %%set true if you want colored links\n');
    fprintf(outputLatex, '    linktoc=all,     %%set to all if you want both sections and subsections linked\n');
    fprintf(outputLatex, '    linkcolor=blue  %%choose some color if you want links to stand out\n');
    fprintf(outputLatex, '}\n');
    fprintf(outputLatex, '\n');
    fprintf(outputLatex, '\\DeclareGraphicsRule{.tif}{png}{.png}{`convert #1 `dirname #1`/`basename #1 .tif`.png}\n');
    fprintf(outputLatex, '\n');
    fprintf(outputLatex, '\\title{Winter 2022 Final Project}\n');
    fprintf(outputLatex, '\\author{Group 6}\n\n');
    fprintf(outputLatex, '\\begin{document}\n');
    fprintf(outputLatex, '\\maketitle\n');

    fprintf(outputLatex, '\\tableofcontents');
    fprintf(outputLatex, '\\newpage');

    for scanNo=[1]% Chapters

        fprintf(outputLatex, '\\newpage\n');
        fprintf(outputLatex, '%% Chapter %d\n', scanNo);
        fprintf(outputLatex, '\\section{Output from classifier}\n');
        fprintf(outputLatex, '\\label{section%d}\n', scanNo);

        fprintf(outputLatex, '\\subsection{Output}\n');
        fprintf(outputLatex, '\\label{Sec%d_L2_Introduction}\n',scanNo);

        fprintf(outputLatex, outputString);
        
        %
        % trim command: left, bottom, right, top
        %


    end % of for-loop over all subjects

    % %
    %
    % End Document
    %
    fprintf(outputLatex, '\\end{document}\n\n');

    %
    % now read the entire file and replace all underscores within quotation
    % marks with '\_' to avoid the subscripts.  
    %
    fclose(outputLatex);
    outputLatex = fopen(this_latex_file_namepath,'r');
    allLaTeXText = fread(outputLatex, inf, '*char');
    fclose(outputLatex);

    numReplacements = 0;
    Qopen = 1==0;
    for qwe=1:numel(allLaTeXText)
        if (allLaTeXText(qwe)=='$') && (allLaTeXText(qwe+1)=='"')
            Qopen = ~Qopen;
        elseif (allLaTeXText(qwe)=='"') && (allLaTeXText(qwe+1)=='$')
            Qopen = ~Qopen;
        elseif (allLaTeXText(qwe)=='_') && Qopen
            numReplacements = numReplacements + 1;
        end
    end

    newLaTeXText = char(zeros(numel(allLaTeXText)+numReplacements,1,'int8'));
    Qopen = 1==0; asd=1;
    for qwe=1:numel(allLaTeXText)
        if (allLaTeXText(qwe)=='$') && (allLaTeXText(qwe+1)=='"')
            Qopen = ~Qopen;
        elseif (allLaTeXText(qwe)=='"') && (allLaTeXText(qwe+1)=='$')
            Qopen = ~Qopen;
        elseif (allLaTeXText(qwe)=='_') && Qopen
            numReplacements = numReplacements + 1;
            newLaTeXText(asd) = '\';
            asd=asd+1;
        end
        newLaTeXText(asd) = allLaTeXText(qwe);
        asd=asd+1;
    end

    outputLatex = fopen(this_latex_file_namepath,'w');
    fwrite(outputLatex, newLaTeXText);
    fclose(outputLatex);

else
    fprintf(2, 'Could not open LaTeX output file!\n');
end % of if-open LaTeX file