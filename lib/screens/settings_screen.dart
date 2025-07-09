import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../models/user_model.dart';
import '../widgets/animated_widgets.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService();
  final _storageService = StorageService();

  UserModel? _user;
  bool _isLoading = true;
  bool _notificationsEnabled = true;
  bool _autoRefreshEnabled = true;
  int _refreshInterval = 30;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadSettings();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = await _authService.getUserProfile();
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadSettings() async {
    final notifications = await _storageService.getNotificationsEnabled();
    final autoRefresh = await _storageService.getAutoRefreshEnabled();
    final interval = await _storageService.getReaderRefreshInterval();

    if (mounted) {
      setState(() {
        _notificationsEnabled = notifications;
        _autoRefreshEnabled = autoRefresh;
        _refreshInterval = interval;
      });
    }
  }

  Future<void> _updateNotifications(bool value) async {
    await _storageService.saveNotificationsEnabled(value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  Future<void> _updateAutoRefresh(bool value) async {
    await _storageService.saveAutoRefreshEnabled(value);
    setState(() {
      _autoRefreshEnabled = value;
    });
  }

  Future<void> _updateRefreshInterval(int value) async {
    await _storageService.saveReaderRefreshInterval(value);
    setState(() {
      _refreshInterval = value;
    });
  }

  Future<void> _showLogoutDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.tertiary,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _logout();
    }
  }

  Future<void> _logout() async {
    try {
      await _authService.signOut();
      await _storageService.clear();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
          ),
        );
      }
    }
  }

  Future<void> _showProfileDialog() async {
    final nameController = TextEditingController(text: _user?.name ?? '');
    final phoneController = TextEditingController(text: _user?.phone ?? '');
    final addressController = TextEditingController(text: _user?.address ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _authService.updateUserProfile(
                  name: nameController.text.trim(),
                  phone: phoneController.text.trim(),
                  address: addressController.text.trim(),
                );
                await _loadUserProfile();
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Profile updated successfully'),
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating profile: ${e.toString()}'),
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  FadeInAnimation(
                    delay: const Duration(milliseconds: 100),
                    child: _buildProfileSection(),
                  ),

                  const SizedBox(height: 32),

                  // App Settings
                  SlideInAnimation(
                    delay: const Duration(milliseconds: 200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'App Settings',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        _buildSettingsSection(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Theme Settings
                  SlideInAnimation(
                    delay: const Duration(milliseconds: 300),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Appearance',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        _buildThemeSection(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // System Information
                  SlideInAnimation(
                    delay: const Duration(milliseconds: 400),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'System Information',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        _buildSystemInfoSection(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Logout Button
                  SlideInAnimation(
                    delay: const Duration(milliseconds: 500),
                    child: _buildLogoutButton(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileSection() {
    return ScaleInAnimation(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
              child: Text(
                _user?.initials ?? 'U',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _user?.displayName ?? 'User',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              _user?.email ?? '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            if (_user?.role != null) ...[
              const SizedBox(height: 8),
              Chip(
                label: Text(
                  _user!.role.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: _getRoleColor(_user!.role),
              ),
            ],
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _showProfileDialog,
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                side: BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red.withOpacity(0.2);
      case 'manager':
        return Colors.orange.withOpacity(0.2);
      case 'employee':
        return Colors.blue.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }

  Widget _buildSettingsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive notifications for RFID events'),
            value: _notificationsEnabled,
            onChanged: _updateNotifications,
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Auto Refresh'),
            subtitle: const Text('Automatically refresh data'),
            value: _autoRefreshEnabled,
            onChanged: _updateAutoRefresh,
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Refresh Interval'),
            subtitle: Text('Update data every $_refreshInterval seconds'),
            trailing: DropdownButton<int>(
              value: _refreshInterval,
              onChanged: (value) {
                if (value != null) {
                  _updateRefreshInterval(value);
                }
              },
              items: [15, 30, 60, 120].map((seconds) {
                return DropdownMenuItem(
                  value: seconds,
                  child: Text('${seconds}s'),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSection() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: Text(themeProvider.isDarkMode
                ? 'Dark theme enabled'
                : 'Light theme enabled'),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
            activeColor: Theme.of(context).colorScheme.primary,
            secondary: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                key: ValueKey(themeProvider.isDarkMode),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSystemInfoSection() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoTile('App Version', '1.0.0'),
          const Divider(height: 1),
          _buildInfoTile('Build Number', '1'),
          const Divider(height: 1),
          _buildInfoTile('Database', 'Supabase'),
          const Divider(height: 1),
          _buildInfoTile('User ID', _user?.id.substring(0, 8) ?? 'Unknown'),
          const Divider(height: 1),
          _buildInfoTile(
              'Status', _user?.isActive == true ? 'Active' : 'Inactive'),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return ListTile(
      title: Text(title),
      trailing: Text(
        value,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: PulseAnimation(
        child: ElevatedButton.icon(
          onPressed: _showLogoutDialog,
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
