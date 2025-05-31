import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// Utility functions for chat message handling
class MessageUtils {
  /// Format message text, handling links, emoji, etc.
  static String formatMessageText(String text) {
    // For now, just return the original text
    // In the future we can add formatting for links, emoji, etc.
    return text;
  }
  
  /// Returns a user-friendly error message for chat operations
  static String getUserFriendlyErrorMessage(dynamic error) {
    if (error == null) {
      return 'An unknown error occurred';
    }
    
    String errorMessage = error.toString();
    
    // Network connection errors
    if (errorMessage.contains('SocketException') || 
        errorMessage.contains('Connection refused') ||
        errorMessage.contains('Network is unreachable')) {
      return 'Network connection error. Please check your internet connection.';
    }
    
    // Authentication errors
    if (errorMessage.contains('401') || 
        errorMessage.contains('Unauthorized') ||
        errorMessage.contains('Authentication required')) {
      return 'Authentication error. Please log in again.';
    }
    
    // Server errors
    if (errorMessage.contains('500') || 
        errorMessage.contains('Internal Server Error')) {
      return 'Server error. Please try again later.';
    }
    
    // If no specific error is matched, return a generic message
    return 'Failed to send message. Please try again.';
  }
  
  /// Shows a snackbar with the error message
  static void showErrorSnackBar(BuildContext context, String message, {VoidCallback? onRetry}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 5),
        action: onRetry != null ? SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: onRetry,
        ) : null,
      ),
    );
  }
  
  /// Shows a success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
} 