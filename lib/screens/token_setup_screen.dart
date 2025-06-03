import 'package:flutter/material.dart';
import '../services/token_service.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';
import '../services/service_provider.dart';
import '../constants/colors.dart';

class TokenSetupScreen extends StatefulWidget {
  const TokenSetupScreen({Key? key}) : super(key: key);

  @override
  State<TokenSetupScreen> createState() => _TokenSetupScreenState();
}

class _TokenSetupScreenState extends State<TokenSetupScreen> {
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  final ChatService _chatService = ServiceProvider().getChatService();
  final AuthService _authService = ServiceProvider().getAuthService();
  
  String? _currentToken;
  bool _isLoading = true;
  bool _isLoginLoading = false;
  String? _loginError;

  @override
  void initState() {
    super.initState();
    _loadCurrentToken();
  }

  Future<void> _loadCurrentToken() async {
    final token = await TokenService.getToken();
    setState(() {
      _currentToken = token;
      if (token != null) {
        _tokenController.text = token;
      }
      _isLoading = false;
    });
  }

  Future<void> _saveToken() async {
    final token = _tokenController.text.trim();
    if (token.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      
      await TokenService.setTestToken(token);
      _chatService.setToken(token);
      
      setState(() {
        _currentToken = token;
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token saved successfully')),
      );
    }
  }

  Future<void> _clearToken() async {
    setState(() {
      _isLoading = true;
    });
    
    await TokenService.clearToken();
    _tokenController.clear();
    
    setState(() {
      _currentToken = null;
      _isLoading = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Token cleared')),
    );
  }
  
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _loginError = 'Please enter both email and password';
      });
      return;
    }
    
    setState(() {
      _isLoginLoading = true;
      _loginError = null;
    });
    
    try {
      final result = await _authService.login(email, password);
      
      if (result['success'] == true) {
        // Update online status
        await _authService.updateLastActivity();
        
        setState(() {
          _currentToken = result['token'];
          _isLoginLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful')),
        );
        
        // Navigate to chat list
        Navigator.pushReplacementNamed(context, '/chat_list');
      } else {
        setState(() {
          _loginError = result['message'] ?? 'Login failed';
          _isLoginLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _loginError = e.toString();
        _isLoginLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login / Setup'),
        backgroundColor: AppColors.primary800,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Login Section
                  const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Login with your email and password',
                    style: TextStyle(
                      color: AppColors.gray600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      hintText: 'Enter your email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      hintText: 'Enter your password',
                    ),
                    obscureText: true,
                  ),
                  if (_loginError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _loginError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoginLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary800,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: _isLoginLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Login'),
                  ),
                  
                  const Divider(height: 40),
                  
                  // Token Setup Section
                  const Text(
                    'Manual Token Setup',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter your API token for testing the chat functionality',
                    style: TextStyle(
                      color: AppColors.gray600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _tokenController,
                    decoration: InputDecoration(
                      labelText: 'API Token',
                      border: OutlineInputBorder(),
                      hintText: 'Enter your API token here',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _tokenController.clear(),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveToken,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary800,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Save Token'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _clearToken,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary800,
                            side: const BorderSide(color: AppColors.primary800),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Clear Token'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Current Token Status:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _currentToken != null
                          ? AppColors.primary050
                          : AppColors.gray100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _currentToken != null
                          ? 'Token is set and ready to use'
                          : 'No token set',
                      style: TextStyle(
                        color: _currentToken != null
                            ? AppColors.primary800
                            : AppColors.gray600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _currentToken != null
                        ? () {
                            Navigator.pushReplacementNamed(context, '/chat_list');
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary800,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Go to Chat List'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _currentToken != null
                        ? () {
                            Navigator.pushNamed(context, '/guide_profile', arguments: 1);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('View Guide Profile'),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
} 