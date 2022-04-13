import numpy as np
# import the necessary packages
from torchvision.transforms import ToTensor
from torchvision.datasets import EMNIST
import torch


def predict_letter(image):
    
    # set the device we will be using to test the model
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    torch.set_num_threads(1)
    testData = EMNIST(root="data/", split = "byclass", train=False, download=True,
	    transform=ToTensor())
    model = torch.load('model.pth').to(device)
    model.eval()

    # switch off autograd
    with torch.no_grad():
        # increase dimensionality to be [1 1 28 28]
        image = np.expand_dims(image, axis=0)
        image = np.expand_dims(image, axis=0)

        img = torch.tensor(image).float()
        img = img.to(device)
        pred = model(img)

        # find the class label index with the largest probability
        idx = pred.argmax(axis=1).cpu().numpy()[0]
        predLabel = testData.classes[idx] 
        #print(predLabel)

    return predLabel

