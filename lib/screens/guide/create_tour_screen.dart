import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:guidini/constants/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:guidini/widgets/forms/basic_info_step.dart';
import 'package:guidini/widgets/forms/activities_step.dart';
import 'package:guidini/widgets/forms/schedule_step.dart';
import 'package:guidini/widgets/forms/images_step.dart';
import 'package:guidini/widgets/forms/review_step.dart'; // Add this import
import 'package:guidini/models/activity_data.dart';
import 'package:guidini/models/tour_date_data.dart';
import 'package:guidini/config/app_config.dart';

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
  List<XFile> _selectedImages = [];

  // Activities and tour dates
  List<ActivityData> _activities = [ActivityData()];
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
        Uri.parse('${AppConfig.apiHost}/api/guide/tours/create'),
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
      case 4:
        // Review step - all previous validations should pass
        return _validateAllSteps();
      default:
        return true;
    }
  }

  bool _validateAllSteps() {
    // Validate basic info
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _durationController.text.isEmpty ||
        _maxGroupSizeController.text.isEmpty ||
        _selectedCityId == null) {
      return false;
    }

    // Validate activities
    final validActivities =
        _activities.where((activity) => activity.isValid()).toList();
    if (validActivities.isEmpty) return false;

    // Validate tour dates
    final validDates = _tourDates.where((date) => date.isValid()).toList();
    if (validDates.isEmpty) return false;

    // Validate images
    if (_selectedImages.isEmpty) return false;

    return true;
  }

  Future<void> _submitTour() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_validateAllSteps()) {
      _showErrorSnackBar('Please complete all required fields');
      return;
    }

    final validActivities =
        _activities.where((activity) => activity.isValid()).toList();
    if (validActivities.isEmpty) {
      _showErrorSnackBar('At least one complete activity is required');
      return;
    }

    final validDates = _tourDates.where((date) => date.isValid()).toList();
    if (validDates.isEmpty) {
      _showErrorSnackBar('At least one tour date is required');
      return;
    }

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

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.apiHost}/api/guide/tours'),
      );

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
        final xFile = _selectedImages[i];
        final bytes = await xFile.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'images[$i]',
          bytes,
          filename: xFile.name,
        ));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessSnackBar('Tour created successfully!');
        Navigator.pop(context);
      } else {
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
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
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
        case 4:
          message = 'Please complete all steps before creating the tour';
          break;
      }
      _showErrorSnackBar(message);
      return;
    }

    if (_currentStep < 4) {
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
        appBar: AppBar(title: const Text('Create Tour')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Create Tour'),
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (_currentStep > 0) {
                _previousStep();
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: Container(
          color: Colors.white,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Progress indicator
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    children: List.generate(5, (index) {
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          height: 4,
                          decoration: BoxDecoration(
                            color: index <= _currentStep
                                ? AppColors.primary800
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                // Step labels
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStepLabel('Basic Info', 0),
                      _buildStepLabel('Activities', 1),
                      _buildStepLabel('Schedule', 2),
                      _buildStepLabel('Images', 3),
                      _buildStepLabel('Review', 4),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Form content
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        BasicInfoStep(
                          titleController: _titleController,
                          descriptionController: _descriptionController,
                          priceController: _priceController,
                          durationController: _durationController,
                          maxGroupSizeController: _maxGroupSizeController,
                          cities: _cities,
                          selectedCityId: _selectedCityId,
                          availabilityStatus: _availabilityStatus,
                          isTransportIncluded: _isTransportIncluded,
                          isFoodIncluded: _isFoodIncluded,
                          onCityChanged: (value) =>
                              setState(() => _selectedCityId = value),
                          onAvailabilityChanged: (value) =>
                              setState(() => _availabilityStatus = value!),
                          onTransportChanged: (value) =>
                              setState(() => _isTransportIncluded = value!),
                          onFoodChanged: (value) =>
                              setState(() => _isFoodIncluded = value!),
                        ),
                        ActivitiesStep(
                          activities: _activities,
                          activityCategories: _activityCategories,
                          onActivitiesChanged: (updatedActivities) {
                            setState(() {
                              _activities = updatedActivities;
                            });
                          },
                        ),
                        ScheduleStep(
                          tourDates: _tourDates,
                          onTourDatesChanged: (updatedTourDates) {
                            setState(() {
                              _tourDates = updatedTourDates;
                            });
                          },
                        ),
                        ImagesStep(
                          selectedImages: _selectedImages,
                          onImagesChanged: (updatedImages) {
                            setState(() {
                              _selectedImages = updatedImages;
                            });
                          },
                          onShowError: _showErrorSnackBar,
                          onShowSuccess: _showSuccessSnackBar,
                        ),
                        ReviewStep(
                          title: _titleController.text,
                          description: _descriptionController.text,
                          price: _priceController.text,
                          duration: _durationController.text,
                          maxGroupSize: _maxGroupSizeController.text,
                          cities: _cities,
                          selectedCityId: _selectedCityId,
                          availabilityStatus: _availabilityStatus,
                          isTransportIncluded: _isTransportIncluded,
                          isFoodIncluded: _isFoodIncluded,
                          activities: _activities,
                          tourDates: _tourDates,
                          selectedImages: _selectedImages,
                          activityCategories: _activityCategories,
                        ),
                      ],
                    ),
                  ),
                ),
                // Navigation buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    children: [
                      if (_currentStep > 0)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _previousStep,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.primary800),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Previous',
                              style: TextStyle(color: AppColors.primary800),
                            ),
                          ),
                        ),
                      if (_currentStep > 0) const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary800,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _isLoading
                              ? null
                              : (_currentStep == 4 ? _submitTour : _nextStep),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _currentStep == 4 ? 'Create Tour' : 'Next',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildStepLabel(String label, int step) {
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;

    return Expanded(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive
              ? AppColors.primary800
              : isCompleted
                  ? Colors.green
                  : Colors.grey[600],
        ),
      ),
    );
  }
}
