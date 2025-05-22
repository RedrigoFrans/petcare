import 'package:flutter/material.dart';

class Boarding extends StatefulWidget {
  const Boarding({Key? key}) : super(key: key);

  @override
  State<Boarding> createState() => _BoardingScreenState();
}

class _BoardingScreenState extends State<Boarding> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _petNameController = TextEditingController();
  String? _species;
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _selectDate({
    required BuildContext context,
    required bool isStartDate,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pilih tanggal titip dan ambil")),
        );
        return;
      }

      // Simulasi penyimpanan data
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Data Penitipan"),
          content: Text(
            "Nama Hewan: ${_petNameController.text}\n"
                "Jenis: $_species\n"
                "Titip: ${_startDate!.toLocal().toString().split(' ')[0]}\n"
                "Ambil: ${_endDate!.toLocal().toString().split(' ')[0]}",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _formKey.currentState!.reset();
                _petNameController.clear();
                setState(() {
                  _species = null;
                  _startDate = null;
                  _endDate = null;
                });
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _petNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Penitipan Hewan'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Isi Data Penitipan:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _petNameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Hewan',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _species,
                items: const [
                  DropdownMenuItem(value: 'Anjing', child: Text('Anjing')),
                  DropdownMenuItem(value: 'Kucing', child: Text('Kucing')),
                  DropdownMenuItem(value: 'Kelinci', child: Text('Kelinci')),
                  DropdownMenuItem(value: 'Burung', child: Text('Burung')),
                ],
                onChanged: (value) => setState(() => _species = value),
                decoration: const InputDecoration(
                  labelText: 'Jenis Hewan',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null ? 'Pilih jenis hewan' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  _startDate == null
                      ? 'Pilih tanggal dititipkan'
                      : 'Dititipkan: ${_startDate!.toLocal().toString().split(' ')[0]}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context: context, isStartDate: true),
              ),
              ListTile(
                title: Text(
                  _endDate == null
                      ? 'Pilih tanggal diambil'
                      : 'Diambil: ${_endDate!.toLocal().toString().split(' ')[0]}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context: context, isStartDate: false),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Kirim Data',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
