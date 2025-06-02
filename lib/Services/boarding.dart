import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Api/boarding_service.dart';

class Boarding extends StatefulWidget {
  const Boarding({Key? key}) : super(key: key);

  @override
  State<Boarding> createState() => _BoardingState();
}

class _BoardingState extends State<Boarding> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController petNameController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;
  int totalPrice = 0;
  String selectedSpecies = 'Anjing';
  bool isLoading = false;

  final int pricePerDay = 10000;

  // Species options matching backend validation
  final List<String> speciesOptions = ['Anjing', 'Kucing', 'Kelinci', 'Burung'];

  // Green theme colors
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color darkGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFFE8F5E8);
  static const Color accentGreen = Color(0xFF66BB6A);

  void _calculateTotalPrice() {
    if (startDate != null && endDate != null && endDate!.isAfter(startDate!)) {
      int days = endDate!.difference(startDate!).inDays + 1;
      setState(() {
        totalPrice = days * pricePerDay;
      });
    } else {
      setState(() {
        totalPrice = 0;
      });
    }
  }

  Future<void> _selectDate({required bool isStart}) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = isStart
        ? now
        : (startDate != null ? startDate!.add(const Duration(days: 1)) : now);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryGreen,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
          if (endDate != null && endDate!.isBefore(startDate!)) {
            endDate = null;
          }
        } else {
          endDate = picked;
        }
        _calculateTotalPrice();
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Text('Harap lengkapi semua data yang diperlukan!'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Prepare data for API
      final Map<String, dynamic> boardingData = {
        'pet_name': petNameController.text.trim(),
        'species': selectedSpecies,
        'owner_name': ownerNameController.text.trim(),
        'owner_phone': phoneController.text.trim(),
        'owner_email': emailController.text.trim().isEmpty ? null : emailController.text.trim(),
        'start_date': DateFormat('yyyy-MM-dd').format(startDate!),
        'end_date': DateFormat('yyyy-MM-dd').format(endDate!),
        'special_instructions': notesController.text.trim().isEmpty ? null : notesController.text.trim(),
        'daily_rate': pricePerDay,
        'services': [], // Empty array for now, can be extended later
      };

      // Call API
      final response = await BoardingService.createBoarding(boardingData);

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Pemesanan berhasil disimpan!'),
            ],
          ),
          backgroundColor: primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );

      // Clear form
      _clearForm();

    } catch (e) {
      if (!mounted) return;
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Gagal menyimpan data: ${e.toString()}'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _clearForm() {
    ownerNameController.clear();
    phoneController.clear();
    emailController.clear();
    petNameController.clear();
    notesController.clear();
    setState(() {
      startDate = null;
      endDate = null;
      totalPrice = 0;
      selectedSpecies = 'Anjing';
    });
  }

  @override
  void dispose() {
    ownerNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    petNameController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaryGreen, size: 20),
          labelStyle: const TextStyle(color: darkGreen, fontSize: 14),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSpeciesDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedSpecies,
        decoration: const InputDecoration(
          labelText: 'Jenis Hewan',
          prefixIcon: Icon(Icons.category, color: primaryGreen, size: 20),
          labelStyle: TextStyle(color: darkGreen, fontSize: 14),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        items: speciesOptions.map((String species) {
          return DropdownMenuItem<String>(
            value: species,
            child: Text(species),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              selectedSpecies = newValue;
            });
          }
        },
        validator: (value) => value == null ? 'Pilih jenis hewan' : null,
      ),
    );
  }

  Widget _buildDateSelector({
    required String title,
    required DateTime? selectedDate,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(icon, color: primaryGreen, size: 20),
        title: Text(
          selectedDate == null
              ? title
              : '${title}: ${DateFormat('dd MMM yyyy').format(selectedDate)}',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: selectedDate == null ? Colors.grey[600] : darkGreen,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: primaryGreen, size: 16),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Penitipan Hewan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryGreen,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryGreen, Color(0xFFF5F5F5)],
            stops: [0.0, 0.3],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: lightGreen,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Icon(
                          Icons.pets,
                          size: 40,
                          color: primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Formulir Penitipan',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: darkGreen,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Isi data lengkap untuk penitipan hewan kesayangan Anda',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Owner Information Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: lightGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: primaryGreen,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Data Pemilik',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        controller: ownerNameController,
                        label: 'Nama Pemilik',
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Masukkan nama pemilik';
                          }
                          if (value.trim().length > 255) {
                            return 'Nama terlalu panjang (maksimal 255 karakter)';
                          }
                          return null;
                        },
                      ),
                      _buildInputField(
                        controller: phoneController,
                        label: 'Nomor Telepon',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Masukkan nomor telepon';
                          }
                          if (value.trim().length > 20) {
                            return 'Nomor telepon terlalu panjang';
                          }
                          return null;
                        },
                      ),
                      _buildInputField(
                        controller: emailController,
                        label: 'Email (Opsional)',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                              return 'Format email tidak valid';
                            }
                            if (value.trim().length > 255) {
                              return 'Email terlalu panjang';
                            }
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Pet Information Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: lightGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.pets,
                              color: primaryGreen,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Data Hewan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        controller: petNameController,
                        label: 'Nama Hewan',
                        icon: Icons.pets,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Masukkan nama hewan';
                          }
                          if (value.trim().length > 255) {
                            return 'Nama hewan terlalu panjang';
                          }
                          return null;
                        },
                      ),
                      _buildSpeciesDropdown(),
                      _buildInputField(
                        controller: notesController,
                        label: 'Catatan Khusus',
                        icon: Icons.note_alt,
                        maxLines: 3,
                        validator: (value) {
                          if (value != null && value.trim().length > 1000) {
                            return 'Catatan terlalu panjang (maksimal 1000 karakter)';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Booking Schedule Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: lightGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.schedule,
                              color: primaryGreen,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Jadwal Penitipan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildDateSelector(
                        title: 'Pilih Tanggal Mulai',
                        selectedDate: startDate,
                        onTap: () => _selectDate(isStart: true),
                        icon: Icons.calendar_today,
                      ),
                      _buildDateSelector(
                        title: 'Pilih Tanggal Selesai',
                        selectedDate: endDate,
                        onTap: () => _selectDate(isStart: false),
                        icon: Icons.event_available,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Price Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [primaryGreen, accentGreen],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: primaryGreen.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 30,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Total Biaya',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Rp ${NumberFormat("#,###", "id_ID").format(totalPrice)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (startDate != null && endDate != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${endDate!.difference(startDate!).inDays + 1} hari × Rp ${NumberFormat("#,###", "id_ID").format(pricePerDay)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      shadowColor: darkGreen.withOpacity(0.3),
                    ),
                    child: isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text('Menyimpan...'),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send, size: 20),
                              SizedBox(width: 10),
                              Text(
                                'Pesan Penitipan',
                                style: TextStyle(
                                  fontSize: 16,
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
      ),
    );
  }
}