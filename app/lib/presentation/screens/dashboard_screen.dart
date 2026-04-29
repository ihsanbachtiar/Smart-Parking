import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../providers/parking_provider.dart';
import 'detail_screen.dart';
import 'profile_screen.dart';
import '../../data/models/parking_sensor.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ParkingProvider>(context, listen: false).fetchParkingData();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ParkingProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (provider.state == DataState.loaded) {
      _animationController.forward(from: 0.0);
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        title: const Text('Smart Parking', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Hapus Cache',
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 22),
            ),
            onPressed: () {
              provider.clearCache();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Cache berhasil dihapus!', style: TextStyle(fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Profil Admin',
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person_outline_rounded, color: Theme.of(context).primaryColor, size: 22),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: isDark 
              ? [const Color(0xFF1A1A24), const Color(0xFF121212)]
              : [const Color(0xFFF0F4FD), const Color(0xFFF8FAFC)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSourceIndicator(provider.source),
              if (provider.state == DataState.loaded) 
                _buildHeroSummary(provider.sensors, isDark),
              Expanded(
                child: _buildBodyContent(provider),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          provider.fetchParkingData();
        },
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 4,
        child: const Icon(Icons.refresh_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildHeroSummary(List<ParkingSensor> sensors, bool isDark) {
    int totalAvailable = 0;
    int totalOccupied = 0;
    for (var s in sensors) {
      totalAvailable += s.availableSlots;
      totalOccupied += s.occupiedSlots;
    }
    final int capacity = totalAvailable + totalOccupied;

    return FadeTransition(
      opacity: _animationController,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark 
              ? [const Color(0xFF2B32B2), const Color(0xFF1488CC)]
              : [const Color(0xFF1488CC), const Color(0xFF2B32B2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1488CC).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ]
        ),
        child: Column(
          children: [
            const Text(
              'Ringkasan Area Parkir',
              style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn('Tersedia', totalAvailable.toString(), Colors.greenAccent),
                Container(width: 1, height: 40, color: Colors.white24),
                _buildStatColumn('Terisi', totalOccupied.toString(), Colors.orangeAccent),
                Container(width: 1, height: 40, color: Colors.white24),
                _buildStatColumn('Total', capacity.toString(), Colors.white),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSourceIndicator(DataSource source) {
    if (source == DataSource.none) return const SizedBox.shrink();
    
    final isOnline = source == DataSource.online;
    final color = isOnline ? Colors.green : Colors.orange;
    final text = isOnline ? '🟢 Live Online Data' : '🟠 Offline Cached Data';

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildBodyContent(ParkingProvider provider) {
    switch (provider.state) {
      case DataState.loading:
        return const Center(child: CircularProgressIndicator());
      case DataState.error:
        return _buildErrorState(provider.errorMessage, provider.fetchParkingData);
      case DataState.empty:
        return _buildEmptyState(provider.fetchParkingData);
      case DataState.loaded:
        return RefreshIndicator(
          onRefresh: () => provider.fetchParkingData(),
          child: ListView.builder(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 80, top: 0),
            itemCount: provider.sensors.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final sensor = provider.sensors[index];
              return AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.5, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _animationController,
                      curve: Interval(
                        (index / provider.sensors.length) * 0.5,
                        1.0,
                        curve: Curves.easeOutCubic,
                      ),
                    )),
                    child: FadeTransition(
                      opacity: _animationController,
                      child: child,
                    ),
                  );
                },
                child: _buildSensorCard(context, sensor),
              );
            },
          ),
        );
    }
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded, size: 72, color: Colors.red),
            ),
            const SizedBox(height: 24),
            Text(
              'Koneksi Terputus',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inbox_rounded, size: 72, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          const Text(
            'Belum Ada Data',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          const Text(
            'Cache kosong dan tidak ada koneksi server.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            onPressed: onRetry,
            icon: const Icon(Icons.cloud_download_rounded),
            label: const Text('Tarik Data Server'),
          )
        ],
      ),
    );
  }

  Widget _buildSensorCard(BuildContext context, ParkingSensor sensor) {
    final totalSlots = sensor.availableSlots + sensor.occupiedSlots;
    final isFull = sensor.availableSlots == 0 && totalSlots > 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242430) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetailScreen(sensor: sensor)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: isFull ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    isFull ? Icons.block_flipped : Icons.local_parking_rounded,
                    color: isFull ? Colors.red : Colors.blue,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sensor.deviceName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: sensor.isActive 
                                ? Colors.green.withOpacity(0.1) 
                                : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  sensor.isActive ? Icons.circle : Icons.circle_outlined,
                                  size: 8,
                                  color: sensor.isActive ? Colors.green : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  sensor.isActive ? 'Active' : 'Offline',
                                  style: TextStyle(
                                    fontSize: 10, 
                                    fontWeight: FontWeight.bold,
                                    color: sensor.isActive ? Colors.green : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isFull ? 'Kapasitas Penuh' : '${sensor.availableSlots} slot tersedia',
                            style: TextStyle(
                              color: isFull ? Colors.red : Colors.green,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
