import numpy as np
from tensorflow import keras
#from PIL import Image
#from torch import argmax

# image is 32x32x1 normalized grayscale
def predict_letter(image):
    
    image = image[None,:,:,None]
    
    model = keras.models.load_model('./hasy_model.h5')

    index = np.argmax(model(image))

    with open('labels.txt','r') as f:
        labels=[]
        for line in f:
            strip_lines=line.strip()
            label=strip_lines.split()
            labels.append(label)

    return labels[index][0]
    
#pil_im = Image.open('hasy-data/v2-00047.png', 'r')
#im = pil_im.convert("L")
#array1 = np.asarray(im)/255
#im2 = array1.reshape(32,32,1)
#im2 = np.expand_dims(im2, axis=0)

#print(predict_letter(im2))

