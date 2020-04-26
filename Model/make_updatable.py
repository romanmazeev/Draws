import coremltools
from coremltools.models import MLModel

embedding_path = './TinyDrawingEmbedding.mlmodel'
embedding_model = MLModel(embedding_path)

embedding_spec = embedding_model.get_spec()

from coremltools.models.nearest_neighbors import KNearestNeighborsClassifierBuilder
import coremltools.models.datatypes as datatypes

knn_builder = KNearestNeighborsClassifierBuilder(input_name='embedding',
                                                 output_name='label',
                                                 number_of_dimensions=128,
                                                 default_class_label='unknown',
                                                 k=3,
                                                 weighting_scheme='inverse_distance',
                                                 index_type='linear')

knn_builder.author = 'Core ML Tools Example'
knn_builder.license = 'MIT'
knn_builder.description = 'Classifies 128 dimension vector based on 3 nearest neighbors'

knn_spec = knn_builder.spec
knn_spec.description.input[0].shortDescription = 'Input vector to classify'
knn_spec.description.output[0].shortDescription = 'Predicted label. Defaults to \'unknown\''
knn_spec.description.output[1].shortDescription = 'Probabilities / score for each possible label.'

# print knn_spec.description

pipeline_spec = coremltools.proto.Model_pb2.Model()
pipeline_spec.specificationVersion = coremltools._MINIMUM_UPDATABLE_SPEC_VERSION
pipeline_spec.isUpdatable = True

# Inputs are the inputs from the embedding model
pipeline_spec.description.input.extend(embedding_spec.description.input[:])

# Outputs are the outputs from the classification model
pipeline_spec.description.output.extend(knn_spec.description.output[:])
pipeline_spec.description.predictedFeatureName = knn_spec.description.predictedFeatureName
pipeline_spec.description.predictedProbabilitiesName = knn_spec.description.predictedProbabilitiesName

# Training inputs
pipeline_spec.description.trainingInput.extend([embedding_spec.description.input[0]])
pipeline_spec.description.trainingInput[0].shortDescription = 'Example sketch'
pipeline_spec.description.trainingInput.extend([knn_spec.description.output[0]])
pipeline_spec.description.trainingInput[1].shortDescription = 'Associated true label of example sketch'

# Provide metadata
pipeline_spec.description.metadata.author = 'Core ML Tools'
pipeline_spec.description.metadata.license = 'MIT'
pipeline_spec.description.metadata.shortDescription = ('An updatable model which can be used to train a tiny 28 x 28 drawing classifier based on user examples.'
                                                       ' It uses a drawing embedding trained on the Quick, Draw! dataset (https://github.com/googlecreativelab/quickdraw-dataset)')

# Construct pipeline by adding the embedding and then the nearest neighbor classifier
pipeline_spec.pipelineClassifier.pipeline.models.add().CopyFrom(embedding_spec)
pipeline_spec.pipelineClassifier.pipeline.models.add().CopyFrom(knn_spec)

# Save the updated spec.
from coremltools.models import MLModel
mlmodel = MLModel(pipeline_spec)

output_path = './TinyDrawingClassifier.mlmodel'
from coremltools.models.utils import save_spec
mlmodel.save(output_path)
