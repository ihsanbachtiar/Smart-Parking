const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

// Dummy data yang relevan dengan konteks IoT (Smart Parking)
const parkingData = [
  {
    "id": "SENS-001",
    "device_name": "Sensor Parkir Lobby A",
    "description": "Smart Distance Sensor untuk mendeteksi kendaraan di Lobby Utama A.",
    "available_slots": 5,
    "occupied_slots": 15,
    "is_active": true,
    "updated_at": new Date(Date.now() - 1000 * 60 * 5).toISOString() // 5 menit lalu
  },
  {
    "id": "SENS-002",
    "device_name": "Sensor Parkir Basement 1",
    "description": "Kamera CCTV dan Sensor Ultrasonik pada area VIP Basement 1.",
    "available_slots": 0,
    "occupied_slots": 50,
    "is_active": true,
    "updated_at": new Date().toISOString()
  },
  {
    "id": "SENS-003",
    "device_name": "Sensor Parkir Outdoor B",
    "description": "Sensor Tanah Nirkabel (Wireless Ground Sensor) di area terbuka B.",
    "available_slots": 24,
    "occupied_slots": 12,
    "is_active": false,
    "updated_at": new Date(Date.now() - 1000 * 60 * 60 * 12).toISOString() // 12 jam lalu
  },
  {
    "id": "SENS-004",
    "device_name": "Monitoring Slot VIP C",
    "description": "Sensor pendeteksi parkir khusus roda dua area C.",
    "available_slots": 10,
    "occupied_slots": 0,
    "is_active": true,
    "updated_at": new Date().toISOString()
  },
  {
    "id": "SENS-005",
    "device_name": "Kamera Pengawas Pintu Masuk",
    "description": "Kamera ANPR untuk mencatat pelat nomor di pintu Utara.",
    "available_slots": 4,
    "occupied_slots": 1,
    "is_active": true,
    "updated_at": new Date(Date.now() - 1000 * 60 * 2).toISOString() 
  },
  {
    "id": "SENS-006",
    "device_name": "Sensor Parkir Gedung Timur",
    "description": "In-ground magnetic sensor untuk area eksekutif Timur.",
    "available_slots": 0,
    "occupied_slots": 20,
    "is_active": true,
    "updated_at": new Date(Date.now() - 1000 * 60 * 15).toISOString() 
  },
  {
    "id": "SENS-007",
    "device_name": "Radar Occupancy Rooftop",
    "description": "Radar pemantau keseluruhan area parkir lantai teratas (Rooftop).",
    "available_slots": 45,
    "occupied_slots": 5,
    "is_active": false,
    "updated_at": new Date(Date.now() - 1000 * 60 * 60 * 48).toISOString() // 2 hari lalu
  }
];

// Endpoint untuk fetcing semua data parking
app.get('/api/parking', (req, res) => {
  console.log(`[${new Date().toISOString()}] GET /api/parking diakses`);
  
  // Simulasi network delay sedikit agar aplikasi mobile (Loading State) terlihat alami
  setTimeout(() => {
    res.json(parkingData);
  }, 1000);
});

// Endpoint untuk fetching specific sensor by ID
app.get('/api/parking/:id', (req, res) => {
  const sensor = parkingData.find(s => s.id === req.params.id);
  if (sensor) {
    res.json(sensor);
  } else {
    res.status(404).json({ message: "Sensor device not found" });
  }
});

const PORT = 3500;
app.listen(PORT, () => {
  console.log(`Smart Parking Mock API berjalan di http://localhost:${PORT}`);
  console.log(`- Data Parkir: http://localhost:${PORT}/api/parking`);
});
