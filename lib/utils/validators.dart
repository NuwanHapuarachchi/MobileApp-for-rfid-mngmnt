class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    
    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }
    
    final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
    if (!nameRegex.hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }
    
    return null;
  }

  // Phone number validation
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }

  // URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$'
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }

  // Number validation
  static String? validateNumber(String? value, {int? min, int? max}) {
    if (value == null || value.isEmpty) {
      return 'Number is required';
    }
    
    final number = int.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    if (min != null && number < min) {
      return 'Number must be at least $min';
    }
    
    if (max != null && number > max) {
      return 'Number must be at most $max';
    }
    
    return null;
  }

  // Double validation
  static String? validateDouble(String? value, {double? min, double? max}) {
    if (value == null || value.isEmpty) {
      return 'Number is required';
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    if (min != null && number < min) {
      return 'Number must be at least $min';
    }
    
    if (max != null && number > max) {
      return 'Number must be at most $max';
    }
    
    return null;
  }

  // RFID Tag ID validation
  static String? validateTagId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tag ID is required';
    }
    
    if (value.length < 4) {
      return 'Tag ID must be at least 4 characters long';
    }
    
    final tagRegex = RegExp(r'^[a-zA-Z0-9]+$');
    if (!tagRegex.hasMatch(value)) {
      return 'Tag ID can only contain letters and numbers';
    }
    
    return null;
  }

  // IP Address validation
  static String? validateIpAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'IP address is required';
    }
    
    final ipRegex = RegExp(
      r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
    );
    
    if (!ipRegex.hasMatch(value)) {
      return 'Please enter a valid IP address';
    }
    
    return null;
  }

  // Port validation
  static String? validatePort(String? value) {
    if (value == null || value.isEmpty) {
      return 'Port is required';
    }
    
    final port = int.tryParse(value);
    if (port == null) {
      return 'Please enter a valid port number';
    }
    
    if (port < 1 || port > 65535) {
      return 'Port must be between 1 and 65535';
    }
    
    return null;
  }

  // MAC Address validation
  static String? validateMacAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'MAC address is required';
    }
    
    final macRegex = RegExp(
      r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$'
    );
    
    if (!macRegex.hasMatch(value)) {
      return 'Please enter a valid MAC address (xx:xx:xx:xx:xx:xx)';
    }
    
    return null;
  }

  // Location validation
  static String? validateLocation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Location is required';
    }
    
    if (value.trim().length < 2) {
      return 'Location must be at least 2 characters long';
    }
    
    return null;
  }

  // Description validation
  static String? validateDescription(String? value, {int maxLength = 500}) {
    if (value != null && value.length > maxLength) {
      return 'Description must be less than $maxLength characters';
    }
    
    return null;
  }

  // Custom validation
  static String? validateCustom(
    String? value, 
    bool Function(String) validator, 
    String errorMessage,
  ) {
    if (value == null || value.isEmpty) {
      return errorMessage;
    }
    
    if (!validator(value)) {
      return errorMessage;
    }
    
    return null;
  }

  // Multiple validators
  static String? validateMultiple(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  // Date validation
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }
    
    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }

  // Time validation
  static String? validateTime(String? value) {
    if (value == null || value.isEmpty) {
      return 'Time is required';
    }
    
    final timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (!timeRegex.hasMatch(value)) {
      return 'Please enter a valid time (HH:MM)';
    }
    
    return null;
  }

  // File size validation
  static String? validateFileSize(int? bytes, int maxSizeInMB) {
    if (bytes == null) {
      return 'File is required';
    }
    
    final maxSizeInBytes = maxSizeInMB * 1024 * 1024;
    if (bytes > maxSizeInBytes) {
      return 'File size must be less than ${maxSizeInMB}MB';
    }
    
    return null;
  }

  // File extension validation
  static String? validateFileExtension(String? fileName, List<String> allowedExtensions) {
    if (fileName == null || fileName.isEmpty) {
      return 'File is required';
    }
    
    final extension = fileName.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      return 'File must be one of: ${allowedExtensions.join(', ')}';
    }
    
    return null;
  }
} 