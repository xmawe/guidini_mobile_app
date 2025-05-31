import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CreateTourScreen extends StatefulWidget {
  const CreateTourScreen({Key? key}) : super(key: key);

  @override
  State<CreateTourScreen> createState() => _CreateTourScreenState();
}

class _CreateTourScreenState extends State<CreateTourScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isLoadingData = true;

  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _maxGroupSizeController = TextEditingController();

  // Dropdown data
  List<dynamic> _cities = [];
  List<dynamic> _activityCategories = [];

  // Form data
  int? _selectedCityId;
  String _availabilityStatus = 'available';
  bool _isTransportIncluded = false;
  bool _isFoodIncluded = false;

  // Images
  List<File> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();

  // Activities
  List<ActivityData> _activities = [ActivityData()];

  // Tour dates
  List<TourDateData> _tourDates = [TourDateData()];

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _maxGroupSizeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadDropdownData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('http://192.168.200.8:8000/api/tours'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _cities = data['data']['cities'];
          _activityCategories = data['data']['activityCategories'];
          _isLoadingData = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        _isLoadingData = false;
      });
      _showErrorSnackBar('Failed to load dropdown data: $e');
    }
  }

  // Updated _pickImages method with better error handling and fallback options

  Future<bool> _requestPermissions() async {
    // Check current permission status
    var cameraStatus = await Permission.camera.status;
    var storageStatus = await Permission.storage.status;
    var photosStatus = await Permission.photos.status;

    print('Camera permission: $cameraStatus');
    print('Storage permission: $storageStatus');
    print('Photos permission: $photosStatus');

    // Request permissions if not granted
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
      Permission.photos,
    ].request();

    bool cameraGranted =
        statuses[Permission.camera] == PermissionStatus.granted;
    bool storageGranted =
        statuses[Permission.storage] == PermissionStatus.granted ||
            statuses[Permission.photos] == PermissionStatus.granted;

    return cameraGranted && storageGranted;
  }

  Future<void> _handlePermissionDenied() async {
    bool shouldShowRationale =
        await Permission.camera.shouldShowRequestRationale ||
            await Permission.storage.shouldShowRequestRationale;

    if (shouldShowRationale) {
      _showPermissionDialog();
    } else {
      // User has permanently denied permissions, direct to settings
      _showSettingsDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permissions Required'),
          content: const Text(
              'This app needs camera and storage permissions to let you add photos to your tours. Please grant these permissions to continue.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _requestPermissions();
              },
              child: const Text('Grant Permissions'),
            ),
          ],
        );
      },
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Open Settings'),
          content: const Text(
              'Please go to Settings and enable camera and storage permissions for this app.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImages() async {
    print('_pickImages called');

    try {
      // Simplified permission check for debugging
      if (Platform.isAndroid) {
        // For Android 13+, use more specific permissions
        var status = await Permission.photos.request();
        if (!status.isGranted) {
          print('Photos permission denied: $status');
          _showErrorSnackBar('Photos permission is required');
          return;
        }
      } else if (Platform.isIOS) {
        var status = await Permission.photos.request();
        if (!status.isGranted) {
          print('Photos permission denied: $status');
          _showErrorSnackBar('Photos permission is required');
          return;
        }
      }

      print('Attempting to pick images...');

      // Try the simpler single image picker first for debugging
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      print('Image picker result: ${image?.path}');

      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
        print('Image added successfully');
        _showSuccessSnackBar('Image added successfully!');
      } else {
        print('No image selected');
      }
    } catch (e) {
      print('Error in _pickImages: $e');
      _showErrorSnackBar('Error picking image: $e');
    }
  }

  Future<void> _pickFromCamera() async {
    print('_pickFromCamera called');

    try {
      // Request camera permission
      var cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        print('Camera permission denied: $cameraStatus');
        _showErrorSnackBar('Camera permission is required');
        return;
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
        setState(() {
          _selectedImages.add(File(image.path));
        });
        print('Camera image added successfully');
        _showSuccessSnackBar('Photo taken successfully!');
      } else {
        print('No photo taken');
      }
    } catch (e) {
      print('Error in _pickFromCamera: $e');
      _showErrorSnackBar('Error taking photo: $e');
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
        setState(() {
          _selectedImages.add(File(image.path));
        });
        _showSuccessSnackBar('Image selected!');
      } else {
        print('No image selected');
      }
    } catch (e) {
      print('Direct picker error: $e');
      _showErrorSnackBar('Error: $e');
    }
  }

