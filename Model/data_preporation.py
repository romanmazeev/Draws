import turicreate as tc
import numpy as np
import os

random_state = np.random.RandomState(10000)

# Change if applicable
dataset_dir = 'Dataset'
bitmaps_dir = os.path.join(dataset_dir, 'bitmaps')
npy_ext = '.npy'
num_examples_per_class = 10000

f = open('classes.txt', 'r')
classes = f.read().splitlines()
f.close()

num_classes = len(classes)

def build_sframe():
    bitmaps_list, labels_list = [], []
    for class_name in classes:
        class_data = np.load(os.path.join(bitmaps_dir, class_name + npy_ext))
        random_state.shuffle(class_data)
        class_data_selected = class_data[:num_examples_per_class]
        class_data_selected = class_data_selected.reshape(
            class_data_selected.shape[0], 28, 28, 1)
        for np_pixel_data in class_data_selected:
            FORMAT_RAW = 2
            bitmap = tc.Image(_image_data = np_pixel_data.tobytes(),
                              _width = np_pixel_data.shape[1],
                              _height = np_pixel_data.shape[0],
                              _channels = np_pixel_data.shape[2],
                              _format_enum = FORMAT_RAW,
                              _image_data_size = np_pixel_data.size)
            bitmaps_list.append(bitmap)
            labels_list.append(class_name)

    sf = tc.SFrame({"drawing": bitmaps_list, "label": labels_list})
    sf.save(os.path.join(dataset_dir, "drawn.sframe"))
    return sf 

sf = build_sframe()