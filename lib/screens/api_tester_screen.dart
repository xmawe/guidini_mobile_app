import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/chat_service.dart';
import '../services/service_provider.dart';
import '../constants/colors.dart';

class ApiTesterScreen extends StatefulWidget {
  const ApiTesterScreen({Key? key}) : super(key: key);

  @override
  _ApiTesterScreenState createState() => _ApiTesterScreenState();
}

class _ApiTesterScreenState extends State<ApiTesterScreen> {
  final TextEditingController _endpointController = TextEditingController(text: '/chat/rooms');
  final ChatService _chatService = ServiceProvider().getChatService();
  bool _isLoading = false;
  dynamic _apiResponse;
  String _errorMessage = '';

  @override
  void dispose() {
    _endpointController.dispose();
    super.dispose();
  }

  // Helper method to print nested JSON with indentation
  String _prettyJson(dynamic json) {
    var encoder = const JsonEncoder.withIndent('  ');
    try {
      return encoder.convert(json);
    } catch (e) {
      return json.toString();
    }
  }

  Future<void> _makeApiCall() async {
    final endpoint = _endpointController.text.trim();
    
    if (endpoint.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter an endpoint';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _apiResponse = null;
    });
    
    try {
      final result = await _chatService.getRawApiResponse(endpoint);
      
      setState(() {
        _apiResponse = result['data'];
        _isLoading = false;
      });
      
      if (result['success'] != true) {
        setState(() {
          _errorMessage = result['message'] ?? 'Unknown error';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Tester'),
        backgroundColor: AppColors.primary800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Endpoint input
            TextField(
              controller: _endpointController,
              decoration: const InputDecoration(
                labelText: 'API Endpoint',
                hintText: '/chat/rooms',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Test button
            ElevatedButton(
              onPressed: _isLoading ? null : _makeApiCall,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary800,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Test API Call'),
            ),
            
            // Error message
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.red.shade100,
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red.shade800),
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Response display
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'API Response:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_apiResponse != null)
                        SelectableText(
                          _prettyJson(_apiResponse),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        )
                      else
                        const Text(
                          'No response yet',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                    ],
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