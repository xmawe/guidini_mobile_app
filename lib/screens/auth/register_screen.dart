import 'package:guidini/models/city.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../constants/colors.dart';
import 'package:guidini/widgets/custom_input_field.dart';
import 'package:guidini/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // Error messages for each field
  Map<String, String> _errors = {};

  List<City> _cities = [];
  int? _selectedCityId = 1;
  bool _isCitiesLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCities();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
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

      print('Cities API Status Code: ${response.statusCode}');
      print('Cities API Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Decoded data: $data');

        List<City> cities = [];

        // Handle different response structures
        if (data is List) {
          // If response is directly an array
          cities = data.map((cityJson) => City.fromJson(cityJson)).toList();
        } else if (data is Map && data.containsKey('cities')) {
          // If response has 'cities' key
          cities = (data['cities'] as List)
              .map((cityJson) => City.fromJson(cityJson))
              .toList();
        } else if (data is Map && data.containsKey('data')) {
          // If response has 'data' key
          cities = (data['data'] as List)
              .map((cityJson) => City.fromJson(cityJson))
              .toList();
        }

        print('Parsed cities count: ${cities.length}');
        if (cities.isNotEmpty) {
          print('First city: ${cities.first.name}');
        }

        setState(() {
          _cities = cities;
          _isCitiesLoading = false;
        });
      } else {
        print('Failed to load cities. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
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

  Future<void> _submitForm() async {
    // Clear previous errors
    setState(() {
      _errors.clear();
      _isLoading = true;
    });

    try {
      final result = await AuthService.register(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
        cityId: _selectedCityId!,
        password: _passwordController.text,
      );

      if (result['success']) {
        // Registration successful
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration successful!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to home screen
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        // Handle errors
        if (result['errors'] != null) {
          setState(() {
            _errors = Map<String, String>.from(result['errors'].map((key,
                    value) =>
                MapEntry(key, value is List ? value.first : value.toString())));
          });
        } else {
          // Show general error message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Registration failed'),
                backgroundColor: Colors.red,
              ),
            );
          }
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            // Background image with overlay
            SizedBox.expand(
              child: Image.asset(
                'lib/assets/images/onboarding_screen.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Container(color: Colors.black.withOpacity(0.2)),

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child:
                              Icon(Icons.arrow_back, color: AppColors.gray600),
                        ),
                        const SizedBox(height: 32),

                        Text(
                          "Sign up",
                          style: TextStyle(
                            color: AppColors.primary800,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Let locals lead the way.',
                          style: TextStyle(
                            color: AppColors.gray600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // First & Last Name
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomInputField(
                                    hint: "",
                                    label: 'First Name',
                                    controller: _firstNameController,
                                    prefixIcon: Icon(Icons.person_outline,
                                        color: AppColors.gray300),
                                    errorText: _errors['firstName'],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomInputField(
                                    hint: "",
                                    label: 'Last Name',
                                    controller: _lastNameController,
                                    errorText: _errors['lastName'],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Email
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomInputField(
                              hint: "",
                              label: 'Email',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icon(Icons.email_outlined,
                                  color: AppColors.gray300),
                              errorText: _errors['email'],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Phone
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomInputField(
                              hint: "",
                              label: 'Phone number',
                              controller: _phoneController,
                              prefixIcon: Icon(Icons.phone_outlined,
                                  color: AppColors.gray300),
                              keyboardType: TextInputType.phone,
                              errorText: _errors['phoneNumber'],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // City dropdown
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                        const SizedBox(height: 16),
                        // Password
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomInputField(
                              hint: "",
                              label: 'Password',
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              prefixIcon: Icon(Icons.lock_outline,
                                  color: AppColors.gray300),
                              errorText: _errors['password'],
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                child: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppColors.gray400,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Sign Up Button
                        SizedBox(
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
                            onPressed: _isLoading ? null : _submitForm,
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
                                    'Sign up',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Login link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "You already have an account? ",
                              style: TextStyle(
                                  color: AppColors.gray600, fontSize: 14),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacementNamed(
                                    context, '/login');
                              },
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  color: AppColors.primary800,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
