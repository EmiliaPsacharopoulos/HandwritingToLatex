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
outputString2 = "";
while(col < endCol)
    col = col + 1;
    colSum = sum(text(:,col));
    if(colSum < collen) % 750 if a line intersectes a particularly large amount of white (letters)
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
                    outputString2 = append(outputString2," \\newline ");
                    maxAy = max(bound(:,1));
                end
                switch math
                    case 0
                        letter = poly2mask(bound(:,2),bound(:,1),size(pic,1),size(pic,2));
                    case 1
                        letter = poly2mask([min(bound(:,2)), min(bound(:,2)), max(bound(:,2)), max(bound(:,2))],[max(bound(:,1)), min(bound(:,1)), min(bound(:,1)), max(bound(:,1))],size(pic,1),size(pic,2));
                end
                picNew = pic .* letter;
                if(~math)
                    picNew(picNew == 0) = 0.75;
                end
                imshow(picNew);
                if(abs(max(bound(:,1)) - maxAy) > 200) %was 250, 500
                    outputString = append(outputString," ");
                    outputString2 = append(outputString2," ");
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
%                 let = im2gray(im2double(imread([path2project, 'tempFolder/current.png'])));
                let = im2bw(imread([path2project, 'tempFolder/current.png']));

    %             let = imbinarize(im2gray(imread('/Users/jamesdavid/Documents/Winter2022/EECS 351/project/matlabHandwriting/tempFolder/current.png')));
                %let = imcomplement(let);
                let2 = imcomplement(let);
                let1 = imresize(let,[32 32]);
                let2 = imresize(let2,[28 28]);
                
                [label1, label] = predict_letter(let1, let2);

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

                if(strcmp(string(label1),'E') || strcmp(string(label1),'\Sigma') || strcmp(string(label1),'S') || strcmp(string(label1),'\int'))
                    % here this feedback loop looks for the bounds of
                    % mathematical operators
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
                                bound = B{L(k,j)};
                                letter = poly2mask([min(bound(:,2)), min(bound(:,2)), max(bound(:,2)), max(bound(:,2))],[max(bound(:,1)), min(bound(:,1)), min(bound(:,1)), max(bound(:,1))],size(pic,1),size(pic,2));
                                picNew = pic .* letter;
                                imshow(picNew);
                                if(abs(max(bound(:,1)) - maxAy) > 200) %was 250, 500
                                    outputString = append(outputString," ");
                                    outputString2 = append(outputString2," ");
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
                %                 let = im2gray(im2double(imread([path2project, 'tempFolder/current.png'])));
                                let = im2bw(imread([path2project, 'tempFolder/current.png']));
                                let2 = imcomplement(let);
                                let1 = imresize(let,[32 32]);
                                let2 = imresize(let2,[28 28]);
                                [dc, num] = predict_letter(let1, let2);
                                if(strcmp(string(label1),'E') || strcmp(string(label1),'\Sigma'))
                                    label1 = strjoin(string(['\sum^{',string(num),'}']),'');
                                else
                                    label1 = strjoin(string(['\int^{',string(num),'}']),'');
                                end
                                break;
                            end
                        end

                        if(contains(string(label1),'sum') || contains(string(label1),'int^'))
                            break;
                        end

                    end

                    letbot = max(bound(:,2));

                    letBounds = [min(bound(:,1)) max(bound(:,1))];

                    if(letbot + 200 > size(L,2))
                        start = size(L,2);
                    else
                        start = letbot + 200;
                    end

                    for j = letbot:start
                        for k = letBounds(1):letBounds(2)
                            if(L(k,j) ~= 0 && ~ismember(L(k,j),alreadyDone))
                                bound = B{L(k,j)};
                                letter = poly2mask([min(bound(:,2)), min(bound(:,2)), max(bound(:,2)), max(bound(:,2))],[max(bound(:,1)), min(bound(:,1)), min(bound(:,1)), max(bound(:,1))],size(pic,1),size(pic,2));
                                picNew = pic .* letter;
                                imshow(picNew);
                                if(abs(max(bound(:,1)) - maxAy) > 200) %was 250, 500
                                    outputString = append(outputString," ");
                                    outputString2 = append(outputString2," ");
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
                %                 let = im2gray(im2double(imread([path2project, 'tempFolder/current.png'])));
                                let = im2bw(imread([path2project, 'tempFolder/current.png']));
                                let2 = imcomplement(let);
                                let1 = imresize(let,[32 32]);
                                let2 = imresize(let2,[28 28]);
                                [dc, num] = predict_letter(let1, let2);
                                if(contains(string(label1),'sum'))
                                    label1 = append(label1,strjoin(['_{=',string(num),'}'],''),'');
                                else
                                    label1 = append(label1,strjoin(['_{',string(num),'}'],''),'');
                                end
                                break;
                            end
                        end
                        if(contains(string(label1),'_'))
                            break;
                        end

                    end
                end

                if(contains(string(label1),'\'))
                    label1 = strjoin(string(['$\',string(label1),'$']),'');
                end

                outputString = append(outputString,string(label));
                outputString2 = append(outputString2,string(label1));

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
                        outputString2 = append(outputString2," \\newline ");
                        maxAy = max(bound(:,1));
                    end
                    switch math
                        case 0
                            letter = poly2mask(bound(:,2),bound(:,1),size(pic,1),size(pic,2));
                        case 1
                            letter = poly2mask([min(bound(:,2)), min(bound(:,2)), max(bound(:,2)), max(bound(:,2))],[max(bound(:,1)), min(bound(:,1)), min(bound(:,1)), max(bound(:,1))],size(pic,1),size(pic,2));
                    end
                    picNew = pic .* letter;
                    if(~math)
                        picNew(picNew == 0) = 0.75;
                    end
                    imshow(picNew);
                    if(abs(max(bound(:,1)) - maxAy) > 200) %was 250, 500
                        outputString = append(outputString," ");
                        outputString2 = append(outputString2," ");
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
%                     let = im2gray(im2double(imread([path2project, 'tempFolder/current.png'])));

        %             let = imbinarize(im2gray(imread('/Users/jamesdavid/Documents/Winter2022/EECS 351/project/matlabHandwriting/tempFolder/current.png')));

                    let2 = imcomplement(let);
                    let1 = imresize(let,[32 32]);
                    let2 = imresize(let2,[28 28]);
                    [label1, label] = predict_letter(let1, let2);

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

                    if(strcmp(string(label1),'E') || strcmp(string(label1),'\Sigma') || strcmp(string(label1),'S') || strcmp(string(label1),'\int'))
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
                                    bound = B{L(k,j)};
                                    letter = poly2mask([min(bound(:,2)), min(bound(:,2)), max(bound(:,2)), max(bound(:,2))],[max(bound(:,1)), min(bound(:,1)), min(bound(:,1)), max(bound(:,1))],size(pic,1),size(pic,2));
                                    picNew = pic .* letter;
                                    imshow(picNew);
                                    if(abs(max(bound(:,1)) - maxAy) > 200) %was 250, 500
                                        outputString = append(outputString," ");
                                        outputString2 = append(outputString2," ");
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
                    %                 let = im2gray(im2double(imread([path2project, 'tempFolder/current.png'])));
                                    let = im2bw(imread([path2project, 'tempFolder/current.png']));
                                    let2 = imcomplement(let);
                                    let1 = imresize(let,[32 32]);
                                    let2 = imresize(let2,[28 28]);
                                    [dc, num] = predict_letter(let1, let2);
                                    if(strcmp(string(label1),'E') || strcmp(string(label1),'\Sigma'))
                                        label1 = strjoin(string(['\sum^{',string(num),'}']),'');
                                    else
                                        label1 = strjoin(string(['\int^{',string(num),'}']),'');
                                    end
                                    break;
                                end
                            end
    
                            if(contains(string(label1),'sum') || contains(string(label1),'int^'))
                                break;
                            end
    
                        end

                        letbot = max(bound(:,2));
    
                        letBounds = [min(bound(:,1)) max(bound(:,1))];
    
                        if(letbot + 200 > size(L,2))
                            start = size(L,2);
                        else
                            start = letbot + 200;
                        end

                        for j = letbot:start
                            for k = letBounds(1):letBounds(2)
                                if(L(k,j) ~= 0 && ~ismember(L(k,j),alreadyDone))
                                    bound = B{L(k,j)};
                                    letter = poly2mask([min(bound(:,2)), min(bound(:,2)), max(bound(:,2)), max(bound(:,2))],[max(bound(:,1)), min(bound(:,1)), min(bound(:,1)), max(bound(:,1))],size(pic,1),size(pic,2));
                                    picNew = pic .* letter;
                                    imshow(picNew);
                                    if(abs(max(bound(:,1)) - maxAy) > 200) %was 250, 500
                                        outputString = append(outputString," ");
                                        outputString2 = append(outputString2," ");
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
                    %                 let = im2gray(im2double(imread([path2project, 'tempFolder/current.png'])));
                                    let = im2bw(imread([path2project, 'tempFolder/current.png']));
                                    let2 = imcomplement(let);
                                    let1 = imresize(let,[32 32]);
                                    let2 = imresize(let2,[28 28]);
                                    [dc, num] = predict_letter(let1, let2);
                                    if(contains(string(label1),'sum'))
                                        label1 = append(string(label1),strjoin(['_{=',string(num),'}'],''),'');
                                    else
                                        label1 = append(string(label1),strjoin(['_{',string(num),'}'],''),'');
                                    end
                                    break;
                                end
                            end
                            if(contains(string(label1),'_'))
                                break;
                            end
    
                        end
                    end

                if(contains(string(label1),'\'))
                    label1 = strjoin(string(['$\',string(label1),'$']),'');
                end

                    outputString = append(outputString,string(label));
                    outputString2 = append(outputString2,string(label1));

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
outputString2 = extractBetween(outputString2,12,strlength(outputString2));