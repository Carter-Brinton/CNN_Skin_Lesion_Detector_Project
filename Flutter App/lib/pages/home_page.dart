import 'dart:io';
import 'dart:typed_data';
import 'package:cs334_final_project/services/image_classification_service.dart';
import 'package:cs334_final_project/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class CameraApp extends StatefulWidget {
  const CameraApp({super.key, required this.title});
  final String title;

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  bool _pictureTaken = false;
  bool _isLoading = false;
  XFile? _selectedImage;
  bool classificationCompleted = false;
  SkinClassInfo? highestClass;
  int highestClassIndex = 0;
  List<double>? classificationResults;
  final ImageClassificationService imageClassificationHelper = ImageClassificationService();

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading...'),
            ],
          ),
        );
      },
    );
  }

  Future<void> _takePicture() async {
    setState(() {
      _pictureTaken = false;
      classificationCompleted = false;
    });

    final XFile? picture = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (picture != null) {
      setState(() {
        _pictureTaken = true;
        _selectedImage = picture;
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _pictureTaken = true;
        _selectedImage = pickedImage;
      });
    }
  }

  Future<void> _classifyImage() async {
    _showLoadingDialog();

    try {
      final results = await imageClassificationHelper.classifyImage(_selectedImage);

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      setState(() {
        _isLoading = false;
        highestClassIndex = results.indexWhere((result) => result > 0.5);
        highestClass = skinClasses[highestClassIndex];
      });

      // Show the classification result dialog
      _showClassificationResultDialog(results);
    } catch (e) {
      // print('Error during inference: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showClassificationResultDialog(List<double> classificationResults) {
    highestClassIndex = classificationResults.indexOf(classificationResults.reduce((a, b) => a > b ? a : b));
    highestClass = skinClasses[highestClassIndex];

    setState(() {
      classificationCompleted = true;
      this.classificationResults = classificationResults;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Classification Result'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Class Scores:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                classificationResults.map((score) => score.toStringAsFixed(5)).join(', '),
              ),
              const SizedBox(height: 16),
              const Text(
                'Class Percentages:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: skinClasses.map((info) {
                  final index = skinClasses.indexOf(info);
                  return Text(
                    "${info.displayName}: ${(classificationResults[index] * 100).toStringAsFixed(2)}%",
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Image?'),
          content: const Text('Are you sure you want to delete this image?'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _pictureTaken = false;
                  classificationCompleted = false;
                  _selectedImage = null;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showSaveConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save Image?'),
          content: const Text('Do you want to save this image?'),
          actions: [
            TextButton(
              onPressed: () {
                // Implement saving functionality here
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // TODO_: Improve so that it zooms in and crops where a skin lesion is, not just the top of the camera view
  Widget _buildCroppedImage() {
    if (_selectedImage != null) {
      final file = File(_selectedImage!.path);
      final image = img.decodeImage(file.readAsBytesSync());

      // Ensure the image is a square
      final size = image!.width < image.height ? image.width : image.height;
      final croppedImage = img.copyCrop(
        image,
        0,
        0,
        size,
        size,
      );

      return Image.memory(
        Uint8List.fromList(img.encodeJpg(croppedImage)),
        width: 400,
        height: 400,
      );
    } else {
      return const Center(child: Text('Upload an image or take a picture to get started.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 17),
        ),
      ),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(15.0),
          children: <Widget>[
            _buildCroppedImage(),
            const SizedBox(height: 16),
            Visibility(
              visible: _selectedImage == null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: _pictureTaken ? null : _pickImage,
                      child: const Text('Choose Image'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: _pictureTaken ? null : _takePicture,
                      child: const Text('Take Picture'),
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: _pictureTaken,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _takePicture,
                    child: const Text('Retake'),
                  ),
                  const SizedBox(width: 16),
                  Visibility(
                    visible: !classificationCompleted,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _classifyImage,
                      child: const Text('Classify'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Visibility(
              visible: classificationCompleted,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Model\'s Guess:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  Text(
                    '${highestClass?.displayName ?? 'Unknown Class'}: ${(classificationResults != null && classificationResults!.isNotEmpty) ? (classificationResults![highestClassIndex] * 100).toStringAsFixed(2) : 'N/A'}%',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: classificationCompleted,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 15,
                  columns: const <DataColumn>[
                    DataColumn(
                      label: Text('Name'),
                    ),
                    DataColumn(
                      label: Text('Description'),
                    ),
                    DataColumn(
                      label: Text('Cancerous'),
                    ),
                  ],
                  rows: skinConditions.map((skinCondition) {
                    return DataRow(
                      cells: <DataCell>[
                        DataCell(Text(skinCondition.name)),
                        DataCell(
                          SizedBox(
                            width: 575,
                            child: Text(
                              skinCondition.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 200,
                            child: Text(
                              skinCondition.cancerous,
                              maxLines: 2,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 50),
            Visibility(
              visible: _selectedImage != null,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: _selectedImage == null ? null : _showDeleteConfirmationDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Delete', style: TextStyle(color: Colors.white)),
                    ),
                    ElevatedButton(
                      onPressed: _selectedImage == null ? null : _showSaveConfirmationDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Save', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Body Image Map',
          ),
        ],
        onTap: (index) {
          // Future Enhancements
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _pictureTaken ? _takePicture : null,
        tooltip: 'Take Picture',
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
