
study_home = '/Users/jamesdavid/Documents/Winter2022/EECS 351/project/babyProject/pdf/';


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

        fprintf(outputLatex, 'Put output here\n');
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