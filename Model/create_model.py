import turicreate as tc

# Try any one of the following
SFRAME_PATH = "quickdraw/sframes/bitmap_square_triangle.sframe"
SFRAME_PATH = "quickdraw/sframes/stroke_square_triangle.sframe"

# Load the data
data =  tc.SFrame(SFRAME_PATH)

# Make a small train-test split since our toolkit is not very data-hungry 
# for 2 classes
train_data, test_data = data.random_split(0.7)

# Create a model
model = tc.drawing_classifier.create(train_data, 'label')

# Save predictions to an SArray
predictions = model.predict(test_data)

# Evaluate the model and save the results into a dictionary
metrics = model.evaluate(test_data)
print(metrics["accuracy"])

# Save the model for later use in Turi Create
model.save("square_triangle.model")

# Export for use in Core ML
model.export_coreml("MySquareTriangleClassifier.mlmodel")

