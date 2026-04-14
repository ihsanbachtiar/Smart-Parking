import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/parking_sensor.dart';

class DetailScreen extends StatelessWidget {
  final ParkingSensor sensor;

  const DetailScreen({Key? key, required this.sensor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalSlots = sensor.availableSlots + sensor.occupiedSlots;
    final double occupancyRate = totalSlots > 0 ? (sensor.occupiedSlots / totalSlots) : 0;
    final isFull = sensor.availableSlots == 0 && totalSlots > 0;
    
    // Format timestamp
    final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(sensor.updatedAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Sensor'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: isFull ? Colors.red.shade50 : Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(
                      isFull ? Icons.do_not_disturb_alt : Icons.local_parking,
                      size: 64,
                      color: isFull ? Colors.red : Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      sensor.deviceName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: sensor.isActive ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        sensor.isActive ? 'SENSOR AKTIF' : 'SENSOR MATI (OFFLINE)',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Occupancy Visualization
            const Text(
              'Detail Okupansi Area',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            
            _buildInfoRow('ID Device', sensor.id, Icons.tag),
            const Divider(),
            _buildInfoRow('Deskripsi', sensor.description, Icons.info_outline),
            const Divider(),
            _buildInfoRow('Terakhir Update', formattedDate, Icons.access_time),
            
            const SizedBox(height: 32),
            
            // Slot Visualization Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Terisi: ${sensor.occupiedSlots}',
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Tersedia: ${sensor.availableSlots}',
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: occupancyRate,
                minHeight: 24,
                backgroundColor: Colors.green,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Total Kapasitas: $totalSlots Kendaraan',
                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
