import numpy as np
import pandas as pd
from tensorflow import keras
from sklearn.metrics import confusion_matrix
import seaborn as sns
import matplotlib.pyplot as plt

# Read data with labels
data_labels = pd.read_csv("hasy-data-labels.csv")

# Extracting data only for selected labels
import string
cand = ['\\pi','\\sum','\\tau','\\rightarrow','\\infty','\\int','\\approx','\\times','<','>','[',']','+','-','/'] + list(string.ascii_letters) + list(string.digits)
df = data_labels.loc[data_labels["latex"].isin(cand) ]

# Preparing training data as numpy array of vectors from raw images
from PIL import Image
# from skimage import io, color

listOfB = []
for items in df['path'].iteritems(): 
    pil_im = Image.open(items[1], 'r')
    im = pil_im.convert("L")
    array1 = np.asarray(im)/255.
    listOfB.append(array1)
B = np.array(listOfB) 
B.reshape(df.shape[0], 32, 32, 1)
B = np.expand_dims(B, axis=3)
train_x = B

#import matplotlib.pyplot as plt
#plt.imshow(train_x[400])

# Indexing raw labels to indexes of lists
classes = df["latex"].unique().tolist()
n_classes = len(classes)

# save the labels 
with open("./labels.txt", "w") as f:
    f.write("\n".join(classes))

# Preparing categorical labels for multiclass classification (categorical crossentropy)
train_y = df['latex']
listOfk = []
for items in df['latex'].iteritems():
    intermediate = np.zeros(n_classes)
    index = classes.index(items[1])
    intermediate[index] = 1
    listOfk.append(intermediate)
categorical_labels = np.array(listOfk)
train_y = categorical_labels

model = keras.models.load_model('./hasy_model.h5')
pred = []
cor = []
correct = 0
for i in range(23189):
    img = np.expand_dims(train_x[i], axis=0)
    index = np.argmax(model(img))
    pred.append(index)
    cor.append(np.argmax(train_y[i]))
    if index == np.argmax(train_y[i]):
        correct = correct + 1

#print(pred)
#print(cor)
perc = correct/23189.0 * 100
cf_matrix = confusion_matrix(cor, pred)

ax = sns.heatmap(cf_matrix, annot=False, cmap='Blues')

ax.set_title('HASYv2 Confusion Matrix\n\n');
ax.set_xlabel('\nPredicted Values')
ax.set_ylabel('Actual Values ');
print(perc)

## Display the visualization of the Confusion Matrix.
plt.show()