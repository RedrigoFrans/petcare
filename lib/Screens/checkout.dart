import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;

class Checkout extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final VoidCallback onConfirm;

  const Checkout({
    super.key,
    required this.cartItems,
    required this.onConfirm,
  });

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  late List<bool> _selectedItems;
  XFile? _pickedFile;
  Uint8List? _webImage;
  final TextEditingController _addressController = TextEditingController();

  static const Color primaryGreen = Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    _selectedItems = List<bool>.filled(widget.cartItems.length, true);
  }

  double get totalPrice {
    double total = 0;
    for (int i = 0; i < widget.cartItems.length; i++) {
      if (_selectedItems[i]) {
        double price = widget.cartItems[i]['price'] ?? 0.0;
        int qty = widget.cartItems[i]['quantity'] ?? 1;
        total += price * qty;
      }
    }
    return total;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Pilih Sumber Gambar"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Galeri",
                      style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
                    ),
                  ),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
                    _processPickedFile(pickedFile);
                  },
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Kamera",
                      style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
                    ),
                  ),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 75);
                    _processPickedFile(pickedFile);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _processPickedFile(XFile? pickedFile) {
    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
        if (kIsWeb) {
          pickedFile.readAsBytes().then((value) {
            setState(() {
              _webImage = value;
            });
          });
        }
      });
    }
  }

  Widget _buildImagePreview() {
    if (_pickedFile == null) {
      return const SizedBox.shrink();
    }
    if (kIsWeb) {
      if (_webImage != null) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Image.memory(_webImage!, height: 150, fit: BoxFit.cover),
        );
      } else {
        return const Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(),
        );
      }
    } else {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Image.file(File(_pickedFile!.path), height: 150, fit: BoxFit.cover),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: primaryGreen,
      ),
      body: widget.cartItems.isEmpty
          ? const Center(child: Text("Keranjang kamu kosong"))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = widget.cartItems[index];
                      return CheckboxListTile(
                        activeColor: primaryGreen,
                        checkColor: Colors.white,
                        value: _selectedItems[index],
                        onChanged: (value) {
                          setState(() {
                            _selectedItems[index] = value ?? false;
                          });
                        },
                        title: Text(item['name']),
                        subtitle: Row(
                          children: [
                            Text("Rp ${item['price'].toStringAsFixed(0)}"),
                            const SizedBox(width: 8),
                            Text("Jumlah: ${item['quantity'] ?? 1}"),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),

                // Tambahan Input Alamat
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Alamat Pengiriman",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _addressController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: "Tulis alamat lengkap Anda...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                _buildImagePreview(),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Metode Pembayaran",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text("Silakan transfer ke rekening berikut:"),
                      const SizedBox(height: 4),
                      Card(
                        color: primaryGreen.withOpacity(0.2),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Bank BCA", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text("No. Rek: 1234567890"),
                              Text("a.n. PT. Petcare Indonesia"),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Total: Rp ${totalPrice.toStringAsFixed(0)}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.upload),
                        label: const Text("Unggah Bukti Transfer (Screenshot)"),
                        style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          if (totalPrice == 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Pilih item terlebih dahulu")),
                            );
                            return;
                          }

                          if (_pickedFile == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Mohon unggah bukti pembayaran (SS)")),
                            );
                            return;
                          }

                          if (_addressController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Mohon isi alamat pengiriman")),
                            );
                            return;
                          }

                          widget.onConfirm();
                        },
                        child: const Text("Konfirmasi Pembayaran"),
                        style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
