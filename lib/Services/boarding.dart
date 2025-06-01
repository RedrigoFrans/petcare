import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Boarding extends StatefulWidget {
  const Boarding({Key? key}) : super(key: key);

  @override
  State<Boarding> createState() => _BoardingScreenState();
}

class _BoardingScreenState extends State<Boarding> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  // Form controllers
  final TextEditingController _petNameController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _ownerPhoneController = TextEditingController();
  final TextEditingController _ownerEmailController = TextEditingController();
  final TextEditingController _specialInstructionsController = TextEditingController();
  final TextEditingController _dailyRateController = TextEditingController();

  String? _species;
  DateTime? _startDate;
  DateTime? _endDate;
  List<String> _selectedServices = [];
  List<Map<String, dynamic>> _boardings = [];
  bool _isLoading = false;

  final List<String> _availableServices = [
    'Grooming',
    'Exercise/Walk',
    'Feeding Premium',
    'Play Time',
    'Bath Service',
    'Nail Trimming'
  ];

  final Map<String, double> _speciesRates = {
    'Anjing': 75000,
    'Kucing': 60000,
    'Kelinci': 45000,
    'Burung': 35000,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBoardings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _petNameController.dispose();
    _ownerNameController.dispose();
    _ownerPhoneController.dispose();
    _ownerEmailController.dispose();
    _specialInstructionsController.dispose();
    _dailyRateController.dispose();
    super.dispose();
  }

  Future<void> _loadBoardings() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/boardings'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _boardings = List<Map<String, dynamic>>.from(data['data']);
        });
      }
    } catch (e) {
      _showSnackBar('Error loading data: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate({
    required BuildContext context,
    required bool isStartDate,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.teal,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
        _updateDailyRate();
      });
    }
  }

  void _updateDailyRate() {
    if (_species != null && _speciesRates.containsKey(_species)) {
      _dailyRateController.text = _speciesRates[_species]!.toStringAsFixed(0);
    }
  }

  double _calculateTotalCost() {
    if (_startDate == null || _endDate == null || _dailyRateController.text.isEmpty) {
      return 0;
    }
    final days = _endDate!.difference(_startDate!).inDays + 1;
    final dailyRate = double.tryParse(_dailyRateController.text) ?? 0;
    return days * dailyRate;
  }

  int _calculateDays() {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      _showSnackBar("Pilih tanggal titip dan ambil", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    final boardingData = {
      'pet_name': _petNameController.text,
      'species': _species,
      'owner_name': _ownerNameController.text,
      'owner_phone': _ownerPhoneController.text,
      'owner_email': _ownerEmailController.text.isEmpty ? null : _ownerEmailController.text,
      'start_date': _startDate!.toIso8601String().split('T')[0],
      'end_date': _endDate!.toIso8601String().split('T')[0],
      'special_instructions': _specialInstructionsController.text.isEmpty ? null : _specialInstructionsController.text,
      'daily_rate': double.parse(_dailyRateController.text),
      'services': _selectedServices,
    };

    try {
      final response = await http.post(
        Uri.parse('http://your-api-url/api/boardings'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(boardingData),
      );

      if (response.statusCode == 201) {
        _showSnackBar("Data penitipan berhasil disimpan!", Colors.green);
        _resetForm();
        _loadBoardings();
        _tabController.animateTo(1); // Switch to list tab
      } else {
        final error = json.decode(response.body);
        _showSnackBar("Error: ${error['message']}", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Error: $e", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _petNameController.clear();
    _ownerNameController.clear();
    _ownerPhoneController.clear();
    _ownerEmailController.clear();
    _specialInstructionsController.clear();
    _dailyRateController.clear();
    setState(() {
      _species = null;
      _startDate = null;
      _endDate = null;
      _selectedServices.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Boarding Service'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.add), text: 'Tambah Penitipan'),
            Tab(icon: Icon(Icons.list), text: 'Daftar Penitipan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFormTab(),
          _buildListTab(),
        ],
      ),
    );
  }

  Widget _buildFormTab() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.teal.shade50, Colors.white],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildSectionCard(
                title: 'Informasi Hewan Peliharaan',
                icon: Icons.pets,
                children: [
                  _buildTextField(
                    controller: _petNameController,
                    label: 'Nama Hewan',
                    icon: Icons.pets,
                    validator: (value) => value?.isEmpty ?? true ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Informasi Pemilik',
                icon: Icons.person,
                children: [
                  _buildTextField(
                    controller: _ownerNameController,
                    label: 'Nama Pemilik',
                    icon: Icons.person,
                    validator: (value) => value?.isEmpty ?? true ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _ownerPhoneController,
                    label: 'Nomor Telepon',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) => value?.isEmpty ?? true ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _ownerEmailController,
                    label: 'Email (Opsional)',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Jadwal Penitipan',
                icon: Icons.calendar_today,
                children: [
                  _buildDateTile(
                    title: _startDate == null
                        ? 'Pilih tanggal dititipkan'
                        : 'Dititipkan: ${_startDate!.toLocal().toString().split(' ')[0]}',
                    onTap: () => _selectDate(context: context, isStartDate: true),
                  ),
                  _buildDateTile(
                    title: _endDate == null
                        ? 'Pilih tanggal diambil'
                        : 'Diambil: ${_endDate!.toLocal().toString().split(' ')[0]}',
                    onTap: () => _selectDate(context: context, isStartDate: false),
                  ),
                  if (_startDate != null && _endDate != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Durasi: ${_calculateDays()} hari',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Layanan Tambahan',
                icon: Icons.star,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableServices.map((service) {
                      final isSelected = _selectedServices.contains(service);
                      return FilterChip(
                        label: Text(service),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedServices.add(service);
                            } else {
                              _selectedServices.remove(service);
                            }
                          });
                        },
                        selectedColor: Colors.teal.shade100,
                        checkmarkColor: Colors.teal.shade700,
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Biaya & Catatan',
                icon: Icons.attach_money,
                children: [
                  _buildTextField(
                    controller: _dailyRateController,
                    label: 'Tarif per Hari (Rp)',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty ?? true ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  if (_startDate != null && _endDate != null && _dailyRateController.text.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Biaya:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                            ),
                          ),
                          Text(
                            'Rp ${_calculateTotalCost().toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _specialInstructionsController,
                    label: 'Instruksi Khusus (Opsional)',
                    icon: Icons.note,
                    maxLines: 3,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Simpan Data Penitipan',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListTab() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.teal.shade50, Colors.white],
        ),
      ),
      child: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadBoardings,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _boardings.length,
              itemBuilder: (context, index) {
                final boarding = _boardings[index];
                return _buildBoardingCard(boarding);
              },
            ),
          ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.teal, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
      ),
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: (value) {
        if (controller == _dailyRateController) {
          setState(() {});
        }
      },
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _species,
      items: _speciesRates.keys.map((species) {
        return DropdownMenuItem(
          value: species,
          child: Row(
            children: [
              Icon(_getSpeciesIcon(species), color: Colors.teal, size: 20),
              const SizedBox(width: 8),
              Text(species),
              const Spacer(),
              Text(
                'Rp ${_speciesRates[species]!.toStringAsFixed(0)}/hari',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _species = value;
          _updateDailyRate();
        });
      },
      decoration: InputDecoration(
        labelText: 'Jenis Hewan',
        prefixIcon: const Icon(Icons.category, color: Colors.teal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
      ),
      validator: (value) => value == null ? 'Pilih jenis hewan' : null,
    );
  }

  IconData _getSpeciesIcon(String species) {
    switch (species) {
      case 'Anjing':
        return Icons.pets;
      case 'Kucing':
        return Icons.pets;
      case 'Kelinci':
        return Icons.cruelty_free;
      case 'Burung':
        return Icons.flutter_dash;
      default:
        return Icons.pets;
    }
  }

  Widget _buildDateTile({
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.teal),
              const SizedBox(width: 12),
              Expanded(child: Text(title)),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade600),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoardingCard(Map<String, dynamic> boarding) {
    final status = boarding['status'] ?? 'pending';
    final statusColor = _getStatusColor(status);
    
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        boarding['pet_name'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            _getSpeciesIcon(boarding['species'] ?? ''),
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            boarding['species'] ?? '',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    _getStatusText(status),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Pemilik', boarding['owner_name'] ?? '', Icons.person),
                  const SizedBox(height: 8),
                  _buildInfoRow('Telepon', boarding['owner_phone'] ?? '', Icons.phone),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Periode',
                    '${boarding['start_date']} - ${boarding['end_date']}',
                    Icons.date_range,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Total Biaya',
                    'Rp ${boarding['total_cost']?.toString() ?? '0'}',
                    Icons.attach_money,
                  ),
                ],
              ),
            ),
            if (boarding['services'] != null && (boarding['services'] as List).isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  const Text(
                    'Layanan Tambahan:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: (boarding['services'] as List).map<Widget>((service) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          service.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.teal.shade800,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            if (boarding['special_instructions'] != null && boarding['special_instructions'].toString().isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  const Text(
                    'Instruksi Khusus:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    boarding['special_instructions'].toString(),
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (status == 'pending')
                  TextButton.icon(
                    onPressed: () => _updateBoardingStatus(boarding['id'], 'active'),
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: const Text('Mulai'),
                    style: TextButton.styleFrom(foregroundColor: Colors.green),
                  ),
                if (status == 'active')
                  TextButton.icon(
                    onPressed: () => _updateBoardingStatus(boarding['id'], 'completed'),
                    icon: const Icon(Icons.check_circle, size: 16),
                    label: const Text('Selesai'),
                    style: TextButton.styleFrom(foregroundColor: Colors.blue),
                  ),
                TextButton.icon(
                  onPressed: () => _showBoardingDetails(boarding),
                  icon: const Icon(Icons.info, size: 16),
                  label: const Text('Detail'),
                  style: TextButton.styleFrom(foregroundColor: Colors.teal),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'active':
        return 'Aktif';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return 'Unknown';
    }
  }

  Future<void> _updateBoardingStatus(int id, String newStatus) async {
    try {
      final response = await http.patch(
        Uri.parse('http://your-api-url/api/boardings/$id/status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        _showSnackBar('Status berhasil diperbarui', Colors.green);
        _loadBoardings();
      } else {
        _showSnackBar('Gagal memperbarui status', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    }
  }

  void _showBoardingDetails(Map<String, dynamic> boarding) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail Penitipan - ${boarding['pet_name']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Nama Hewan', boarding['pet_name']),
              _buildDetailRow('Jenis', boarding['species']),
              _buildDetailRow('Pemilik', boarding['owner_name']),
              _buildDetailRow('Telepon', boarding['owner_phone']),
              if (boarding['owner_email'] != null)
                _buildDetailRow('Email', boarding['owner_email']),
              _buildDetailRow('Tanggal Mulai', boarding['start_date']),
              _buildDetailRow('Tanggal Selesai', boarding['end_date']),
              _buildDetailRow('Tarif Harian', 'Rp ${boarding['daily_rate']}'),
              _buildDetailRow('Total Biaya', 'Rp ${boarding['total_cost']}'),
              _buildDetailRow('Status', _getStatusText(boarding['status'])),
              if (boarding['special_instructions'] != null)
                _buildDetailRow('Instruksi Khusus', boarding['special_instructions']),
              if (boarding['notes'] != null)
                _buildDetailRow('Catatan Staff', boarding['notes']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value?.toString() ?? '-')),
        ],
      ),
    );
  }
}