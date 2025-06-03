import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../constants/colors.dart';
import 'package:guidini/widgets/custom_input_field.dart';
import 'package:guidini/services/auth_service.dart';
import 'package:guidini/config/app_config.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // Error messages for each field
  Map<String, String> _errors = {};

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validatePasswords() {
    _errors.clear();
    bool isValid = true;

    // Check if current password is empty
    if (_currentPasswordController.text.isEmpty) {
      _errors['currentPassword'] = 'Current password is required';
      isValid = false;
    }

    // Check if new password is empty
    if (_newPasswordController.text.isEmpty) {
      _errors['newPassword'] = 'New password is required';
      isValid = false;
    } else {
      // Check password strength
      if (_newPasswordController.text.length < 8) {
        _errors['newPassword'] = 'Password must be at least 8 characters';
        isValid = false;
      }
    }

    // Check if confirm password matches
    if (_confirmPasswordController.text.isEmpty) {
      _errors['confirmPassword'] = 'Please confirm your password';
      isValid = false;
    } else if (_newPasswordController.text != _confirmPasswordController.text) {
      _errors['confirmPassword'] = 'Passwords do not match';
      isValid = false;
    }

    // Check if new password is same as current password
    if (_currentPasswordController.text.isNotEmpty &&
        _newPasswordController.text.isNotEmpty &&
        _currentPasswordController.text == _newPasswordController.text) {
      _errors['newPassword'] =
          'New password must be different from current password';
      isValid = false;
    }

    return isValid;
  }

  Future<void> _changePassword() async {
    // Clear previous errors and validate
    setState(() {
      _errors.clear();
    });

    if (!_validatePasswords()) {
      setState(() {});
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('${AppConfig.apiHost}/api/user/edit/security'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'currentPassword': _currentPasswordController.text,
          'newPassword': _newPasswordController.text,
          'newPassword_confirmation': _confirmPasswordController.text,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Password change successful
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password changed successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back to profile settings
          Navigator.pop(context, true);
        }
      } else {
        // Handle errors
        if (responseData['errors'] != null) {
          setState(() {
            _errors = Map<String, String>.from(responseData['errors'].map((key,
                    value) =>
                MapEntry(key, value is List ? value.first : value.toString())));
          });
        } else {
          // Show general error message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(responseData['message'] ?? 'Password change failed'),
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Change Password'),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        backgroundColor: AppColors.primary800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header Section
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Security Icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primary800.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.security,
                            size: 40,
                            color: AppColors.primary800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Update Your Password',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Choose a strong password to keep your account secure',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
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
                          //   'Password Information',
                          //   style: TextStyle(
                          //     fontSize: 16,
                          //     fontWeight: FontWeight.w500,
                          //     color: Colors.grey[700],
                          //   ),
                          // ),
                          // const SizedBox(height: 20),
                          // Current Password
                          CustomInputField(
                            hint: "",
                            label: 'Current Password',
                            controller: _currentPasswordController,
                            obscureText: _obscureCurrentPassword,
                            prefixIcon: Icon(Icons.lock_outline,
                                color: AppColors.gray300),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureCurrentPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.gray300,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureCurrentPassword =
                                      !_obscureCurrentPassword;
                                });
                              },
                            ),
                            errorText: _errors['currentPassword'],
                          ),
                          const SizedBox(height: 16),

                          // New Password
                          CustomInputField(
                            hint: "",
                            label: 'New Password',
                            controller: _newPasswordController,
                            obscureText: _obscureNewPassword,
                            prefixIcon: Icon(Icons.lock_outline,
                                color: AppColors.gray300),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureNewPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.gray300,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureNewPassword = !_obscureNewPassword;
                                });
                              },
                            ),
                            errorText: _errors['newPassword'],
                          ),
                          const SizedBox(height: 8),

                          // Password Requirements
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Password Requirements:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      _newPasswordController.text.length >= 8
                                          ? Icons.check_circle
                                          : Icons.radio_button_unchecked,
                                      size: 12,
                                      color:
                                          _newPasswordController.text.length >=
                                                  8
                                              ? Colors.green
                                              : Colors.grey[400],
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'At least 8 characters',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Confirm Password
                          CustomInputField(
                            hint: "",
                            label: 'Confirm New Password',
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            prefixIcon: Icon(Icons.lock_outline,
                                color: AppColors.gray300),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.gray300,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                            errorText: _errors['confirmPassword'],
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

          // Fixed Change Password Button at Bottom
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
                  onPressed: _isLoading ? null : _changePassword,
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
                          'Change Password',
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
