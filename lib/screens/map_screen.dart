import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/checkpoint.dart';
import '../models/checkpoint_status.dart';
import '../services/auth_service.dart';
import '../services/checkpoint_service.dart';
import '../utils/constants.dart';
import '../utils/localization.dart';
import '../widgets/checkpoint_marker.dart';
import '../widgets/checkpoint_card.dart';
import 'checkpoint_detail_screen.dart';
import 'login_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  final CheckpointService _checkpointService = CheckpointService();
  final AuthService _authService = AuthService();

  List<Checkpoint> _allCheckpoints = [];
  List<Checkpoint> _filteredCheckpoints = [];
  Map<String, CheckpointStatus> _statuses = {};

  String? _selectedRegion;
  bool _isAdmin = false;
  bool _isLoading = true;
  bool _isLoadingStatuses = false;
  String? _errorMessage;

  final MapController _mapController = MapController();
  late TabController _tabController;
  int _selectedTabIndex = 0;

  StreamSubscription<List<Checkpoint>>? _checkpointSub;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkAdmin();
    _subscribeToCheckpoints();
  }

  @override
  void dispose() {
    _checkpointSub?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _checkAdmin() async {
    try {
      final admin = await _authService.isAdmin();
      if (mounted) setState(() => _isAdmin = admin);
    } catch (_) {}
  }

  void _subscribeToCheckpoints() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    _checkpointSub?.cancel();
    _checkpointSub = (_checkpointService.getCheckpoints() as Stream<List<Checkpoint>>).listen(
      (checkpoints) async {
        if (!mounted) return;
        _allCheckpoints = checkpoints;
        _applyFilter();

        if (checkpoints.isNotEmpty) {
          await _loadAllStatuses(checkpoints.map((c) => c.id).toList());
        }

        if (mounted) setState(() => _isLoading = false);
      },
      onError: (error) {
        debugPrint('🔴 Firestore error: $error');
        if (mounted) {
          setState(() {
            _isLoading = false;
            if (_allCheckpoints.isEmpty) {
              _errorMessage = 'فشل تحميل البيانات. تأكد من اتصالك بالإنترنت';
            }
          });
        }
      },
    );
  }

  Future<void> _loadAllStatuses(List<String> ids) async {
    if (!mounted) return;
    setState(() => _isLoadingStatuses = true);
    try {
      final statuses = await _checkpointService.getAllCheckpointStatuses(ids);
      if (mounted) {
        setState(() {
          _statuses = statuses;
          _isLoadingStatuses = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading statuses: $e');
      if (mounted) setState(() => _isLoadingStatuses = false);
    }
  }

  void _applyFilter() {
    setState(() {
      _filteredCheckpoints = _selectedRegion == null
          ? List.from(_allCheckpoints)
          : _allCheckpoints.where((cp) => cp.region == _selectedRegion).toList();
    });
  }

  void _selectRegion(String? region) {
    setState(() => _selectedRegion = region);
    _applyFilter();
  }

  Future<void> _refreshStatuses() async {
    await _loadAllStatuses(_allCheckpoints.map((c) => c.id).toList());
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildRegionDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildModernAppBar(),
              _buildTabBar(),
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _errorMessage != null && _filteredCheckpoints.isEmpty
                        ? _buildErrorState()
                        : _selectedTabIndex == 0
                            ? _buildMapView()
                            : _buildListView(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: () => _showAddCheckpointDialog(),
              backgroundColor: Colors.green.shade700,
              elevation: 4,
              child: const Icon(Icons.add_location_alt),
            )
          : null,
    );
  }

  Widget _buildRegionDrawer() {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade600, Colors.green.shade600],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.filter_alt_rounded, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 20),
                const Text(
                  'تصفية حسب المنطقة',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'اختر منطقة لعرض الحواجز فيها',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildDrawerRegionTile(null, 'جميع المناطق', Icons.public, Colors.blue),
                const Divider(height: 1),
                ...AppConstants.regions.map((r) => _buildDrawerRegionTile(r, r, Icons.place, Colors.green)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerRegionTile(String? region, String label, IconData icon, Color iconColor) {
    final isSelected = _selectedRegion == region;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? iconColor.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: isSelected ? iconColor : Colors.grey.shade600, size: 22),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? iconColor : Colors.grey.shade800,
        ),
      ),
      trailing: isSelected
          ? Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, color: iconColor, size: 18),
            )
          : null,
      tileColor: isSelected ? iconColor.withOpacity(0.08) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: () {
        _selectRegion(region);
        Navigator.pop(context);
      },
    );
  }

 // Replace just the _buildModernAppBar method in map_screen.dart:

