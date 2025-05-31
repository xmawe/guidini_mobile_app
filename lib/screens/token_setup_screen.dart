import 'package:flutter/material.dart';
import '../services/token_service.dart';
import '../services/chat_service.dart';
import '../services/service_provider.dart';
import '../constants/colors.dart';

class TokenSetupScreen extends StatefulWidget {
  const TokenSetupScreen({Key? key}) : super(key: key);

  @override
  State<TokenSetupScreen> createState() => _TokenSetupScreenState();
}

class _TokenSetupScreenState extends State<TokenSetupScreen> {
  final TextEditingController _tokenController = TextEditingController();
  final ChatService _chatService = ServiceProvider().getChatService();
  String? _currentToken;
  bool _isLoading = true;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Token Setup'),
        backgroundColor: AppColors.primary800,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Set API Token',
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
                  const SizedBox(height: 24),
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
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/chat_list');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary800,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Go to Chat List'),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }
} 