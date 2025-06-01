import 'package:guidini/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Blurred background image
          SizedBox.expand(
            child: Image.asset(
              'lib/assets/images/onboarding_screen.jpg', // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          Container(color: Colors.black.withOpacity(0.2)),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Icon(Icons.arrow_back,
                        color: AppColors.gray600, size: 24),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Reset password',
                    style: TextStyle(
                      color: AppColors.primary800,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Update your password to regain the access.',
                    style: TextStyle(
                      color: AppColors.gray600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomInputField(
                    hint: "",
                    controller: TextEditingController(),
                    label: 'Password',
                    obscureText: true,
                    prefixIcon:
                        Icon(Icons.lock_outline, color: AppColors.gray300),
                    suffixIcon:
                        Icon(Icons.visibility_off, color: AppColors.gray400),
                  ),
                  const SizedBox(height: 16),
                  CustomInputField(
                    hint: "",
                    controller: TextEditingController(),
                    label: 'Confirm password',
                    obscureText: true,
                    prefixIcon:
                        Icon(Icons.lock_outline, color: AppColors.gray300),
                    suffixIcon:
                        Icon(Icons.visibility_off, color: AppColors.gray400),
                  ),
                  const SizedBox(height: 24),
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
                      onPressed: () {},
                      child: const Text(
                        'Update password',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
