import numpy as np
import pandas as pd

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

import tensorflow as tf
from tensorflow.keras import layers
#from tensorflow.keras.callbacks import EarlyStopping

# preparing neural network model using keras API
model = tf.keras.Sequential()
model.add(layers.Conv2D(32, kernel_size=(5, 5),
                 activation='relu',
                 input_shape=(32,32,1)))
model.add(layers.MaxPooling2D(pool_size=(2, 2)))
model.add(layers.Conv2D(64, (3, 3), activation='relu'))
model.add(layers.MaxPooling2D(pool_size=(2, 2)))
model.add(layers.Conv2D(128, (3, 3), activation='relu'))
model.add(layers.Dropout(0.1))
model.add(layers.Flatten())
model.add(layers.Dense(128, activation='relu'))
model.add(layers.Dense(n_classes, activation='softmax'))
model.compile(loss='categorical_crossentropy', optimizer='Adam', metrics=['accuracy'])
model.summary()

data_generator_with_aug = tf.keras.preprocessing.image.ImageDataGenerator(
    validation_split=.2, 
    #width_shift_range=.2,
    #height_shift_range=.2, rotation_range=30,
    #zoom_range=.2, 
    #shear_range=.1,
#     rescale=1./255,
)

training_data_generator = data_generator_with_aug.flow(train_x, train_y, subset='training')
validation_data_generator = data_generator_with_aug.flow(train_x, train_y, subset='validation')
history = model.fit(x = train_x, y = train_y,
                        #batch_size=128,
                        epochs=20,   #5 for demo, use 25 for better results
                        steps_per_epoch = 23189,
                        #validation_data=validation_data_generator, 
                        #callbacks=[EarlyStopping(monitor="val_acc", min_delta=0.1, patience=5)]
                    )

model.save('./hasy_model.h5')