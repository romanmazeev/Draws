import coremltools

coreml_model_path = "./QuickDraw.mlmodel"

spec = coremltools.utils.load_spec(coreml_model_path)
builder = coremltools.models.neural_network.NeuralNetworkBuilder(spec=spec)
builder.inspect_layers(last=3)
builder.inspect_input_features()

neuralnetwork_spec = builder.spec

neuralnetwork_spec.description.input[0].type.imageType.width = 28
neuralnetwork_spec.description.input[0].type.imageType.height = 28

neuralnetwork_spec.description.metadata.author = 'Roman Mazeev'
neuralnetwork_spec.description.metadata.license = 'MIT'
neuralnetwork_spec.description.metadata.shortDescription = (
        'QuickDraw classifier converted from a Keras model')
        
model_spec = builder.spec
builder.make_updatable(['dense_3', 'dense_2'])
builder.set_categorical_cross_entropy_loss(name='lossLayer', input='output')

from coremltools.models.neural_network import SgdParams
builder.set_sgd_optimizer(SgdParams(lr=0.01, batch=5))
builder.set_epochs(2)

model_spec.isUpdatable = True
model_spec.specificationVersion = coremltools._MINIMUM_UPDATABLE_SPEC_VERSION

model_spec.description.trainingInput[0].shortDescription = 'Image for training and updating the model'
model_spec.description.trainingInput[1].shortDescription = 'Set the value as drawing image label and update the model'
coremltools.utils.save_spec(model_spec, "QuickDrawUpdatable.mlmodel")