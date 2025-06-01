import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:guidini/constants/colors.dart';
import 'package:guidini/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:guidini/providers/user_role_provider.dart'; // Add this import

class BecomeGuideScreen extends StatefulWidget {
  const BecomeGuideScreen({Key? key}) : super(key: key);

  @override
  State<BecomeGuideScreen> createState() => _BecomeGuideScreenState();
}

class _BecomeGuideScreenState extends State<BecomeGuideScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;
  bool _alreadyApplied = false;

  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  final _experienceController = TextEditingController();

  // Form data
  List<String> _selectedLanguages = [];
  File? _profileImageFile;
  File? _certificationImageFile;
  Uint8List? _profileImageBytes;
  Uint8List? _certificationImageBytes;
  String? _selectedCity;
  double _rating = 0.0;
  bool _isVerified = false;

  // Available data
  final List<String> _availableLanguages = [
    'English', 'French', 'Spanish', 'German', 'Italian',
    'Portuguese', 'Arabic', 'Chinese', 'Japanese', 'Russian'
  ];

  final List<String> _availableCities = [
    'Paris', 'London', 'New York', 'Tokyo', 'Berlin',
    'Rome', 'Barcelona', 'Amsterdam', 'Prague', 'Vienna'
  ];

  @override
  void initState() {
    super.initState();
    _checkExistingApplication();
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _experienceController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _checkExistingApplication() async {
    try {
      final userData = await AuthService.getUserData();
      if (userData != null && userData['guide_application_status'] != null) {
        setState(() {
          _alreadyApplied = userData['guide_application_status'] == 'pending' ||
                           userData['guide_application_status'] == 'in_review';
        });
      }
      // Update UserRoleProvider with the current state
      final roleProvider = Provider.of<UserRoleProvider>(context, listen: false);
      roleProvider.updateUserData(userData ?? {});
    } catch (e) {
      print('Error checking existing application: $e');
    }
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await AuthService.getUserData();
      if (userData != null) {
        setState(() {
          _firstNameController.text = userData['firstName'] ?? '';
          _lastNameController.text = userData['lastName'] ?? '';
          _emailController.text = userData['email'] ?? '';
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _pickImage(bool isProfile) async {
    try {
      final ImagePicker picker = ImagePicker();

      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 1080,
                      maxHeight: 1080,
                      imageQuality: 85,
                    );
                    if (image != null) {
                      final bytes = await image.readAsBytes();
                      setState(() {
                        if (isProfile) {
                          _profileImageBytes = bytes;
                          if (!kIsWeb) _profileImageFile = File(image.path);
                        } else {
                          _certificationImageBytes = bytes;
                          if (!kIsWeb) _certificationImageFile = File(image.path);
                        }
                      });
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Camera'),
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 1080,
                      maxHeight: 1080,
                      imageQuality: 85,
                    );
                    if (image != null) {
                      final bytes = await image.readAsBytes();
                      setState(() {
                        if (isProfile) {
                          _profileImageBytes = bytes;
                          if (!kIsWeb) _profileImageFile = File(image.path);
                        } else {
                          _certificationImageBytes = bytes;
                          if (!kIsWeb) _certificationImageFile = File(image.path);
                        }
                      });
                    }
                  },
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildImageWidget(Uint8List? imageBytes, File? imageFile) {
    if (kIsWeb && imageBytes != null) {
      return Image.memory(
        imageBytes,
        fit: BoxFit.cover,
      );
    } else if (!kIsWeb && imageFile != null) {
      return Image.file(
        imageFile,
        fit: BoxFit.cover,
      );
    }
    return const SizedBox.shrink();
  }

  bool _hasImage(bool isProfile) {
    if (isProfile) {
      return kIsWeb ? _profileImageBytes != null : _profileImageFile != null;
    } else {
      return kIsWeb ? _certificationImageBytes != null : _certificationImageFile != null;
    }
  }

  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Languages'),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  itemCount: _availableLanguages.length,
                  itemBuilder: (context, index) {
                    final language = _availableLanguages[index];
                    final isSelected = _selectedLanguages.contains(language);

                    return CheckboxListTile(
                      title: Text(language),
                      value: isSelected,
                      activeColor: AppColors.primary800,
                      onChanged: (bool? value) {
                        setDialogState(() {
                          if (value == true) {
                            _selectedLanguages.add(language);
                          } else {
                            _selectedLanguages.remove(language);
                          }
                        });
                        setState(() {});
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Done',
                    style: TextStyle(color: AppColors.primary800),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedLanguages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one language'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_hasImage(false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload your certification document'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare application data
      final applicationData = {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'bio': _bioController.text,
        'location': _locationController.text,
        'experience': _experienceController.text,
        'languages': _selectedLanguages,
        'city': _selectedCity,
        'profileImage': _profileImageBytes, // Upload to storage in backend
        'certificationImage': _certificationImageBytes, // Upload to storage in backend
        'status': 'pending',
      };

      // Submit to backend
      // TODO: Replace with actual API call
      // Example: await AuthService.submitGuideApplication(applicationData);
      await Future.delayed(const Duration(seconds: 2));

      // Update local state
      if (mounted) {
        setState(() {
          _alreadyApplied = true;
        });

        // Do NOT enable guide role here; wait for admin approval
        final roleProvider = Provider.of<UserRoleProvider>(context, listen: false);
        roleProvider.updateUserData({'guide_application_status': 'pending'}); // Reflect pending status

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Your guide application has been submitted. Please wait for admin confirmation.',
            ),
            backgroundColor: AppColors.primary800,
            duration: const Duration(seconds: 3),
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting application: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleProvider = Provider.of<UserRoleProvider>(context, listen: false);
    if (_alreadyApplied || roleProvider.currentRole == UserRole.guide) {
      return _buildAlreadyAppliedScreen();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Become a Guide'),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        backgroundColor: AppColors.primary800,
        foregroundColor: Colors.white,
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
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? AppColors.primary800
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildPersonalInfoPage(),
                  _buildProfessionalInfoPage(),
                  _buildDocumentsPage(),
                ],
              ),
            ),

            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.primary800),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Previous',
                          style: TextStyle(color: AppColors.primary800),
                        ),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : (_currentPage == 2 ? _submitApplication : _nextPage),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary800,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              _currentPage == 2 ? 'Submit Application' : 'Next',
                              style: const TextStyle(color: Colors.white),
                            ),
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

  Widget _buildAlreadyAppliedScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Guide Application'),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        backgroundColor: AppColors.primary800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary800.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  size: 50,
                  color: AppColors.primary800,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Application Already Submitted',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'You already filled this form. Please wait for admin confirmation.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary800,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text(
                  'Go Back',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about yourself',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // Profile Image
          Center(
            child: GestureDetector(
              onTap: () => _pickImage(true),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                ),
                child: _hasImage(true)
                    ? ClipOval(
                        child: _buildImageWidget(_profileImageBytes, _profileImageFile),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 32,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add Photo',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // First Name
          _buildTextField(
            controller: _firstNameController,
            label: 'First Name',
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter your first name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Last Name
          _buildTextField(
            controller: _lastNameController,
            label: 'Last Name',
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter your last name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Email
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Phone Number
          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number',
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter your phone number';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Professional Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about your expertise',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // Bio
          _buildTextField(
            controller: _bioController,
            label: 'Professional Bio',
            maxLines: 4,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please write a brief bio about yourself';
              }
              if (value!.length < 50) {
                return 'Bio should be at least 50 characters long';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // City Selection
          DropdownButtonFormField<String>(
            value: _selectedCity,
            decoration: InputDecoration(
              labelText: 'Primary City',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary800),
              ),
            ),
            items: _availableCities.map((city) {
              return DropdownMenuItem(
                value: city,
                child: Text(city),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCity = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select your primary city';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Languages
          GestureDetector(
            onTap: _showLanguageSelector,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Languages',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (_selectedLanguages.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: _selectedLanguages.map((language) {
                              return Chip(
                                label: Text(
                                  language,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor:
                                    AppColors.primary800.withOpacity(0.1),
                                labelStyle: TextStyle(color: AppColors.primary800),
                                deleteIcon: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: AppColors.primary800,
                                ),
                                onDeleted: () {
                                  setState(() {
                                    _selectedLanguages.remove(language);
                                  });
                                },
                              );
                            }).toList(),
                          )
                        else
                          Text(
                            'Select languages you speak',
                            style: TextStyle(
                              color: Colors.grey[500],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Experience
          _buildTextField(
            controller: _experienceController,
            label: 'Years of Experience',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter your years of experience';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Documents & Verification',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload your certification documents',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // Certification Document
          const Text(
            'Certification Document',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload your guide license, tourism certification, or relevant qualification document',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),

          GestureDetector(
            onTap: () => _pickImage(false),
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: _hasImage(false)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child:
                          _buildImageWidget(_certificationImageBytes, _certificationImageFile),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 48,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tap to upload document',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Supported formats: JPG, PNG, PDF',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          if (_hasImage(false)) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Document uploaded successfully',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _pickImage(false),
                  child: Text(
                    'Change',
                    style: TextStyle(color: AppColors.primary800),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 32),

          // Terms and Conditions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Important Information',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '• Your application will be reviewed within 2-3 business days\n'
                  '• You will receive an email confirmation once approved\n'
                  '• All information provided must be accurate and verifiable\n'
                  '• You can track your application status in your profile',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary800),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}