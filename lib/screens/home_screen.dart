import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/animated_widgets.dart';
import '../utils/responsive_utils.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onTabChange;

  const HomeScreen({super.key, this.onTabChange});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _databaseService = DatabaseService();

  Map<String, dynamic>? _dashboardStats;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final stats = await _databaseService.getDashboardStats();
      if (mounted) {
        setState(() {
          _dashboardStats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _dashboardStats = null;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refresh() async {
    await _loadDashboardData();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('RFID Manager'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: Theme.of(context).colorScheme.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: ResponsiveUtils.getScreenPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Error message banner if there's an error
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          Theme.of(context).colorScheme.error.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.error,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Failed to load dashboard data: $_errorMessage',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _refresh,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),

              // Welcome Section
              FadeInAnimation(
                delay: const Duration(milliseconds: 100),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context,
                      mobile: 20, tablet: 24, desktop: 28)),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context, 16),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                          height: ResponsiveUtils.getSpacing(context,
                              mobile: 4, tablet: 6, desktop: 8)),
                      Text(
                        user?.email ?? 'User',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context, 24),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                          height: ResponsiveUtils.getSpacing(context,
                              mobile: 8, tablet: 10, desktop: 12)),
                      Text(
                        'Welcome to your RFID Management Dashboard',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context, 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Quick Stats Section
              SlideInAnimation(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'System Overview',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),

              const SizedBox(height: 16),

              if (_isLoading)
                const FadeInAnimation(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: LoadingWidget(),
                    ),
                  ),
                )
              else if (_errorMessage != null)
                SlideInAnimation(
                  delay: const Duration(milliseconds: 300),
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .tertiary
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .tertiary
                                  .withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Theme.of(context).colorScheme.tertiary,
                                size: 48,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Error Loading Data',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .tertiary
                                      .withOpacity(0.8),
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refresh,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_dashboardStats != null)
                Column(
                  children: [
                    // Stats Grid with Staggered Animation
                    GridView.count(
                      crossAxisCount: ResponsiveUtils.getGridCrossAxisCount(
                        context,
                        mobileCount: 2,
                        tabletPortraitCount: 2,
                        tabletLandscapeCount: 4,
                        desktopCount: 4,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: ResponsiveUtils.getSpacing(context),
                      mainAxisSpacing: ResponsiveUtils.getSpacing(context),
                      childAspectRatio:
                          ResponsiveUtils.isTabletLandscape(context)
                              ? 1.4
                              : 1.3,
                      children: [
                        ScaleInAnimation(
                          delay: const Duration(milliseconds: 300),
                          child: StatCard(
                            title: 'Total Readers',
                            value: _dashboardStats!['total_readers'].toString(),
                            icon: Icons.router,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        ScaleInAnimation(
                          delay: const Duration(milliseconds: 400),
                          child: StatCard(
                            title: 'Active Readers',
                            value:
                                _dashboardStats!['active_readers'].toString(),
                            icon: Icons.wifi,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        ScaleInAnimation(
                          delay: const Duration(milliseconds: 500),
                          child: StatCard(
                            title: 'Total Tags',
                            value: _dashboardStats!['total_tags'].toString(),
                            icon: Icons.nfc,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                        ScaleInAnimation(
                          delay: const Duration(milliseconds: 600),
                          child: StatCard(
                            title: 'Today\'s Scans',
                            value: _dashboardStats!['today_scans'].toString(),
                            icon: Icons.timeline,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Quick Actions
                    SlideInAnimation(
                      delay: const Duration(milliseconds: 700),
                      child: Text(
                        'Quick Actions',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Action Cards with Staggered Animation
                    SlideInAnimation(
                      delay: const Duration(milliseconds: 800),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildActionCard(
                              title: 'View Readers',
                              subtitle: 'Manage RFID readers',
                              icon: Icons.router,
                              onTap: () {
                                // Switch to readers tab (index 1)
                                widget.onTabChange?.call(1);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildActionCard(
                              title: 'View Tags',
                              subtitle: 'Manage RFID tags',
                              icon: Icons.nfc,
                              onTap: () {
                                // Switch to tags tab (index 2)
                                widget.onTabChange?.call(2);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    SlideInAnimation(
                      delay: const Duration(milliseconds: 900),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildActionCard(
                              title: 'Scan History',
                              subtitle: 'View recent scans',
                              icon: Icons.history,
                              onTap: () {
                                // Switch to scan history tab (index 3)
                                widget.onTabChange?.call(3);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildActionCard(
                              title: 'Settings',
                              subtitle: 'Configure app',
                              icon: Icons.settings,
                              onTap: () {
                                // Switch to settings tab (index 4)
                                widget.onTabChange?.call(4);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 24),

              // System Status
              FadeInAnimation(
                delay: const Duration(milliseconds: 1000),
                child: Container(
                  width: double.infinity,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.health_and_safety,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'System Status',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildStatusItem('Database', 'Connected', true),
                      _buildStatusItem('Supabase Auth', 'Active', true),
                      _buildStatusItem('Real-time Updates', 'Enabled', true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String title, String status, bool isOnline) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Row(
            children: [
              PulseAnimation(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isOnline
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.tertiary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                status,
                style: TextStyle(
                  color: isOnline
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.tertiary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