// Updated button widgets with debug information
  Widget _buildImagesStep() {
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

          // Debug button
          ElevatedButton(
            onPressed: () {
              print('Debug button pressed');
              _showSuccessSnackBar('Button is working!');
            },
            child: const Text('Test Button (Debug)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
          const SizedBox(height: 10),

          // Updated picker buttons with onPressed debug
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    print('Gallery button pressed');
                    _pickImageDirect(); // Use the simpler method first
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
          if (_selectedImages.isNotEmpty) ...[
            Text(
              'Selected Images (${_selectedImages.length})',
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
              itemCount: _selectedImages.length,
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
                        child: Image.file(
                          _selectedImages[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(Icons.error, color: Colors.red),
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

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  bool _validateStep() {
    switch (_currentStep) {
      case 0:
        return _titleController.text.isNotEmpty &&
            _descriptionController.text.isNotEmpty &&
            _priceController.text.isNotEmpty &&
            _durationController.text.isNotEmpty &&
            _maxGroupSizeController.text.isNotEmpty &&
            _selectedCityId != null;
      case 1:
        return _activities.any((activity) => activity.isValid());
      case 2:
        return _tourDates.any((date) => date.isValid());
      case 3:
        return _selectedImages.isNotEmpty;
      default:
        return true;
    }
  }

  Future<void> _submitTour() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate all steps
    if (!_validateStep()) {
      _showErrorSnackBar('Please complete all required fields');
      return;
    }

    // Validate activities
    final validActivities =
        _activities.where((activity) => activity.isValid()).toList();
    if (validActivities.isEmpty) {
      _showErrorSnackBar('At least one complete activity is required');
      return;
    }

    // Validate tour dates
    final validDates = _tourDates.where((date) => date.isValid()).toList();
    if (validDates.isEmpty) {
      _showErrorSnackBar('At least one tour date is required');
      return;
    }

    // Validate images
    if (_selectedImages.isEmpty) {
      _showErrorSnackBar('At least one tour image is required');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.200.8:8000/api/tours'),
      );

      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      // Add basic tour data
      request.fields['title'] = _titleController.text;
      request.fields['description'] = _descriptionController.text;
      request.fields['price'] = _priceController.text;
      request.fields['duration'] = _durationController.text;
      request.fields['max_group_size'] = _maxGroupSizeController.text;
      request.fields['city_id'] = _selectedCityId.toString();
      request.fields['availability_status'] = _availabilityStatus;
      request.fields['is_transport_included'] =
          _isTransportIncluded ? '1' : '0';
      request.fields['is_food_included'] = _isFoodIncluded ? '1' : '0';

      // Add activities
      for (int i = 0; i < validActivities.length; i++) {
        final activity = validActivities[i];
        request.fields['activities[$i][title]'] = activity.title!;
        request.fields['activities[$i][description]'] = activity.description!;
        request.fields['activities[$i][activity_category_id]'] =
            activity.categoryId.toString();
        request.fields['activities[$i][duration]'] =
            activity.duration.toString();

        if (activity.locationLabel?.isNotEmpty == true) {
          request.fields['activities[$i][location][label]'] =
              activity.locationLabel!;
        }
        if (activity.latitude?.isNotEmpty == true) {
          request.fields['activities[$i][location][latitude]'] =
              activity.latitude!;
        }
        if (activity.longitude?.isNotEmpty == true) {
          request.fields['activities[$i][location][longitude]'] =
              activity.longitude!;
        }
      }

      // Add tour dates
      for (int i = 0; i < validDates.length; i++) {
        final tourDate = validDates[i];
        request.fields['tour_dates[$i][day_of_week]'] =
            tourDate.dayOfWeek.toString();
        request.fields['tour_dates[$i][start_time]'] = tourDate.startTime!;
        request.fields['tour_dates[$i][end_time]'] = tourDate.endTime!;
      }

      // Add images
      for (int i = 0; i < _selectedImages.length; i++) {
        final file = _selectedImages[i];
        request.files.add(await http.MultipartFile.fromPath(
          'images[$i]',
          file.path,
        ));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessSnackBar('Tour created successfully!');
        Navigator.pop(context);
      } else {
        print('Response status: ${response.statusCode}');
        print('Response body: $responseBody');
        final errorData = json.decode(responseBody);
        throw Exception(errorData['message'] ?? 'Failed to create tour');
      }
    } catch (e) {
      _showErrorSnackBar('Error creating tour: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _nextStep() {
    if (!_validateStep()) {
      String message = '';
      switch (_currentStep) {
        case 0:
          message = 'Please fill in all basic information fields';
          break;
        case 1:
          message = 'Please add at least one complete activity';
          break;
        case 2:
          message = 'Please add at least one tour date';
          break;
        case 3:
          message = 'Please add at least one tour image';
          break;
      }
      _showErrorSnackBar(message);
      return;
    }

    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Create Tour'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Tour'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= _currentStep
                            ? Colors.blue
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            // Form content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildBasicInfoStep(),
                  _buildActivitiesStep(),
                  _buildScheduleStep(),
                  _buildImagesStep(),
                ],
              ),
            ),
            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        child: const Text('Previous'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : (_currentStep == 3 ? _submitTour : _nextStep),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(_currentStep == 3 ? 'Create Tour' : 'Next'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Basic Information',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Tour Title *',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value?.isEmpty ?? true ? 'Title is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description *',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Description is required' : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price *',
                    border: OutlineInputBorder(),
                    prefixText: '\$ ',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Price is required' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(
                    labelText: 'Duration (hours) *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Duration is required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _maxGroupSizeController,
                  decoration: const InputDecoration(
                    labelText: 'Max Group Size *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Max group size is required'
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _selectedCityId,
                  decoration: const InputDecoration(
                    labelText: 'City *',
                    border: OutlineInputBorder(),
                  ),
                  items: _cities.map<DropdownMenuItem<int>>((city) {
                    return DropdownMenuItem<int>(
                      value: city['id'],
                      child: Text(city['name']),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedCityId = value),
                  validator: (value) =>
                      value == null ? 'Please select a city' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _availabilityStatus,
            decoration: const InputDecoration(
              labelText: 'Availability Status',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'available', child: Text('Available')),
              DropdownMenuItem(
                  value: 'unavailable', child: Text('Unavailable')),
            ],
            onChanged: (value) => setState(() => _availabilityStatus = value!),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: const Text('Transport Included'),
                  value: _isTransportIncluded,
                  onChanged: (value) =>
                      setState(() => _isTransportIncluded = value!),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  title: const Text('Food Included'),
                  value: _isFoodIncluded,
                  onChanged: (value) =>
                      setState(() => _isFoodIncluded = value!),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Activities *',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _activities.add(ActivityData());
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Activity'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'At least one complete activity is required',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _activities.length,
            itemBuilder: (context, index) {
              return _buildActivityCard(index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(int index) {
    final activity = _activities[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Activity ${index + 1}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    if (activity.isValid())
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    if (_activities.length > 1)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _activities.removeAt(index);
                          });
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: activity.title,
              decoration: const InputDecoration(
                labelText: 'Activity Title *',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => activity.title = value),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: activity.description,
              decoration: const InputDecoration(
                labelText: 'Activity Description *',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) =>
                  setState(() => activity.description = value),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: activity.categoryId,
                    decoration: const InputDecoration(
                      labelText: 'Category *',
                      border: OutlineInputBorder(),
                    ),
                    items: _activityCategories
                        .map<DropdownMenuItem<int>>((category) {
                      return DropdownMenuItem<int>(
                        value: category['id'],
                        child: Text(category['name']),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => activity.categoryId = value),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: activity.duration?.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Duration (min) *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) =>
                        setState(() => activity.duration = int.tryParse(value)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Location (Optional)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: activity.locationLabel,
              decoration: const InputDecoration(
                labelText: 'Location Label',
                border: OutlineInputBorder(),
                hintText: 'e.g., Jemaa el-Fnaa, Marrakech Medina',
              ),
              onChanged: (value) =>
                  setState(() => activity.locationLabel = value),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: activity.latitude,
                    decoration: const InputDecoration(
                      labelText: 'Latitude',
                      border: OutlineInputBorder(),
                      hintText: '31.625969',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) =>
                        setState(() => activity.latitude = value),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: activity.longitude,
                    decoration: const InputDecoration(
                      labelText: 'Longitude',
                      border: OutlineInputBorder(),
                      hintText: '-7.989226',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) =>
                        setState(() => activity.longitude = value),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tour Schedule *',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _tourDates.add(TourDateData());
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Schedule'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'At least one tour schedule is required',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _tourDates.length,
            itemBuilder: (context, index) {
              return _buildScheduleCard(index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(int index) {
    final tourDate = _tourDates[index];
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Schedule ${index + 1}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    if (tourDate.isValid())
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    if (_tourDates.length > 1)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _tourDates.removeAt(index);
                          });
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: tourDate.dayOfWeek,
              decoration: const InputDecoration(
                labelText: 'Day of Week *',
                border: OutlineInputBorder(),
              ),
              items: days.asMap().entries.map<DropdownMenuItem<int>>((entry) {
                return DropdownMenuItem<int>(
                  value: entry.key + 1,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) => setState(() => tourDate.dayOfWeek = value),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: tourDate.startTime,
                    decoration: const InputDecoration(
                      labelText: 'Start Time (HH:MM) *',
                      border: OutlineInputBorder(),
                      hintText: '09:00',
                    ),
                    onChanged: (value) =>
                        setState(() => tourDate.startTime = value),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: tourDate.endTime,
                    decoration: const InputDecoration(
                      labelText: 'End Time (HH:MM) *',
                      border: OutlineInputBorder(),
                      hintText: '17:00',
                    ),
                    onChanged: (value) =>
                        setState(() => tourDate.endTime = value),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Helper classes for activity and tour date data

class ActivityData {
  String? title;
  String? description;
  int? categoryId;
  int? duration;
  String? locationLabel;
  String? latitude;
  String? longitude;

  ActivityData({
    this.title,
    this.description,
    this.categoryId,
    this.duration,
    this.locationLabel,
    this.latitude,
    this.longitude,
  });

  bool isValid() {
    return (title?.isNotEmpty ?? false) &&
        (description?.isNotEmpty ?? false) &&
        categoryId != null &&
        duration != null;
  }
}

class TourDateData {
  int? dayOfWeek;
  String? startTime;
  String? endTime;

  TourDateData({
    this.dayOfWeek,
    this.startTime,
    this.endTime,
  });

  bool isValid() {
    return dayOfWeek != null &&
        (startTime?.isNotEmpty ?? false) &&
        (endTime?.isNotEmpty ?? false);
  }
}
