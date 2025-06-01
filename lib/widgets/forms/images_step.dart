import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class ImagesStep extends StatefulWidget {
  final List<XFile> selectedImages;
  final Function(List<XFile>) onImagesChanged;
  final Function(String) onShowError;
  final Function(String) onShowSuccess;

  const ImagesStep({
    Key? key,
    required this.selectedImages,
    required this.onImagesChanged,
    required this.onShowError,
    required this.onShowSuccess,
  }) : super(key: key);

  @override
  State<ImagesStep> createState() => _ImagesStepState();
}

class _ImagesStepState extends State<ImagesStep> {
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickImages() async {
    print('_pickImages called');

    try {
      // Simplified permission check for mobile platforms
      if (!kIsWeb) {
        if (Platform.isAndroid) {
          var status = await Permission.photos.request();
          if (!status.isGranted) {
            print('Photos permission denied: $status');
            widget.onShowError('Photos permission is required');
            return;
          }
        } else if (Platform.isIOS) {
          var status = await Permission.photos.request();
          if (!status.isGranted) {
            print('Photos permission denied: $status');
            widget.onShowError('Photos permission is required');
            return;
          }
        }
      }

      print('Attempting to pick images...');

      // Pick single image (works on both web and mobile)
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      print('Image picker result: ${image?.path}');

      if (image != null) {
        final updatedImages = List<XFile>.from(widget.selectedImages);
        updatedImages.add(image);
        widget.onImagesChanged(updatedImages);
        print('Image added successfully');
        widget.onShowSuccess('Image added successfully!');
      } else {
        print('No image selected');
      }
    } catch (e) {
      print('Error in _pickImages: $e');
      widget.onShowError('Error picking image: $e');
    }
  }

  Future<void> _pickFromCamera() async {
    print('_pickFromCamera called');

    try {
      // Request camera permission (skip on web)
      if (!kIsWeb) {
        var cameraStatus = await Permission.camera.request();
        if (!cameraStatus.isGranted) {
          print('Camera permission denied: $cameraStatus');
          widget.onShowError('Camera permission is required');
          return;
        }
      }

      print('Attempting to take photo...');

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      print('Camera result: ${image?.path}');

      if (image != null) {
        final updatedImages = List<XFile>.from(widget.selectedImages);
        updatedImages.add(image);
        widget.onImagesChanged(updatedImages);
        print('Camera image added successfully');
        widget.onShowSuccess('Photo taken successfully!');
      } else {
        print('No photo taken');
      }
    } catch (e) {
      print('Error in _pickFromCamera: $e');
      widget.onShowError('Error taking photo: $e');
    }
  }

  // Alternative method using a more direct approach
  Future<void> _pickImageDirect() async {
    try {
      print('Direct image picker called');

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        print('Image selected: ${image.path}');
        final updatedImages = List<XFile>.from(widget.selectedImages);
        updatedImages.add(image);
        widget.onImagesChanged(updatedImages);
        widget.onShowSuccess('Image selected!');
      } else {
        print('No image selected');
      }
    } catch (e) {
      print('Direct picker error: $e');
      widget.onShowError('Error: $e');
    }
  }

  void _removeImage(int index) {
    final updatedImages = List<XFile>.from(widget.selectedImages);
    updatedImages.removeAt(index);
    widget.onImagesChanged(updatedImages);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tour Images *',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'At least one image is required',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 20),

          // Updated picker buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    print('Gallery button pressed');
                    _pickImageDirect();
                  },
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    print('Camera button pressed');
                    _pickFromCamera();
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          if (widget.selectedImages.isNotEmpty) ...[
            Text(
              'Selected Images (${widget.selectedImages.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: widget.selectedImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: kIsWeb
                            ? Image.network(
                                widget.selectedImages[index].path,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child:
                                          Icon(Icons.error, color: Colors.red),
                                    ),
                                  );
                                },
                              )
                            : Image.file(
                                File(widget.selectedImages[index].path),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child:
                                          Icon(Icons.error, color: Colors.red),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ] else ...[
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No images selected',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
