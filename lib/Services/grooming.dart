import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Grooming extends StatefulWidget {
  const Grooming({Key? key}) : super(key: key);

  @override
  State<Grooming> createState() => _GroomingState();
}

class _GroomingState extends State<Grooming> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool showPackageSelection = true;
  String selectedPackage = 'Basic';

  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);

  String contactNumber = '';
  String contactEmail = '';
  String additionalNotes = '';

  final Map<String, String> groomingDescriptions = {
    'Basic': 'Mandi, kering, potong kuku, bersih telinga.',
    'Premium': 'Basic + potong bulu, parfum, kelenjar.',
    'Full Treatment': 'Premium + anti-kutu, masker bulu, relaksasi.',
  };

  final Map<String, int> packagePrices = {
    'Basic': 50000,
    'Premium': 85000,
    'Full Treatment': 120000,
  };

  final Map<String, IconData> packageIcons = {
    'Basic': Icons.pets,
    'Premium': Icons.star,
    'Full Treatment': Icons.diamond,
  };

  final Map<String, Color> packageColors = {
    'Basic': const Color(0xFF4CAF50),
    'Premium': const Color(0xFF2E7D32),
    'Full Treatment': const Color(0xFF1B5E20),
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _continueToBooking() {
    _animationController.reset();
    setState(() {
      showPackageSelection = false;
    });
    _animationController.forward();
  }

  void _backToPackageSelection() {
    _animationController.reset();
    setState(() {
      showPackageSelection = true;
    });
    _animationController.forward();
  }

  Future<void> _submitBooking() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(color: Color(0xFF4CAF50)),
                SizedBox(width: 20),
                Text("Mengirim booking..."),
              ],
            ),
          );
        },
      );

      final url = Uri.parse('http://127.0.0.1:8000/api/groomings');

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'kategori': selectedPackage.toLowerCase().replaceAll(' ', '_'),
            'tanggal': selectedDate.toIso8601String().split('T').first,
            'jam': '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
            'email': contactEmail,
            'phone': contactNumber,
            'catatan': additionalNotes,
          }),
        );

        Navigator.pop(context); // Close loading dialog

        if (response.statusCode == 201) {
          _showSuccessDialog();
        } else {
          _showErrorSnackBar('Gagal: ${response.body}');
        }
      } catch (e) {
        Navigator.pop(context); // Close loading dialog
        _showErrorSnackBar('Koneksi gagal. Silakan coba lagi.');
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 30),
              SizedBox(width: 10),
              Text('Berhasil!', style: TextStyle(color: Color(0xFF2E7D32))),
            ],
          ),
          content: Text('Booking grooming Anda berhasil dikirim!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('OK', style: TextStyle(color: Color(0xFF4CAF50))),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text(
          "Grooming Booking",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: showPackageSelection ? _buildPackageSelection() : _buildBookingForm(),
      ),
    );
  }

  Widget _buildPackageSelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF4CAF50).withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.pets, size: 40, color: Colors.white),
                SizedBox(height: 10),
                Text(
                  'Pilih Paket Grooming',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Berikan perawatan terbaik untuk hewan kesayangan Anda',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          ...packagePrices.keys.map((pkg) {
            bool isSelected = selectedPackage == pkg;
            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isSelected ? packageColors[pkg]! : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected 
                        ? packageColors[pkg]!.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1),
                    blurRadius: isSelected ? 8 : 4,
                    offset: Offset(0, isSelected ? 4 : 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: packageColors[pkg]!.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    packageIcons[pkg],
                    color: packageColors[pkg],
                    size: 28,
                  ),
                ),
                title: Text(
                  pkg,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? packageColors[pkg] : Colors.black87,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    Text(
                      groomingDescriptions[pkg]!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: packageColors[pkg]!.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Rp ${packagePrices[pkg]!.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: packageColors[pkg],
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: Radio<String>(
                  value: pkg,
                  groupValue: selectedPackage,
                  activeColor: packageColors[pkg],
                  onChanged: (val) {
                    setState(() {
                      selectedPackage = val!;
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    selectedPackage = pkg;
                  });
                },
              ),
            );
          }),
          const SizedBox(height: 30),
          Container(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _continueToBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                shadowColor: Color(0xFF4CAF50).withOpacity(0.4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Lanjut ke Booking",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    packageIcons[selectedPackage],
                    size: 40,
                    color: packageColors[selectedPackage],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Paket $selectedPackage',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: packageColors[selectedPackage],
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Rp ${packagePrices[selectedPackage]!.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            
            _buildSectionTitle('Jadwal Appointment'),
            const SizedBox(height: 10),
            
            _buildDateTimeCard(),
            const SizedBox(height: 25),
            
            _buildSectionTitle('Informasi Kontak'),
            const SizedBox(height: 10),
            
            _buildInputCard(
              child: Column(
                children: [
                  _buildTextField(
                    icon: Icons.email,
                    label: 'Email',
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Email wajib diisi';
                      if (!val.contains('@')) return 'Format email tidak valid';
                      return null;
                    },
                    onSaved: (val) => contactEmail = val!,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    icon: Icons.phone,
                    label: 'Nomor Telepon',
                    keyboardType: TextInputType.phone,
                    validator: (val) => val!.isEmpty ? 'Nomor telepon wajib diisi' : null,
                    onSaved: (val) => contactNumber = val!,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            
            _buildSectionTitle('Catatan Tambahan'),
            const SizedBox(height: 10),
            
            _buildInputCard(
              child: _buildTextField(
                icon: Icons.note,
                label: 'Catatan (opsional)',
                maxLines: 3,
                onSaved: (val) => additionalNotes = val ?? '',
              ),
            ),
            const SizedBox(height: 30),
            
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _backToPackageSelection,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Color(0xFF4CAF50), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_back, color: Color(0xFF4CAF50)),
                          SizedBox(width: 8),
                          Text(
                            "Kembali",
                            style: TextStyle(
                              color: Color(0xFF4CAF50),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submitBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        shadowColor: Color(0xFF4CAF50).withOpacity(0.4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send),
                          SizedBox(width: 8),
                          Text(
                            "Kirim Booking",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2E7D32),
      ),
    );
  }

  Widget _buildDateTimeCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(20),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.calendar_today, color: Color(0xFF4CAF50)),
            ),
            title: Text(
              "Tanggal",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            trailing: Icon(Icons.arrow_forward_ios, color: Color(0xFF4CAF50)),
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Color(0xFF4CAF50),
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: Colors.black,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() {
                  selectedDate = picked;
                });
              }
            },
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          ListTile(
            contentPadding: const EdgeInsets.all(20),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.access_time, color: Color(0xFF4CAF50)),
            ),
            title: Text(
              "Waktu",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              "${selectedTime.format(context)}",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            trailing: Icon(Icons.arrow_forward_ios, color: Color(0xFF4CAF50)),
            onTap: () async {
              TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: selectedTime,
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Color(0xFF4CAF50),
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: Colors.black,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() {
                  selectedTime = picked;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTextField({
    required IconData icon,
    required String label,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFF4CAF50)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF4CAF50), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        labelStyle: TextStyle(color: Colors.grey.shade600),
      ),
      validator: validator,
      onSaved: onSaved,
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }
}