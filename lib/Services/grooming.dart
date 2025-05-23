import 'package:flutter/material.dart';

class Grooming extends StatefulWidget {
  const Grooming({Key? key}) : super(key: key);

  @override
  State<Grooming> createState() => _GroomingScreenState();
}

class _GroomingScreenState extends State<Grooming> {
  final _formKey = GlobalKey<FormState>();

  bool isAdmin = false;

  String selectedPackage = 'Basic';
  bool pickupNeeded = false;
  String pickupTime = 'Pagi';
  String groomingStatus = 'Dipesan';
  double distance = 1.0;

  // Hewan info
  String petName = '';
  String petType = 'Anjing';
  String petSize = 'Kecil';
  String notes = '';
  String phoneNumber = '';

  // Deskripsi paket grooming
  final Map<String, String> groomingDescriptions = {
    'Basic': 'Mandi, kering, potong kuku, bersih telinga. Untuk perawatan rutin.',
    'Premium': 'Basic + potong bulu, pembersihan kelenjar, parfum. Tampilan lebih rapi.',
    'Full Treatment': 'Premium + anti-kutu, masker bulu, pijat relaksasi. Perawatan menyeluruh.',
  };

  // Package prices for visual display
  final Map<String, int> packagePrices = {
    'Basic': 50000,
    'Premium': 85000,
    'Full Treatment': 120000,
  };

  // Package icons
  final Map<String, IconData> packageIcons = {
    'Basic': Icons.pets,
    'Premium': Icons.star,
    'Full Treatment': Icons.diamond,
  };

  double getPickupFee() {
    if (!pickupNeeded) return 0;
    if (distance <= 3) return 10000;
    if (distance <= 6) return 20000;
    return 30000;
  }

  void _submitGrooming() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Simpan ke database di sini

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Layanan Grooming diterima menunggu konfirmasi admin'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Layanan Grooming', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pet Information Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.pets, color: Colors.green),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Data Hewan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Nama Hewan',
                          prefixIcon: const Icon(Icons.pets_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        onSaved: (val) => petName = val ?? '',
                        validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Nomor Telepon',
                          prefixIcon: const Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        keyboardType: TextInputType.phone,
                        onSaved: (val) => phoneNumber = val ?? '',
                        validator: (val) => val == null || val.isEmpty ? 'Nomor telepon wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: petType,
                        decoration: InputDecoration(
                          labelText: 'Jenis Hewan',
                          prefixIcon: const Icon(Icons.category_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: ['Anjing', 'Kucing', 'Lainnya']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) => setState(() => petType = val!),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: petSize,
                        decoration: InputDecoration(
                          labelText: 'Ukuran Hewan',
                          prefixIcon: const Icon(Icons.straighten_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: ['Kecil', 'Sedang', 'Besar']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) => setState(() => petSize = val!),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Catatan Khusus',
                          prefixIcon: const Icon(Icons.note_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        maxLines: 2,
                        onSaved: (val) => notes = val ?? '',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Grooming Package Selection Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.spa, color: Colors.green),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Pilih Paket Grooming',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...['Basic', 'Premium', 'Full Treatment'].map((option) {
                        bool isSelected = selectedPackage == option;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? Colors.green : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                            color: isSelected ? Colors.green.shade100 : Colors.white,
                          ),
                          child: RadioListTile(
                            title: Row(
                              children: [
                                Icon(
                                  packageIcons[option],
                                  color: isSelected ? Colors.green : Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  option,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.green : Colors.black87,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.green : Colors.grey[400],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Rp ${packagePrices[option]!.toString()}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                groomingDescriptions[option] ?? '',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            value: option,
                            groupValue: selectedPackage,
                            onChanged: (val) => setState(() => selectedPackage = val.toString()),
                            activeColor: Colors.green,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Pickup Service Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.local_shipping, color: Colors.green),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Layanan Antar-Jemput',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: CheckboxListTile(
                          title: const Text('Butuh antar-jemput?'),
                          subtitle: const Text('Kami akan menjemput dan mengantar hewan peliharaan Anda'),
                          value: pickupNeeded,
                          onChanged: (val) => setState(() => pickupNeeded = val ?? false),
                          activeColor: Colors.green,
                        ),
                      ),
                      if (pickupNeeded) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Alamat Penjemputan',
                            prefixIcon: const Icon(Icons.location_on_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          validator: (val) {
                            if (pickupNeeded && (val == null || val.isEmpty)) {
                              return 'Alamat harus diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: pickupTime,
                          decoration: InputDecoration(
                            labelText: 'Jadwal Penjemputan',
                            prefixIcon: const Icon(Icons.schedule_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          items: ['Pagi', 'Siang', 'Sore']
                              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (val) => setState(() => pickupTime = val!),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.straighten, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Estimasi Jarak: ${distance.toStringAsFixed(1)} km',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Slider(
                                value: distance,
                                min: 1,
                                max: 10,
                                divisions: 9,
                                label: '${distance.toStringAsFixed(1)} km',
                                onChanged: (val) => setState(() => distance = val),
                                activeColor: Colors.green,
                                inactiveColor: Colors.green.shade200,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Biaya Antar-Jemput: Rp ${getPickupFee().toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Status Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.track_changes, color: Colors.green),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Status Grooming',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      isAdmin
                          ? Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[300]!),
                          color: Colors.grey[50],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButton<String>(
                          value: groomingStatus,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: [
                            'Dipesan',
                            'Dalam Perjalanan',
                            'Sampai di Tempat Grooming',
                            'Selesai Grooming',
                            'Diantar Pulang',
                          ].map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(status)
                          )).toList(),
                          onChanged: (val) => setState(() => groomingStatus = val!),
                        ),
                      )
                          : Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green.shade100, Colors.green.shade200],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.info, color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Status: ",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              groomingStatus,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submitGrooming,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Konfirmasi Layanan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}