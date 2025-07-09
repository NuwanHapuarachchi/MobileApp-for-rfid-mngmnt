import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../models/scan_history_model.dart';
import '../widgets/loading_widget.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  final _databaseService = DatabaseService();
  final _scrollController = ScrollController();

  List<ScanHistoryModel> _scanHistory = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;

  int _currentPage = 0;
  final int _pageSize = 20;
  bool _hasMore = true;

  String? _selectedReader;
  String? _selectedScanType;
  DateTimeRange? _selectedDateRange;
  String _filterType = 'all';

  @override
  void initState() {
    super.initState();
    _loadScanHistory();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMoreScanHistory();
    }
  }

  Future<void> _loadScanHistory({bool refresh = false}) async {
    if (!refresh && _scanHistory.isNotEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Try to get real scan history from database
      final scans = await _databaseService.getScanHistory(limit: 50);

      if (mounted) {
        setState(() {
          _scanHistory = scans;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _scanHistory = [];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreScanHistory() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final history = await _databaseService.getScanHistory(
        limit: _pageSize,
        offset: _currentPage * _pageSize,
        readerId: _selectedReader,
        startDate: _selectedDateRange?.start,
        endDate: _selectedDateRange?.end,
      );

      if (mounted) {
        setState(() {
          _scanHistory.addAll(history);
          _hasMore = history.length == _pageSize;
          _currentPage++;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadScanHistory(refresh: true);
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Scans'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Date Range Filter
            ListTile(
              leading: const Icon(Icons.date_range),
              title: Text(_selectedDateRange == null
                  ? 'Select Date Range'
                  : '${DateFormat('MMM dd').format(_selectedDateRange!.start)} - ${DateFormat('MMM dd').format(_selectedDateRange!.end)}'),
              onTap: () async {
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now(),
                  initialDateRange: _selectedDateRange,
                );
                if (range != null) {
                  setState(() {
                    _selectedDateRange = range;
                  });
                }
              },
            ),

            // Scan Type Filter
            DropdownButtonFormField<String>(
              value: _selectedScanType,
              decoration: const InputDecoration(
                labelText: 'Scan Type',
                prefixIcon: Icon(Icons.category),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('All Types')),
                DropdownMenuItem(value: 'entry', child: Text('Entry')),
                DropdownMenuItem(value: 'exit', child: Text('Exit')),
                DropdownMenuItem(value: 'inventory', child: Text('Inventory')),
                DropdownMenuItem(
                    value: 'maintenance', child: Text('Maintenance')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedScanType = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedReader = null;
                _selectedScanType = null;
                _selectedDateRange = null;
              });
              Navigator.of(context).pop();
              _refreshData();
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _refreshData();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _filterType = value;
              });
              _refreshData();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Scans')),
              const PopupMenuItem(value: 'entry', child: Text('Entry Only')),
              const PopupMenuItem(value: 'exit', child: Text('Exit Only')),
              const PopupMenuItem(
                  value: 'inventory', child: Text('Inventory Only')),
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
                    _filterType == 'all' ? 'All' : _filterType.toUpperCase(),
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
        onRefresh: _refreshData,
        color: Theme.of(context).colorScheme.primary,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _scanHistory.isEmpty) {
      return const Center(child: LoadingWidget());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Scans',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_scanHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Scan History',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scans will appear here once RFID tags are detected',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _scanHistory.length,
      itemBuilder: (context, index) {
        final scan = _scanHistory[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: _buildScanCard(scan),
        );
      },
    );
  }

  Widget _buildScanCard(ScanHistoryModel scan) {
    Color scanTypeColor;
    IconData scanTypeIcon;

    switch (scan.scanType.toLowerCase()) {
      case 'entry':
        scanTypeColor = Colors.green;
        scanTypeIcon = Icons.login;
        break;
      case 'exit':
        scanTypeColor = Colors.red;
        scanTypeIcon = Icons.logout;
        break;
      case 'inventory':
        scanTypeColor = Colors.blue;
        scanTypeIcon = Icons.inventory;
        break;
      default:
        scanTypeColor = Colors.grey;
        scanTypeIcon = Icons.help_outline;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showScanDetails(scan),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: scanTypeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      scanTypeIcon,
                      color: scanTypeColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scan.displayName,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          scan.readerModel ?? 'Reader ${scan.readerId}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: scanTypeColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          scan.scanTypeDisplay,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        scan.timeDisplay,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (scan.locationDisplay.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      scan.locationDisplay,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
              ],
              if (scan.confidenceScore != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Confidence: ${scan.confidenceScore}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showScanDetails(ScanHistoryModel scan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Scan Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Tag UID', scan.tagUid ?? 'Unknown'),
            _buildDetailRow('Owner', scan.ownerName ?? 'Unknown'),
            _buildDetailRow('Scan Type', scan.scanTypeDisplay),
            _buildDetailRow('Reader', scan.readerModel ?? 'Unknown'),
            _buildDetailRow('Location', scan.locationDisplay),
            _buildDetailRow('Timestamp', scan.timeDisplay),
            if (scan.confidenceScore != null)
              _buildDetailRow('Confidence', '${scan.confidenceScore}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
