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

See our [team website](https://sites.google.com/umich.edu/eecs-351-handwriting-to-latex/home?authuser=0) for more information regarding this project.

![flowchart](https://user-images.githubusercontent.com/84528674/165018351-2b05c0e2-7967-49e4-bc2d-b2d0b41fc758.jpg)
This flowchart depicts the project architecture of the connections between all of our subsystems. Image © Team original work.


## Project Implementation

This GitHub repository hosts all code for our entire project implementation. Click the hyperlinks below to access more information regarding our process implementing each subsection, and the project code in its entirety. 

### Image Processing and Filtering
Our main objective of this process is distinguishing the handwriting from the blemishes and scratches on the given surface. We applied various filtering and image processing techniques in MATLAB to manipulate the signal and only assign value to detected handwriting information. Our signal processing is lossy because the handwritten characters and numbers containing encircled regions is completely filled. As a result, we implemented a mask in the Character Isolation subsection to retain that information.

1. [imageFilteringAndProcessingSubsystem.m](https://github.com/EmiliaPsacharopoulos/HandwritingToLatex/blob/main/imageFilteringAndProcessingSubsystem.m)


### Character Isolation and Classification

We had to intertwine the implementation of these subsystems. Read more about each below, and access the .m file listed below to read through our code for these subsections. Note: the image "text" is assumed to be the output from the Image Filtering and Processing subsystem. We are simply extracting the required code for these two subsections for parsability when examining this project, so this .m file is not meant to be run on its own. 

1. [CharacterIsolationAndClassification.m](https://github.com/EmiliaPsacharopoulos/HandwritingToLatex/blob/main/CharacterIsolationAndClassification.m)

#### Character Isolation
This section is highly dependent on the handwriting style of any individual image. We needed to take into account that the spacing between characters will vary heavily, and that nobody can write on a perfectly straight line. This means that our system must be shift invariant to correct the character separation issue, and rotation invariant to correct the imperfect lines of writing. The character isolation process was definitely the most algorithmically-intensive process to design in our project due to the difficulty of making this subsystem shift and rotation invariant. 

#### Character Classification
This section takes in an image of an isolated character from the Character Isolation process, and classifies that image as a character. We decided to compare the predicted character outputs of five common character classification techniques using Python's sklearn classification library. We trained each classifier on the EMNIST dataset's 60,000 training images and then tested each with EMNIST's 10,000 testing images, and then ranked the overall efficiency of each classifier according to its accuracy while also considering speed, and memory. Our Jupiter Notebook files for these methods are almost identical, apart from setting nb_classifier to the given method.
1. [K- Nearest Neighbor](https://github.com/EmiliaPsacharopoulos/HandwritingToLatex/blob/main/KNearestNeighbors.ipynb)
2. [Multinomial Naïve Bayes](https://github.com/EmiliaPsacharopoulos/HandwritingToLatex/blob/main/GaussianNB.ipynb)
3. [Support Vector Machine](https://github.com/EmiliaPsacharopoulos/HandwritingToLatex/blob/main/SVM.ipynb)
4. [Decision Tree](https://github.com/EmiliaPsacharopoulos/HandwritingToLatex/blob/main/DecisionTree.ipynb)

We implemented a convolutional neural network following the LeNet structure. Our process in Python can be broken down into creating the network architecture, training the network, and making predictions with the network.

5. [Neural Network](https://github.com/EmiliaPsacharopoulos/HandwritingToLatex/blob/main/LeNet_CNN)

The five classification methods listed above were for our own testing purposes in choosing the best method for this specific application. Overall, the Support Vector Machine led in accuracy, but we decided to use the LeNet Neural Network classification technique for its high accuracy, low memory usage, speed efficiency, and straightforward interface with MATLAB.

Our *first version* of the character classification subsystem implementation in MATLAB can be split into two primary processes: image processing and executing the model. Each process is its own script.

1. [Data Conditioning](https://github.com/EmiliaPsacharopoulos/HandwritingToLatex/blob/main/data_conditioning.m)
2. [Model Training](https://github.com/EmiliaPsacharopoulos/HandwritingToLatex/blob/main/train_test.m)

We implemented our final version of the Character Classification subsystem as a Python function, called within the MATLAB file. First, the program calls [predict_letter.m](https://github.com/EmiliaPsacharopoulos/HandwritingToLatex/blob/main/matlabHandwriting/predict_letter.m) to classify a given subimage. Then, [predict_letter.m](https://github.com/EmiliaPsacharopoulos/HandwritingToLatex/blob/main/matlabHandwriting/predict_letter.m) uses a Python virtual environment to run the LeNet Convolutional Neural Network classifier in Python. The user must have: 

1. [nnpredict_hasy.py](https://github.com/EmiliaPsacharopoulos/HandwritingToLatex/blob/main/matlabHandwriting/nnpredict_hasy.py) or [nnpredict.py](https://github.com/EmiliaPsacharopoulos/HandwritingToLatex/blob/main/matlabHandwriting/nnpredict.py) 
2. [lenet.py](https://github.com/EmiliaPsacharopoulos/HandwritingToLatex/blob/main/matlabHandwriting/lenet.py)
3. [model.pth](https://github.com/EmiliaPsacharopoulos/HandwritingToLatex/blob/main/matlabHandwriting/model.pth)

We were only able to setup the virtual Python environment in Linux (not on Windows). To account for any interested parties without access to a Linux system, we record a video demonstration of the full-scale system running on our [team website](https://sites.google.com/umich.edu/eecs-351-handwriting-to-latex/home?authuser=0) in the Processes tab.

See the linked [CharacterIsolationAndClassification.m](https://github.com/EmiliaPsacharopoulos/HandwritingToLatex/blob/main/CharacterIsolationAndClassification.m) file to see our final version of this subsystem in combination with the Character Isolation subsystem. 

### Latex Document Formatting
We created a script in MATLAB that converts the outputted classified characters from the Character Classification subsection to a LaTeX file. Our function currently takes in the user-defined lecture title and date metadata, then combines that information with the lecture content in the body of the document. 

1. [LaTeX_Subsystem.m](https://github.com/EmiliaPsacharopoulos/HandwritingToLatex/blob/main/LaTeX_Subsystem.m)


###  Project Code in its Entirety
The entire system follows the flowchart inserted above. It can be run by downloading the folder [matlabHandwriting](https://github.com/EmiliaPsacharopoulos/HandwritingToLatex/tree/main/matlabHandwriting) and running [edgesd.m](https://github.com/EmiliaPsacharopoulos/HandwritingToLatex/blob/main/matlabHandwriting/edgesd.m). Some things to note before running the demo:
* You must set up the python environment in MATLAB using [pyenv](https://www.mathworks.com/help/matlab/ref/pyenv.html) at the command line. We have had far more success setting up the Python virtual environment on Linux computers rather than Windows computers. If this is not working on your Operating System, we have recorded a video demonstration of the full-scale system running on our [team website](https://sites.google.com/umich.edu/eecs-351-handwriting-to-latex/home?authuser=0) in the Processes tab.
* You must load the python module nnpredict.py
    * (detailed instructions in [predict_letter.m](https://github.com/EmiliaPsacharopoulos/HandwritingToLatex/blob/main/matlabHandwriting/predict_letter.m) )
* You must change the directory to your personal location of the folder


## Data

### Our Own Character Handwriting Samples
[Dataset Link](https://drive.google.com/drive/folders/1qJdVS5bR81oHK7z92HAfMuExT0la9WWD)

We made a small database of our own handwriting of the alphabet and some common mathematical symbols. The following characters have more than 20+ samples: N, n, x, Summation, infinity, equals sign, plus sign. We chose those characters from our experiences of knowing how common they are in an EECS 351 lecture. The idea here was to get a small scale idea of using simple classifiers in MATLAB at the beginning of our project. Also, we wanted to obtain samples that use a variety of different backgrounds, and writing tools. 

### EMNIST Database Training Data
[Dataset Link](https://paperswithcode.com/dataset/emnist)

The EMNIST dataset is a publicly available dataset which contains samples of handwritten digits. There are 60,000 training samples and 10,000 testing samples. It contains handwriting samples from American high school students, as well as American Census Bureau employees. The samples are normalized to fit into a 28x28 pixel box and are anti-aliased. 

We implemented K Nearest Neighbors, Multinomial Naïve Bayes, Support Vector Machine, LeNet Neural Network, and Decision Tree Classifiers on this dataset. 

### HASYv2 Database Training Data
[Dataset Link](https://arxiv.org/pdf/1701.08380.pdf)

The HASYv2 dataset is a publicly available dataset which contains samples of handwritten letters, digits, and mathematical symbols. Each character is a black and white, 32x32 image. There are a total of ~168,000 images in the dataset, each correctly labelled with one of the 369 potential classes. 

This dataset was used to train our second neural network to recognize mathematical symbols. Rather than using all of the classes, we extracted the numbers, letters, and a small selection of other characters (∏, ∑, ∫, <, >, -, +, /, ×, ≈, [, ], ∞, 𝛕, →). 

## Authors
* Emilia Psacharopoulos
* Enakshi Deb
* Maura Mulligan
* James Wishart
* Ritika Pansare
