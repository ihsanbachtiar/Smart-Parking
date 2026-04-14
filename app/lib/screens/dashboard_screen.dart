import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/parking_provider.dart';
import 'detail_screen.dart';
import 'profile_screen.dart';
import '../models/parking_sensor.dart';

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
      duration: const Duration(milliseconds: 800),
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
        title: const Text('Dashboard Sensor', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.9),
                Theme.of(context).primaryColor.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Hapus Cache',
            icon: const Icon(Icons.delete_sweep, color: Colors.white),
            onPressed: () {
              provider.clearCache();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache berhasil dihapus!')),
              );
            },
          ),
          IconButton(
            tooltip: 'Refresh Data',
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              provider.fetchParkingData();
            },
          ),
          IconButton(
            tooltip: 'Profil',
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark 
              ? [const Color(0xFF1E1E1E), const Color(0xFF121212)]
              : [const Color(0xFFE3F2FD), const Color(0xFFF5F7FA)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildSourceIndicator(provider.source),
              Expanded(
                child: _buildBodyContent(provider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceIndicator(DataSource source) {
    if (source == DataSource.none) return const SizedBox.shrink();
    
    final isOnline = source == DataSource.online;
    final color = isOnline ? Colors.green : Colors.orange;
    final text = isOnline ? '🟢 Live Online Data' : '🟠 Offline Cached Data';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
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
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 8),
            itemCount: provider.sensors.length,
            itemBuilder: (context, index) {
              final sensor = provider.sensors[index];
              return AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _animationController,
                      curve: Interval(
                        (index / provider.sensors.length) * 0.5,
                        1.0,
                        curve: Curves.easeOutQuart,
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_off, size: 64, color: Colors.red),
            ),
            const SizedBox(height: 24),
            Text(
              'Oh tidak! Koneksi Terputus',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Refresh Lagi', style: TextStyle(fontSize: 16)),
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          const Text(
            'Tidak Ada Data (Cache Kosong)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pastikan server API menyala dan coba lagi.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh Data'),
          )
        ],
      ),
    );
  }

  Widget _buildSensorCard(BuildContext context, ParkingSensor sensor) {
    final totalSlots = sensor.availableSlots + sensor.occupiedSlots;
    final isFull = sensor.availableSlots == 0 && totalSlots > 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailScreen(sensor: sensor),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: isDark 
                ? [const Color(0xFF2C2C2C), const Color(0xFF1F1F1F)]
                : [Colors.white, const Color(0xFFFDFDFD)],
            ),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isFull 
                      ? [Colors.red.shade400, Colors.red.shade700] 
                      : [Colors.blue.shade400, Colors.blue.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (isFull ? Colors.red : Colors.blue).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  isFull ? Icons.do_not_disturb_alt : Icons.local_parking_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sensor.deviceName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          isFull ? Icons.warning_rounded : Icons.check_circle_rounded,
                          size: 16,
                          color: isFull ? Colors.red : Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isFull ? 'Kapasitas Penuh' : '${sensor.availableSlots} slot tersedia',
                          style: TextStyle(
                            color: isFull ? Colors.red : Colors.green,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: sensor.isActive 
                              ? Colors.green.withOpacity(0.1) 
                              : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: sensor.isActive ? Colors.green : Colors.grey,
                              width: 0.5,
                            )
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                sensor.isActive ? Icons.power : Icons.power_off,
                                size: 10,
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
                        const Spacer(),
                        const Text(
                          'Lihat Detail',
                          style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w500),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.blue),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
