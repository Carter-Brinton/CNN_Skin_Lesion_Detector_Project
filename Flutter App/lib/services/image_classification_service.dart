import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class ImageClassificationService {
  static const modelPath = 'assets/models/skin_cancer_model_03.tflite';

  late final Interpreter interpreter;
  late Tensor inputTensor;
  late Tensor outputTensor;

  // Constructor to load the model and initialize tensors
  ImageClassificationService() {
    _loadModel();
  }

  Future<void> _loadModel() async {
    final options = InterpreterOptions();

    // Load model from assets
    interpreter = await Interpreter.fromAsset(modelPath, options: options);
    // Get tensor input shape [1, 224, 224, 3]
    inputTensor = interpreter.getInputTensors().first;
    // Get tensor output shape [1, 1001]
    outputTensor = interpreter.getOutputTensors().first;
  }

  Future<List<double>> classifyImage(XFile? imageFile) async {
    final imageMatrix = await _convertImage(imageFile!);

    final input = [
      imageMatrix
    ];
    // Tensor output [1, 1001]
    final output = [
      List<double>.filled(outputTensor.shape[1], 0)
    ];

    // Run inference
    interpreter.run(input, output);

    // Get the first output tensor
    final result = output.first;

    return result;
  }

  Future<List<List<List<num>>>?> _convertImage(XFile imageFile) async {
    final File file = File(imageFile.path);
    final Uint8List uint8List = await file.readAsBytes();
    final img.Image? image = img.decodeImage(uint8List);

    if (image != null) {
      // Resize the image to (28, 28)
      final img.Image resizedImage = img.copyResize(image, width: 28, height: 28);

      // Convert the image to a list of lists of lists
      final List<List<List<num>>> imageMatrix = [];

      for (int y = 0; y < resizedImage.height; y++) {
        final List<List<num>> row = [];

        for (int x = 0; x < resizedImage.width; x++) {
          final int pixelValue = resizedImage.getPixel(x, y);
          final int red = img.getRed(pixelValue);
          final int green = img.getGreen(pixelValue);
          final int blue = img.getBlue(pixelValue);

          row.add([
            red / 255.0,
            green / 255.0,
            blue / 255.0,
          ]);
        }

        imageMatrix.add(row);
      }

      return imageMatrix;
    }

    return null;
  }
}
