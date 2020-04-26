import coremltools

f = open('classes.txt', 'r')
output_labels = f.read().splitlines()
f.close()

coreml_model = coremltools.converters.keras.convert('QuickDraw.h5', input_names=['image'], output_names=['output'],
                                                   class_labels=output_labels,
                                                   image_input_names='image')

coreml_model.author = 'Roman mazeev'
coreml_model.short_description = 'Drawing classifier converted from a Keras model'
coreml_model.input_description['image'] = 'Takes as input an image'
coreml_model.output_description['output'] = 'Drawning predictions'
coreml_model.output_description['classLabel'] = 'Returns drawing as class label'

coreml_model.save('QuickDraw.mlmodel')