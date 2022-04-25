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

cd(path2project);

close all;
pic = im2double(imread('IMG_6785.jpg')); % import the image and convert to double (for convolution)
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
            if(nones < 10) %was 20 10 for certain images
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
            if(nones < 10) %was 20 10 for certain images
                text(row-nones:row,col) = 0;
            end
            sw1 = 0;
            nones = 0;
        end
    end
end

[B,L,n,A] = bwboundaries(text,'noholes'); % this will find and index those closed spaces left for classification
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
    if(colSum < 750) % if a line intersectes a particularly large amount of white (letters)
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
    end % these above lines will search for a line that intersects the most unique letters, gives a better estimation of the line of letters
    
    firstLet = 1;
    prevRow = size(L,1);
    row = size(L,1);
    while(row >= 1) % now we go along the line, grabbing each letter and feeding it to classifier
        if(L(row,maxCol) ~= 0)
            if(~ismember(L(row,maxCol),alreadyDone))
                bound = B{L(row,maxCol)};
                if(max(bound(:,1)) - min(bound(:,1)) < 10)
                    alreadyDone(aDidex) = L(row,maxCol);
                    aDidex = aDidex + 1;
                    continue;
                end
                if(firstLet)
                    outputString = append(outputString," \\newline ");
                    maxAy = max(bound(:,1));
                end
                letter = poly2mask(bound(:,2),bound(:,1),size(pic,1),size(pic,2));
                picNew = pic .* letter;
                picNew(picNew == 0) = 0.75;
                imshow(picNew);
                if(abs(max(bound(:,1)) - maxAy) > 200) %was 250, 500
                    outputString = append(outputString," ");
                end
                if(min(bound(:,2)) == max(bound(:,2)))
                    maxAx = max(bound(:,2)) + 1;
                else
                    maxAx = max(bound(:,2));
                end
                
                minAx = min(bound(:,2));
    
                if(min(bound(:,1)) == max(bound(:,1)))
                    maxAy = max(bound(:,1)) + 1;
                else
                    maxAy = max(bound(:,1));
                end
    
                minAy = min(bound(:,1));
    
                %axis([minAx-20 maxAx+5 minAy-20 maxAy+20]);
                axis([minAx maxAx minAy maxAy]);
                axis off;
                set(gca,'xdir','reverse');
                set(gca,'view',[90 -90]);
                alreadyDone(aDidex) = L(row,maxCol);
                aDidex = aDidex + 1;
                saveas(gcf,[path2project, 'tempFolder/current.png']);
                let = im2bw(imread([path2project, 'tempFolder/current.png']));
    %             let = imbinarize(im2gray(imread('/Users/jamesdavid/Documents/Winter2022/EECS 351/project/matlabHandwriting/tempFolder/current.png')));
                let = imcomplement(let);
                let = imresize(let,[28 28]);
                label = predict_letter(let);

                if(strcmp(string(label),'l') || strcmp(string(label),'I') || strcmp(string(label),'1') || strcmp(string(label),'J'))
                        % here this feedback loop looks for the different
                        % parts of discontinuous symbols
                    lettop = min(bound(:,2));

                    letBounds = [min(bound(:,1)) max(bound(:,1))];

                    if(lettop - 200 < 1)
                        start = 1;
                    else
                        start = lettop - 200;
                    end
                    
                    for j = start:lettop
                        for k = letBounds(1):letBounds(2)
                            if(L(k,j) ~= 0 && ~ismember(L(k,j),alreadyDone))
                                if(strcmp(string(label),'J'))
                                    label = 'j';
                                    break;
                                else
                                    label = 'i';
                                    break;
                                end
                            end
                        end

                        if(strcmp(string(label),'j') || strcmp(string(label),'i'))
                            break;
                        end

                    end

                end

                outputString = append(outputString,string(label));
                firstLet = 0;
                1;
                row = min(bound(:,1));
            end
        else % this second loop is to account for slanting, it searches a little off our line to see if there are any nearby letters (down more than up)
            if(maxCol - 50 < 1)
                start = 1;
            else
                start = maxCol - 50;
            end
            if(maxCol + 100 > size(text,2))
                ed = size(text,2);
            else
                ed = maxCol + 100;
            end
            for i = start:ed
                if(L(row,i) ~= 0 && ~ismember(L(row,i),alreadyDone))
                    bound = B{L(row,i)};
                    if(max(bound(:,1)) - min(bound(:,1)) < 10)
                        alreadyDone(aDidex) = L(row,i);
                        aDidex = aDidex + 1;
                        continue;
                    end
                    if(firstLet)
                        outputString = append(outputString," \\newline ");
                        maxAy = max(bound(:,1));
                    end
                    letter = poly2mask(bound(:,2),bound(:,1),size(pic,1),size(pic,2));
                    picNew = pic .* letter;
                    picNew(picNew == 0) = 0.75;
                    imshow(picNew);
                    if(abs(max(bound(:,1)) - maxAy) > 200) %was 250, 500
                        outputString = append(outputString," ");
                    end
                    if(min(bound(:,2)) == max(bound(:,2)))
                        maxAx = max(bound(:,2)) + 1;
                    else
                        maxAx = max(bound(:,2));
                    end
                    
                    minAx = min(bound(:,2));
        
                    if(min(bound(:,1)) == max(bound(:,1)))
                        maxAy = max(bound(:,1)) + 1;
                    else
                        maxAy = max(bound(:,1));
                    end
        
                    minAy = min(bound(:,1));
        
                    %axis([minAx-20 maxAx+5 minAy-20 maxAy+20]);
                    axis([minAx maxAx minAy maxAy]);
                    axis off;
                    set(gca,'xdir','reverse');
                    set(gca,'view',[90 -90]);
                    alreadyDone(aDidex) = L(row,i);
                    aDidex = aDidex + 1;
                    saveas(gcf,[path2project, 'tempFolder/current.png']);
                    let = im2bw(imread([path2project, 'tempFolder/current.png']));
        %             let = imbinarize(im2gray(imread('/Users/jamesdavid/Documents/Winter2022/EECS 351/project/matlabHandwriting/tempFolder/current.png')));
                    let = imcomplement(let);
                    let = imresize(let,[28 28]);
                    label = predict_letter(let);

                    if(strcmp(string(label),'l') || strcmp(string(label),'I') || strcmp(string(label),'1') || strcmp(string(label),'J'))
                        
                        lettop = min(bound(:,2));
    
                        letBounds = [min(bound(:,1)) max(bound(:,1))];
    
                        if(lettop - 200 < 1)
                            start = 1;
                        else
                            start = lettop - 200;
                        end
                        
                        for j = start:lettop
                            for k = letBounds(1):letBounds(2)
                                if(L(k,j) ~= 0 && ~ismember(L(k,j),alreadyDone))
                                    if(strcmp(string(label),'J'))
                                        label = 'j';
                                        break;
                                    else
                                        label = 'i';
                                        break;
                                    end
                                end
                            end

                            if(strcmp(string(label),'j') || strcmp(string(label),'i'))
                                break;
                            end

                        end

                    end

                    outputString = append(outputString,string(label));
                    firstLet = 0;
                    1;
                    row = min(bound(:,1));
                    break;
                end
            end
        end
        row = row - 1;
    end
    col = maxCol;
end
outputString = extractBetween(outputString,12,strlength(outputString));
% We not output everything to a properly formatted latex document that can
% be compiled by you favorite compiler
study_home = [path2project, 'pdf/'];


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