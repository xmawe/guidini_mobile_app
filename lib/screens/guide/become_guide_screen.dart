import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:guidini/constants/colors.dart';
import 'package:guidini/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:guidini/providers/user_role_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BecomeGuideScreen extends StatefulWidget {
  const BecomeGuideScreen({Key? key}) : super(key: key);

  @override
  State<BecomeGuideScreen> createState() => _BecomeGuideScreenState();
}

class _BecomeGuideScreenState extends State<BecomeGuideScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _alreadyApplied = false;

  // Form controllers
  final _bioController = TextEditingController();
  final _experienceController = TextEditingController();

  // Form data
  List<String> _selectedLanguages = [];
  File? _profileImageFile;
  File? _attestationImageFile;
  Uint8List? _profileImageBytes;
  Uint8List? _attestationImageBytes;

  // Available languages
  final List<String> _availableLanguages = [
    'English', 'French', 'Spanish', 'German', 'Italian',
    'Portuguese', 'Arabic', 'Chinese', 'Japanese', 'Russian',
    'Dutch', 'Korean', 'Hindi', 'Turkish', 'Swedish'
  ];

  @override
  void initState() {
    super.initState();
    _checkExistingApplication();
  }

  @override
  void dispose() {
    _bioController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _checkExistingApplication() async {
    try {
      final userData = await AuthService.getUserData();
      if (userData != null && userData['guide_application_status'] != null) {
        setState(() {
          _alreadyApplied = userData['guide_application_status'] == 'pending' ||
                           userData['guide_application_status'] == 'approved';
        });
      }
      // Update UserRoleProvider with the current state
      final roleProvider = Provider.of<UserRoleProvider>(context, listen: false);
      roleProvider.updateUserData(userData ?? {});
    } catch (e) {
      print('Error checking existing application: $e');
    }
  }

  Future<void> _pickImage(bool isProfilePicture) async {
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
                        if (isProfilePicture) {
                          _profileImageBytes = bytes;
                          if (!kIsWeb) _profileImageFile = File(image.path);
                        } else {
                          _attestationImageBytes = bytes;
                          if (!kIsWeb) _attestationImageFile = File(image.path);
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
                        if (isProfilePicture) {
                          _profileImageBytes = bytes;
                          if (!kIsWeb) _profileImageFile = File(image.path);
                        } else {
                          _attestationImageBytes = bytes;
                          if (!kIsWeb) _attestationImageFile = File(image.path);
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

  bool _hasImage(bool isProfilePicture) {
    if (isProfilePicture) {
      return kIsWeb ? _profileImageBytes != null : _profileImageFile != null;
    } else {
      return kIsWeb ? _attestationImageBytes != null : _attestationImageFile != null;
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
          content: Text('Please upload your guide attestation document'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get auth token
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Prepare multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${AuthService.baseUrl}/guide/register'),

      );

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Add form fields
      request.fields['biography'] = _bioController.text;
      request.fields['years_of_experience'] = _experienceController.text;
      
      // Add languages as JSON array
      for (int i = 0; i < _selectedLanguages.length; i++) {
        request.fields['languages[$i]'] = _selectedLanguages[i];
      }

      // Add profile picture if selected
      if (_hasImage(true)) {
        if (kIsWeb && _profileImageBytes != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'profile_picture',
              _profileImageBytes!,
              filename: 'profile_picture.jpg',
            ),
          );
        } else if (!kIsWeb && _profileImageFile != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'profile_picture',
              _profileImageFile!.path,
            ),
          );
        }
      }

      // Add attestation image (required)
      if (kIsWeb && _attestationImageBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'attestation_image',
            _attestationImageBytes!,
            filename: 'attestation.jpg',
          ),
        );
      } else if (!kIsWeb && _attestationImageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'attestation_image',
            _attestationImageFile!.path,
          ),
        );
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        // Success
        if (mounted) {
          setState(() {
            _alreadyApplied = true;
          });

          // Update role provider
          final roleProvider = Provider.of<UserRoleProvider>(context, listen: false);
          roleProvider.updateUserData({'guide_application_status': 'approved'});

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Guide registration successful!'),
              backgroundColor: AppColors.primary800,
              duration: const Duration(seconds: 3),
            ),
          );

          Navigator.pop(context, true);
        }
      } else {
        // Error
        throw Exception(responseData['message'] ?? 'Registration failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Guide Registration',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Fill out the form below to become a guide',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),

              // Profile Picture (Optional)
              const Text(
                'Profile Picture (Optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
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

              // Biography
              _buildTextField(
                controller: _bioController,
                label: 'Biography',
                maxLines: 4,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please write your biography';
                  }
                  if (value!.length < 50) {
                    return 'Biography should be at least 50 characters long';
                  }
                  if (value.length > 1000) {
                    return 'Biography should not exceed 1000 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Languages
              const Text(
                'Languages',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
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

              // Years of Experience
              _buildTextField(
                controller: _experienceController,
                label: 'Years of Experience',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your years of experience';
                  }
                  final experience = int.tryParse(value!);
                  if (experience == null || experience < 0 || experience > 50) {
                    return 'Please enter a valid number between 0 and 50';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Attestation Document (Required)
              const Text(
                'Guide Attestation Document *',
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
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
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
                          child: _buildImageWidget(_attestationImageBytes, _attestationImageFile),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              size: 48,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tap to upload document',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Supported formats: JPG, PNG',
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
                const SizedBox(height: 12),
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

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitApplication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary800,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Submit Application',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Information Note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[600],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Important Information',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Your application will be reviewed by our team\n'
                      '• You will be notified once approved\n'
                      '• All information provided must be accurate\n'
                      '• Upload clear, readable documents',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[700],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlreadyAppliedScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Guide Status'),
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
                'You are already a Guide!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Your guide application has been approved and you can now create tours and manage your guide profile.',
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