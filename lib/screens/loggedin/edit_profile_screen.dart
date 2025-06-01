import 'package:flutter/material.dart';
import 'package:guidini/models/city.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../constants/colors.dart';
import 'package:guidini/widgets/custom_input_field.dart';
import 'package:guidini/services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingProfile = true;
  bool _isCitiesLoading = true;

  // Error messages for each field
  Map<String, String> _errors = {};

  List<City> _cities = [];
  int? _selectedCityId;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _fetchCities();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userData = await AuthService.getUserData();
      if (userData != null) {
        setState(() {
          _userData = userData;
          _firstNameController.text = userData['firstName'] ?? '';
          _lastNameController.text = userData['lastName'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _phoneController.text = userData['phoneNumber'] ?? '';
          // Handle different possible field names for city ID
          _selectedCityId = userData['cityId'] ??
              userData['city_id'] ??
              userData['city']?['id'];
          _isLoadingProfile = false;
        });
        print('Loaded user city ID: $_selectedCityId'); // Debug log
      } else {
        setState(() {
          _isLoadingProfile = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to load profile data'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error loading profile: $e');
      setState(() {
        _isLoadingProfile = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _fetchCities() async {
    setState(() {
      _isCitiesLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://192.168.200.8:8000/api/cities'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<City> cities = [];

        // Handle different response structures
        if (data is List) {
          cities = data.map((cityJson) => City.fromJson(cityJson)).toList();
        } else if (data is Map && data.containsKey('cities')) {
          cities = (data['cities'] as List)
              .map((cityJson) => City.fromJson(cityJson))
              .toList();
        } else if (data is Map && data.containsKey('data')) {
          cities = (data['data'] as List)
              .map((cityJson) => City.fromJson(cityJson))
              .toList();
        }

        setState(() {
          _cities = cities;
          _isCitiesLoading = false;
          // Ensure the selected city ID is valid after cities are loaded
          if (_selectedCityId != null &&
              !cities.any((city) => city.id == _selectedCityId)) {
            print('Selected city ID $_selectedCityId not found in cities list');
            _selectedCityId = cities.isNotEmpty ? cities.first.id : null;
          }
        });
        print(
            'Loaded ${cities.length} cities, selected city ID: $_selectedCityId');
      } else {
        setState(() {
          _isCitiesLoading = false;
        });
        throw Exception('Failed to load cities');
      }
    } catch (e) {
      print('Error fetching cities: $e');
      setState(() {
        _isCitiesLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load cities: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _errors.clear();
      _isLoading = true;
    });

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('http://192.168.200.8:8000/api/user/edit/personal'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'email': _emailController.text,
          'phoneNumber': _phoneController.text,
          'cityId': _selectedCityId,
        }),
      );

      if (response.body.isEmpty) {
        throw Exception('Empty response from server');
      }

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final updatedUserData = responseData['data'];

        await AuthService.saveUserData(
          token: token,
          userData: updatedUserData,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  responseData['message'] ?? 'Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } else {
        if (responseData is Map && responseData['errors'] != null) {
          setState(() {
            _errors = Map<String, String>.from(
              responseData['errors'].map(
                (key, value) => MapEntry(
                  key,
                  value is List ? value.first.toString() : value.toString(),
                ),
              ),
            );
          });
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message'] ?? 'Update failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error: ${e.toString()}'),
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

  String _getInitials(String firstName, String lastName) {
    String firstInitial =
        firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    String lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfile) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Edit Profile'),
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
          child: CircularProgressIndicator(
            color: AppColors.primary800,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        backgroundColor: AppColors.primary800,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Remove the save button from app bar
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Header
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Avatar with initials
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primary800,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _getInitials(_firstNameController.text,
                                  _lastNameController.text),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Change Profile Picture',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.primary800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Form Section
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(
                          //   'Personal Information',
                          //   style: TextStyle(
                          //     fontSize: 16,
                          //     fontWeight: FontWeight.w500,
                          //     color: Colors.grey[700],
                          //   ),
                          // ),
                          // const SizedBox(height: 20),
                          // First & Last Name
                          Row(
                            children: [
                              Expanded(
                                child: CustomInputField(
                                  hint: "",
                                  label: 'First Name',
                                  controller: _firstNameController,
                                  prefixIcon: Icon(Icons.person_outline,
                                      color: AppColors.gray300),
                                  errorText: _errors['firstName'],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: CustomInputField(
                                  hint: "",
                                  label: 'Last Name',
                                  controller: _lastNameController,
                                  errorText: _errors['lastName'],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Email
                          CustomInputField(
                            hint: "",
                            label: 'Email',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icon(Icons.email_outlined,
                                color: AppColors.gray300),
                            errorText: _errors['email'],
                          ),
                          const SizedBox(height: 16),

                          // Phone
                          CustomInputField(
                            hint: "",
                            label: 'Phone number',
                            controller: _phoneController,
                            prefixIcon: Icon(Icons.phone_outlined,
                                color: AppColors.gray300),
                            keyboardType: TextInputType.phone,
                            errorText: _errors['phoneNumber'],
                          ),
                          const SizedBox(height: 16),

                          // City dropdown
                          DropdownButtonFormField<int>(
                            value: _selectedCityId,
                            decoration: customInputDecoration(
                              label: 'City',
                              prefixIcon: Icon(Icons.map_outlined,
                                  color: AppColors.gray300),
                              errorText: _errors['cityId'],
                            ),
                            hint: Text(
                              _isCitiesLoading
                                  ? 'Loading cities...'
                                  : _cities.isEmpty
                                      ? 'No cities available'
                                      : 'Select a city',
                              style: TextStyle(color: AppColors.gray400),
                            ),
                            items: _cities.isEmpty
                                ? null
                                : _cities.map((city) {
                                    return DropdownMenuItem<int>(
                                      value: city.id,
                                      child: Text(city.name),
                                    );
                                  }).toList(),
                            onChanged: (_cities.isEmpty || _isCitiesLoading)
                                ? null
                                : (int? value) {
                                    setState(() {
                                      _selectedCityId = value;
                                    });
                                  },
                          ),
                          if (_isCitiesLoading)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary800,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Loading cities...',
                                    style: TextStyle(
                                      color: AppColors.gray400,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (!_isCitiesLoading && _cities.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline,
                                      size: 14, color: Colors.orange),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Failed to load cities. Tap to retry.',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: _fetchCities,
                                    child: Text(
                                      'Retry',
                                      style: TextStyle(
                                        color: AppColors.primary800,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 100), // Add space for the fixed button
                ],
              ),
            ),
          ),

          // Fixed Update Button at Bottom
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary800,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : _updateProfile,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Update Profile',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
