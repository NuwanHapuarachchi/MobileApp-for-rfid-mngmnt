import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/rfid_tag_model.dart';
import '../widgets/loading_widget.dart';
import '../widgets/animated_widgets.dart';
import '../utils/responsive_utils.dart';

class TagsScreen extends StatefulWidget {
  const TagsScreen({super.key});

  @override
  State<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends State<TagsScreen> {
  final _databaseService = DatabaseService();

  List<RfidTagModel> _tags = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tags = await _databaseService.getTags();
      if (mounted) {
        setState(() {
          _tags = tags;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _tags = [];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshTags() async {
    await _loadTags();
  }

  List<RfidTagModel> get _filteredTags {
    if (_filterStatus == 'all') return _tags;
    return _tags.where((tag) => tag.status == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RFID Tags'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _refreshTags,
            icon: const Icon(Icons.refresh),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _filterStatus = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Tags')),
              const PopupMenuItem(value: 'active', child: Text('Active Only')),
              const PopupMenuItem(
                  value: 'inactive', child: Text('Inactive Only')),
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
        onRefresh: _refreshTags,
        color: Theme.of(context).colorScheme.primary,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add new tag functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add Tag functionality coming soon')),
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
            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
            child: Row(
              children: [
                Icon(
                  Icons.warning_outlined,
                  color: Theme.of(context).colorScheme.tertiary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Failed to load tags: $_errorMessage',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontSize: 12,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _refreshTags,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),

        // Tags list
        Expanded(
          child: _buildTagsList(),
        ),
      ],
    );
  }

  Widget _buildTagsList() {
    final filteredTags = _filteredTags;

    if (filteredTags.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.label_outline,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No Tags Found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _filterStatus == 'all'
                  ? 'No RFID tags available'
                  : 'No tags match the current filter',
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
          ? _buildSingleColumnList(filteredTags)
          : _buildGridView(filteredTags),
    );
  }

  Widget _buildSingleColumnList(List<RfidTagModel> tags) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: tags.length,
      separatorBuilder: (context, index) => SizedBox(
        height: ResponsiveUtils.getSpacing(context),
      ),
      itemBuilder: (context, index) {
        return FadeInAnimation(
          delay: Duration(milliseconds: 100 * index),
          child: _buildTagCard(tags[index]),
        );
      },
    );
  }

  Widget _buildGridView(List<RfidTagModel> tags) {
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
            ResponsiveUtils.isTabletLandscape(context) ? 1.3 : 1.2,
      ),
      itemCount: tags.length,
      itemBuilder: (context, index) {
        return FadeInAnimation(
          delay: Duration(milliseconds: 100 * index),
          child: _buildTagCard(tags[index]),
        );
      },
    );
  }

  Widget _buildTagCard(RfidTagModel tag) {
    final statusColor = _getStatusColor(tag.status);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: Navigate to tag details
        },
        child: Padding(
          padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context,
              mobile: 16, tablet: 20, desktop: 24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.nfc,
                      color: statusColor,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getStatusIcon(tag.status),
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                tag.tagUid,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          ResponsiveUtils.getResponsiveFontSize(context, 12),
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(
                  height: ResponsiveUtils.getSpacing(context,
                      mobile: 8, tablet: 10, desktop: 12)),
              Text(
                tag.ownerName ?? 'Unknown Owner',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                      fontWeight: FontWeight.w500,
                      fontSize:
                          ResponsiveUtils.getResponsiveFontSize(context, 11),
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              if (tag.description != null)
                Text(
                  tag.description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize:
                            ResponsiveUtils.getResponsiveFontSize(context, 10),
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tag.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTagDetails(RfidTagModel tag) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tag.tagUid),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Owner', tag.ownerName ?? 'Unknown'),
            _buildDetailRow('Description', tag.description ?? 'No description'),
            _buildDetailRow('Status', tag.status.toUpperCase()),
            _buildDetailRow('Created',
                '${tag.createdAt.day}/${tag.createdAt.month}/${tag.createdAt.year}'),
            _buildDetailRow('Updated',
                '${tag.updatedAt.day}/${tag.updatedAt.month}/${tag.updatedAt.year}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Edit tag functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit functionality coming soon')),
              );
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.grey;
      case 'maintenance':
        return Colors.orange;
      case 'lost':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.check_circle;
      case 'inactive':
        return Icons.remove_circle;
      case 'maintenance':
        return Icons.build;
      case 'lost':
        return Icons.error;
      default:
        return Icons.help_outline;
    }
  }
}
