import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppHelpers {
  // Date formatting helpers
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
  }

  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return formatDate(dateTime);
    }
  }

  // Number formatting helpers
  static String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }

  // Color helpers
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'online':
      case 'connected':
        return Colors.green;
      case 'inactive':
      case 'offline':
      case 'disconnected':
        return Colors.red;
      case 'maintenance':
      case 'warning':
        return Colors.orange;
      case 'retired':
      case 'damaged':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  static Color getScanTypeColor(String scanType) {
    switch (scanType.toLowerCase()) {
      case 'entry':
        return Colors.green;
      case 'exit':
        return Colors.red;
      case 'inventory':
        return Colors.blue;
      case 'maintenance':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Validation helpers
  static bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  static bool isValidTagId(String tagId) {
    return tagId.isNotEmpty && tagId.length >= 4;
  }

  // String helpers
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String truncateString(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static String getInitials(String name) {
    if (name.isEmpty) return '';
    final words = name.split(' ');
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    }
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  // UI helpers
  static void showSnackBar(BuildContext context, String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static Future<bool?> showConfirmDialog(
    BuildContext context, 
    String title, 
    String message,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  // Data helpers
  static List<T> filterList<T>(List<T> list, bool Function(T) predicate) {
    return list.where(predicate).toList();
  }

  static List<T> sortList<T>(List<T> list, int Function(T, T) compare) {
    final sortedList = List<T>.from(list);
    sortedList.sort(compare);
    return sortedList;
  }

  // Network helpers
  static bool isNetworkError(String error) {
    return error.toLowerCase().contains('network') ||
           error.toLowerCase().contains('connection') ||
           error.toLowerCase().contains('timeout');
  }

  // File size helpers
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Theme helpers
  static Brightness getBrightness(BuildContext context) {
    return Theme.of(context).brightness;
  }

  static bool isDarkMode(BuildContext context) {
    return getBrightness(context) == Brightness.dark;
  }

  // Device helpers
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static bool isTablet(BuildContext context) {
    return getScreenWidth(context) > 600;
  }

  static bool isMobile(BuildContext context) {
    return getScreenWidth(context) <= 600;
  }
} 