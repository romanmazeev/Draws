# Draws
iOS/MacOS app that recognize drawings

## Screenshots
### Drawing recognition
![recognition](https://i.imgur.com/uwyfrIQ.gif)

### Drawing recognition after model updating
![updated](https://i.imgur.com/iYRcPt6.gif)

## Requirements
- Xcode 11
- Swift 5
- iOS 13
- MacOS 10.15

### For model converting
- Python 3.6
- [coremltools](https://github.com/apple/coremltools)

## Model
For conversion, a pre-trained keras [model](https://github.com/akshaybahadur21/QuickDraw) was taken, which was trained on [several classes](https://github.com/romanmazeev/Draws/blob/master/Model/classes.txt) of the [Quick Draw!](https://quickdraw.withgoogle.com/data) Dataset.

### How convert to CoreML model
1. Update file with classes to match the classes of your model.
2. Run this [script](https://github.com/romanmazeev/Draws/blob/master/Model/create_model.py) to generate CoreML model.

### How to make model updatable
In order to make the model updatable, you need to run the [script](https://github.com/romanmazeev/Draws/blob/master/Model/make_updatable.py).
 
