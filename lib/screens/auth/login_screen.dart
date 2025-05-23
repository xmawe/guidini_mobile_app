import 'package:Guidini/components/custom_input_field.dart.dart';
import 'package:flutter/material.dart';
import '../../../colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

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
                    'Sign In',
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
                  CustomInputField(
                    hint: "",
                    controller: TextEditingController(),
                    label: 'Email',
                    prefixIcon:
                        Icon(Icons.email_outlined, color: AppColors.gray300),
                  ),
                  const SizedBox(height: 16),
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Forgot password',
                        style: TextStyle(
                          color: AppColors.primary800,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                        'Login',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  // const SizedBox(height: 12),
                  // SizedBox(
                  //   width: double.infinity,
                  //   height: 48,
                  //   child: OutlinedButton.icon(
                  //     icon: Image.asset(
                  //       'lib/assets/images/google.png',
                  //       height: 20,
                  //       width: 20,
                  //     ),
                  //     label: const Text(
                  //       'Sign In with Google',
                  //       style: TextStyle(
                  //           fontSize: 16, fontWeight: FontWeight.bold),
                  //     ),
                  //     style: OutlinedButton.styleFrom(
                  //       foregroundColor: AppColors.gray700,
                  //       backgroundColor: Colors.white,
                  //       side: BorderSide(color: AppColors.gray100),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(12),
                  //       ),
                  //     ),
                  //     onPressed: () {},
                  //   ),
                  // ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "You don't have an account? ",
                        style:
                            TextStyle(color: AppColors.gray600, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Sign Up',
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
        ],
      ),
    );
  }
}
