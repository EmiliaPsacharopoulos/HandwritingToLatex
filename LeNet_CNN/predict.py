# set the numpy seed for better reproducibility
import numpy as np
np.random.seed(42)
# import the necessary packages
from torch.utils.data import DataLoader
from torch.utils.data import Subset
from torchvision.transforms import ToTensor
from torchvision.datasets import EMNIST
import argparse
#import imutils
import torch
#import cv2
from sklearn.metrics import confusion_matrix
import seaborn as sns
import matplotlib.pyplot as plt

# construct the argument parser and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument("-m", "--model", type=str, required=True,
	help="path to the trained PyTorch model")
args = vars(ap.parse_args())

# set the device we will be using to test the model
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
# load the KMNIST dataset and randomly grab 10 data points
print("[INFO] loading the EMNIST test dataset...")
# change EMNIST to MNIST for digits and remove split parameter
# change split to "byclass" if want uppercase, lowercase, and digits
testData = EMNIST(root="data/", split = "letters", train=False, download=True,
	transform=ToTensor())
idxs = np.random.choice(range(0, len(testData)), size=(10000,))
testData = Subset(testData, idxs)
# initialize the test data loader
testDataLoader = DataLoader(testData, batch_size=1)
# load the model and set it to evaluation mode
model = torch.load(args["model"]).to(device)
model.eval()

correct = []
predictions = []

# switch off autograd
with torch.no_grad():
	# loop over the test set
    for (image, label) in testDataLoader:
        # grab the original image and ground truth label
        origImage = image.numpy().squeeze(axis=(0, 1))
        gtLabel = testData.dataset.classes[label.numpy()[0]]
        # send the input to the device and make predictions on it
        image = image.to(device)
        pred = model(image)
        # find the class label index with the largest corresponding
        # probability
        idx = pred.argmax(axis=1).cpu().numpy()[0]
        predLabel = testData.dataset.classes[idx] #testData.dataset.classes[idx]
        print("[INFO] ground truth label: {}, predicted label: {}".format(gtLabel, predLabel))
        correct = correct + [gtLabel]
        predictions = predictions + [predLabel]



#Generate the confusion matrix
cf_matrix = confusion_matrix(correct, predictions)

ax = sns.heatmap(cf_matrix, annot=False, cmap='Blues')

ax.set_title('EMNIST Letters Confusion Matrix: 10,000 samples\n\n');
ax.set_xlabel('\nPredicted Values')
ax.set_ylabel('Actual Values ');


## Display the visualization of the Confusion Matrix.
plt.show()
