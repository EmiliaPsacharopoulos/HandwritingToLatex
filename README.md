# Handwriting to LaTeX
## Project Motivation
Have you ever been sick and missed class? Did you try to watch the recording and then it dawned on you that your Professor does not use electronic slides and you'll need to decipher the board by zooming in real close, and then the pain settles in. Our project is aimed to help remedy this problem.  All the student needs to do is input screenshots of the whiteboard from their lecture recording, and our program translates the written characters into a well-formatted Latex document. It will be as though you were in class all along.  

## Project Description

We are a student project team enrolled in EECS 351: Digital Signal Processing and Analysis at the University of Michigan.
Our overarching goal for the project is to develop an algorithm that allows a user to input a screenshot of a lecture board, and output a nicely formatted LaTeX document of those notes in return. There are four main components to the architecture of our implementation:
1. Image processing and filtering of the lecture recording screenshot.
2. Isolating each individual character.
3. Classifying each individual character.
4. Outputting that classified character to a Latex document.

This GitHub repository hosts our code for our whole project. Click the hyperlinks below to access more information regarding our process implementing each subsection, and the project code in its entirety. 

### Image Processing and Filtering


### Character Isolation


### Character Classification


### Latex Document Formatting


###  Project Code in its Entirety

##### Python Classifiers
1. [K- Nearest Neighbor](https://github.com/EmiliaPsacharopoulos/HandwritingToLatex/blob/main/KNearestNeighbors.ipynb)
2. [Multinomial Naïve Bayes](https://github.com/EmiliaPsacharopoulos/HandwritingToLatex/blob/main/GaussianNB.ipynb)
3. [Support Vector Machine](https://github.com/EmiliaPsacharopoulos/HandwritingToLatex/blob/main/SVM.ipynb)
4. [Decision Tree](https://github.com/EmiliaPsacharopoulos/HandwritingToLatex/blob/main/DecisionTree.ipynb)
5. [Neural Network](https://github.com/EmiliaPsacharopoulos/HandwritingToLatex/blob/main/LeNet_CNN)

##### Matlab Models
1. [Data Conditioning](https://github.com/EmiliaPsacharopoulos/HandwritingToLatex/blob/main/data_conditioning.m)
2. [Model Training](https://github.com/EmiliaPsacharopoulos/HandwritingToLatex/blob/main/train_test.m)

##### Edge Detection

##### Latex Output
1. [Latex Output V1 with no newline capabilities](https://github.com/EmiliaPsacharopoulos/HandwritingToLatex/blob/main/projectPDF.m)
2. [Latex Output V2 with buggy newline capabilities]()


See our [team website](https://sites.google.com/umich.edu/eecs-351-handwriting-to-latex/home?authuser=0) for more information regarding this project.
