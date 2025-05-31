/// Utility functions for string manipulations
class StringUtils {
  /// Gets the initials from a full name.
  /// If the name has multiple parts, it returns the first letter of the first and last part.
  /// If the name has only one part, it returns the first letter.
  /// Returns "?" if the name is empty.
  static String getInitials(String fullName) {
    if (fullName == null || fullName.isEmpty) return "?";
    
    try {
      // Trim and split the name by spaces
      final parts = fullName.trim().split(' ');
      
      if (parts.length > 1) {
        // Get first letter of first and last name
        final firstInitial = parts.first.isNotEmpty ? parts.first[0].toUpperCase() : "";
        final lastInitial = parts.last.isNotEmpty ? parts.last[0].toUpperCase() : "";
        
        return "$firstInitial$lastInitial";
      } else {
        // If only one name, just take the first letter
        final initial = parts.first.isNotEmpty ? parts.first[0].toUpperCase() : "?";
        
        return initial;
      }
    } catch (e) {
      return "?";
    }
  }
} 