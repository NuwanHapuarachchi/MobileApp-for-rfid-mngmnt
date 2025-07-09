import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/rfid_reader_model.dart';
import '../widgets/loading_widget.dart';
import '../widgets/animated_widgets.dart';
import '../utils/responsive_utils.dart';

class ReadersScreen extends StatefulWidget {
  const ReadersScreen({super.key});

  @override
  State<ReadersScreen> createState() => _ReadersScreenState();
}

class _ReadersScreenState extends State<ReadersScreen> {
  final _databaseService = DatabaseService();

  List<RfidReaderModel> _readers = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadReaders();
  }

  Future<void> _loadReaders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final readers = await _databaseService.getReaders();
      if (mounted) {
        setState(() {
          _readers = readers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _readers = [];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshReaders() async {
    await _loadReaders();
  }

  List<RfidReaderModel> get _filteredReaders {
    if (_filterStatus == 'all') return _readers;
    return _readers.where((reader) => reader.status == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RFID Readers'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _refreshReaders,
            icon: const Icon(Icons.refresh),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _filterStatus = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Readers')),
              const PopupMenuItem(value: 'active', child: Text('Active Only')),
              const PopupMenuItem(
                  value: 'offline', child: Text('Offline Only')),
              const PopupMenuItem(
                  value: 'maintenance', child: Text('Maintenance')),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _filterStatus == 'all'
                        ? 'All'
                        : _filterStatus.toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshReaders,
        color: Theme.of(context).colorScheme.primary,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add new reader functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Add Reader functionality coming soon')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: LoadingWidget());
    }

    return Column(
      children: [
        // Error message banner if there's an error
        if (_errorMessage != null)
          Container(
            width: double.infinity,
            padding: ResponsiveUtils.getScreenPadding(context),
            color: Theme.of(context).colorScheme.error.withOpacity(0.1),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Failed to load readers: $_errorMessage',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _refreshReaders,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),

        // Readers list
        Expanded(
          child: _buildReadersList(),
        ),
      ],
    );
  }

  Widget _buildReadersList() {
    final filteredReaders = _filteredReaders;

    if (filteredReaders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.router_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No Readers Found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _filterStatus == 'all'
                  ? 'No RFID readers available'
                  : 'No readers match the current filter',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      );
    }

    // Use responsive grid layout
    return Padding(
      padding: ResponsiveUtils.getScreenPadding(context),
      child: ResponsiveUtils.shouldUseSingleColumn(context)
          ? _buildSingleColumnList(filteredReaders)
          : _buildGridView(filteredReaders),
    );
  }

  Widget _buildSingleColumnList(List<RfidReaderModel> readers) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: readers.length,
      separatorBuilder: (context, index) => SizedBox(
        height: ResponsiveUtils.getSpacing(context),
      ),
      itemBuilder: (context, index) {
        return FadeInAnimation(
          delay: Duration(milliseconds: 100 * index),
          child: _buildReaderCard(readers[index]),
        );
      },
    );
  }

  Widget _buildGridView(List<RfidReaderModel> readers) {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveUtils.getGridCrossAxisCount(
          context,
          mobileCount: 1,
          tabletPortraitCount: 2,
          tabletLandscapeCount: 3,
          desktopCount: 4,
        ),
        crossAxisSpacing: ResponsiveUtils.getSpacing(context),
        mainAxisSpacing: ResponsiveUtils.getSpacing(context),
        childAspectRatio:
            ResponsiveUtils.isTabletLandscape(context) ? 1.2 : 1.1,
      ),
      itemCount: readers.length,
      itemBuilder: (context, index) {
        return FadeInAnimation(
          delay: Duration(milliseconds: 100 * index),
          child: _buildReaderCard(readers[index]),
        );
      },
    );
  }

  Widget _buildReaderCard(RfidReaderModel reader) {
    final statusColor = _getStatusColor(reader.status);
    final lastSeenText = _formatLastSeen(reader.lastSeen);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: Navigate to reader details
        },
        child: Padding(
          padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context,
              mobile: 16, tablet: 20, desktop: 24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      reader.serialNumber,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context, 16),
                          ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      reader.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize:
                            ResponsiveUtils.getResponsiveFontSize(context, 10),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(
                  height: ResponsiveUtils.getSpacing(context,
                      mobile: 8, tablet: 12, desktop: 16)),

              // Model and location
              Text(
                reader.model,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize:
                          ResponsiveUtils.getResponsiveFontSize(context, 14),
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: ResponsiveUtils.getResponsiveFontSize(context, 16),
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      reader.location,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context, 12),
                          ),
                    ),
                  ),
                ],
              ),

              SizedBox(
                  height: ResponsiveUtils.getSpacing(context,
                      mobile: 8, tablet: 12, desktop: 16)),

              // Last seen
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: ResponsiveUtils.getResponsiveFontSize(context, 14),
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Last seen: $lastSeenText',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context, 11),
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'maintenance':
        return Colors.orange;
      case 'offline':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatLastSeen(DateTime? lastSeen) {
    if (lastSeen == null) return 'Never';

    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