Widget _buildModernAppBar() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    child: Row(
      children: [
        // Menu button
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: const Icon(Icons.location_on, size: 20),
            onPressed: _openDrawer,
            color: Colors.green.shade700,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ),
        const SizedBox(width: 6),
        // Logo - smaller
        
        const SizedBox(width: 8),
        // Title
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.tr('مسار'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
              if (_isLoadingStatuses)
                Row(
                  children: [
                    SizedBox(
                      width: 8,
                      height: 8,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        valueColor: AlwaysStoppedAnimation(Colors.green.shade400),
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'تحديث',
                      style: TextStyle(fontSize: 9, color: Colors.green.shade400),
                    ),
                  ],
                ),
            ],
          ),
        ),
        // Region chip - compact
        if (_selectedRegion != null)
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(right: 4),
              child: Chip(
                label: Text(_selectedRegion!, style: const TextStyle(fontSize: 10)),
                backgroundColor: Colors.green.shade100,
                deleteIcon: const Icon(Icons.close, size: 12),
                onDeleted: () => _selectRegion(null),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        // Refresh button
        IconButton(
          icon: const Icon(Icons.refresh_rounded, size: 20),
          onPressed: _isLoadingStatuses ? null : _refreshStatuses,
          color: Colors.green.shade700,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
        // Logout button
        IconButton(
          icon: const Icon(Icons.logout_rounded, size: 20),
          onPressed: () async {
            await _authService.signOut();
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            }
          },
          color: Colors.green.shade700,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
      ],
    ),
  );
}
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
     child: TabBar(
  controller: _tabController,
  onTap: (i) => setState(() => _selectedTabIndex = i),

  // IMPORTANT: makes indicator stretch full tab
  indicatorSize: TabBarIndicatorSize.tab,

  indicator: BoxDecoration(
    color: Colors.green.shade600,
    borderRadius: BorderRadius.circular(30),
  ),

  labelColor: Colors.white,
  unselectedLabelColor: Colors.grey.shade600,

  labelStyle: const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 14,
  ),
  dividerColor: Colors.transparent,
  tabs: const [
    Tab(icon: Icon(Icons.map), text: 'الخريطة'),
    Tab(icon: Icon(Icons.list), text: 'القائمة'),
  ],
),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(Colors.green.shade700),
            ),
          ),
          const SizedBox(height: 16),
          Text('جاري تحميل البيانات...', style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _subscribeToCheckpoints,
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    if (_filteredCheckpoints.isEmpty) 
      return _buildEmptyState(true);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: AppConstants.defaultLocation,
        initialZoom: AppConstants.defaultZoom,
        minZoom: 7.0,
        maxZoom: 15.0,
        onLongPress: (_, latLng) {
          if (_isAdmin) _showAddCheckpointDialog(position: latLng);
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.checkpoint_app',
          maxNativeZoom: 18,
          keepBuffer: 4,
        ),
        MarkerLayer(
          markers: _buildMarkers(),
          rotate: false,
        ),
      ],
    );
  }

  Widget _buildListView() {
    if (_filteredCheckpoints.isEmpty) return _buildEmptyState(false);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredCheckpoints.length,
      itemBuilder: (context, index) {
        final cp = _filteredCheckpoints[index];
        return CheckpointCard(
          checkpoint: cp,
          status: _statuses[cp.id],
          onTap: () => _openDetail(cp),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isMap) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isMap ? Icons.location_off : Icons.list_alt,
              size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            _selectedRegion != null
                ? 'لا توجد حواجز في منطقة $_selectedRegion'
                : 'لا توجد حواجز حالياً',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          if (_selectedRegion != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: TextButton.icon(
                onPressed: () => _selectRegion(null),
                icon: const Icon(Icons.clear),
                label: const Text('إزالة الفلتر'),
              ),
            ),
        ],
      ),
    );
  }

  List<Marker> _buildMarkers() {
    return _filteredCheckpoints.map((cp) {
      return Marker(
        point: LatLng(cp.latitude, cp.longitude),
        width: 110,
        height: 80,
        child: CheckpointMarker(
          checkpoint: cp,
          status: _statuses[cp.id],
          onTap: () => _openDetail(cp),
        ),
      );
    }).toList();
  }

  void _openDetail(Checkpoint checkpoint) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckpointDetailScreen(checkpoint: checkpoint),
      ),
    ).then((_) {
      _refreshStatuses();
    });
  }

  void _showAddCheckpointDialog({LatLng? position}) {
    final nameController = TextEditingController();
    final regionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة حاجز جديد', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الحاجز',
                  hintText: 'مثال: حاجز قلنديا',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: regionController,
                decoration: const InputDecoration(
                  labelText: 'المنطقة',
                  hintText: 'مثال: رام الله',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.place),
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
              if (position != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('📍 موقع الحاجز:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        'خط العرض: ${position.latitude.toStringAsFixed(6)}\n'
                        'خط الطول: ${position.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: TextStyle(color: Colors.grey.shade700)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('الرجاء إدخال اسم الحاجز'),
                  backgroundColor: Colors.orange,
                ));
                return;
              }
              if (position == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('الرجاء الضغط مطولاً على الخريطة لتحديد موقع الحاجز'),
                  backgroundColor: Colors.orange,
                ));
                return;
              }

              final newCheckpoint = Checkpoint(
                id: '',
                name: nameController.text.trim(),
                region: regionController.text.trim().isEmpty ? 'عام' : regionController.text.trim(),
                latitude: position.latitude,
                longitude: position.longitude,
                createdBy: _authService.currentUser?.uid,
                createdAt: DateTime.now(),
              );

              try {
                await _checkpointService.addCheckpoint(newCheckpoint);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✓ تم إضافة "${nameController.text.trim()}" بنجاح'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ فشل الإضافة: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}