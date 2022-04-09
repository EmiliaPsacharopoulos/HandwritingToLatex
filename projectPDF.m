%assuming everything is in the same directory
%user defined inputs: title, date
function pdffilename = projectPDF(filename, title, date)
    %filename = "outputStrings.txt";
    str = string(readlines(filename));
    study_home = 'C:\Users\emili\OneDrive\Desktop\Michigan\W22\EECS351\Project\'; %must be the same place
    cd(study_home);
    pdffilename = 'output.tex';

    %settings here.
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
        fprintf(outputLatex, '}\n');
        fprintf(outputLatex, '\n');
        fprintf(outputLatex, '\\DeclareGraphicsRule{.tif}{png}{.png}{`convert #1 `dirname #1`/`basename #1 .tif`.png}\n');
        fprintf(outputLatex, '\n');
        str_new = append('\\title{', title, '}');
        fprintf(outputLatex, str_new);
        fprintf(outputLatex, '\n');
        str_new = append('\\date{', date, '}');
        fprintf(outputLatex, str_new);
        fprintf(outputLatex, '\n\n');
        fprintf(outputLatex, '\\begin{document}\n');
        fprintf(outputLatex, '\\maketitle\n');

        %output the character array
        addingBraces = append('{', str, '}');
        fprintf(outputLatex, addingBraces);


        % End Document
        fprintf(outputLatex, '\\end{document}\n\n');
    
        %
        % now read the entire file and replace all underscores within quotation
        % marks with '\_' to avoid the subscripts.  
        
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
end


