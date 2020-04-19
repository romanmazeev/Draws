import turicreate as tc
import numpy as np
import os
import json

random_state = np.random.RandomState(100)

# Change if applicable
quickdraw_dir = 'quickdraw'
bitmaps_dir = os.path.join(quickdraw_dir, 'bitmaps')
strokes_dir = os.path.join(quickdraw_dir, 'strokes')
sframes_dir = os.path.join(quickdraw_dir, 'sframes')
npy_ext = '.npz'
ndjson_ext = '.ndjson'
num_examples_per_class = 100
classes = ["square", "triangle"]
num_classes = len(classes)

def build_bitmap_sframe():
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
    sf.save(os.path.join(sframes_dir, "bitmap_quickdraw.sframe"))
    return sf 
    
def build_strokes_sframe():
    drawings_list, labels_list = [], []
    for class_name in classes:
        with open(os.path.join(strokes_dir, class_name+ndjson_ext)) as fin:
            ndjson_data = list(map(lambda x: x.strip(), fin.readlines()))
        random_state.shuffle(ndjson_data)
        ndjson_data_selected = list(map(json.loads, ndjson_data[:num_examples_per_class]))
        raw_drawing_list = [ndjson["drawing"] for ndjson in ndjson_data_selected]
        def raw_to_final(raw_drawing):
            return [
                [
                    {
                        "x": raw_drawing[stroke_id][0][i], 
                        "y": raw_drawing[stroke_id][1][i]
                    } for i in range(len(raw_drawing[stroke_id][0]))
                ] 
                for stroke_id in range(len(raw_drawing))
            ]

        final_drawing_list = list(map(raw_to_final, raw_drawing_list))
        drawings_list.extend(final_drawing_list)
        labels_list.extend([class_name] * num_examples_per_class)
    sf = tc.SFrame({"drawing": drawings_list, "label": labels_list})
    sf.save(os.path.join(sframes_dir, "stroke_quickdraw.sframe"))
    return sf 

sf = build_bitmap_sframe()
sf = build_strokes_sframe()

sf["rendered"] = tc.drawing_classifier.util.draw_strokes(sf["drawing"])
sf.explore()