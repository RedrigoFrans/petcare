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
  static const Color lightGreen = Color(0xFF81C784);
  static const Color darkGreen = Color(0xFF388E3C);

  @override
  void initState() {
    super.initState();
    _selectedItems = List<bool>.filled(widget.cartItems.length, true);
  }

  void _incrementQuantity(int index) {
    setState(() {
      widget.cartItems[index]['quantity'] =
          (widget.cartItems[index]['quantity'] ?? 1) + 1;
    });
  }

  void _decrementQuantity(int index) {
    setState(() {
      int currentQty = widget.cartItems[index]['quantity'] ?? 1;
      if (currentQty > 1) {
        widget.cartItems[index]['quantity'] = currentQty - 1;
      }
    });
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
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.camera_alt, color: primaryGreen),
              ),
              const SizedBox(width: 12),
              const Text("Pilih Sumber Gambar"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    final pickedFile = await picker.pickImage(
                        source: ImageSource.gallery, imageQuality: 75);
                    _processPickedFile(pickedFile);
                  },
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Galeri"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    final pickedFile = await picker.pickImage(
                        source: ImageSource.camera, imageQuality: 75);
                    _processPickedFile(pickedFile);
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Kamera"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: primaryGreen,
                    side: BorderSide(color: primaryGreen, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: primaryGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                "Bukti Transfer Berhasil Diunggah",
                style: TextStyle(
                  color: primaryGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: kIsWeb
                ? (_webImage != null
                ? Image.memory(_webImage!, height: 150,
                width: double.infinity,
                fit: BoxFit.cover)
                : Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                  child: CircularProgressIndicator(color: primaryGreen)),
            ))
                : Image.file(File(_pickedFile!.path), height: 150,
                width: double.infinity,
                fit: BoxFit.cover),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            "Checkout", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryGreen.withOpacity(0.3),
                  lightGreen.withOpacity(0.1)
                ],
              ),
            ),
          ),
        ),
      ),

      body: widget.cartItems.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 80,
                color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "Keranjang kamu kosong",
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      )
          : SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Cart Items Section (scrollable list inside fixed height container)
                      Container(
                        height: constraints.maxHeight * 0.4,
                        // Sesuaikan tinggi list
                        child: Builder(
                          builder: (context) {
                            final visibleItems = List.generate(
                                widget.cartItems.length, (i) => i)
                                .where((i) => _selectedItems[i])
                                .toList();

                            return ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: visibleItems.length,
                              itemBuilder: (context, index) {
                                final actualIndex = visibleItems[index];
                                final item = widget.cartItems[actualIndex];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: CheckboxListTile(
                                    activeColor: primaryGreen,
                                    checkColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            16)),
                                    value: _selectedItems[actualIndex],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedItems[actualIndex] =
                                            value ?? false;
                                      });
                                    },
                                    title: Text(
                                      item['name'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: primaryGreen
                                                      .withOpacity(0.1),
                                                  borderRadius: BorderRadius
                                                      .circular(8),
                                                ),
                                                child: Text(
                                                  "Rp ${item['price']
                                                      .toStringAsFixed(0)}",
                                                  style: TextStyle(
                                                    color: darkGreen,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                              const Spacer(),
                                              Container(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: 4, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[50],
                                                  borderRadius: BorderRadius
                                                      .circular(8),
                                                  border: Border.all(
                                                      color: Colors.grey[300]!),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize
                                                      .min,
                                                  children: [
                                                    InkWell(
                                                      onTap: () =>
                                                          _decrementQuantity(
                                                              actualIndex),
                                                      borderRadius: BorderRadius
                                                          .circular(4),
                                                      child: Container(
                                                        padding: const EdgeInsets
                                                            .all(4),
                                                        child: Icon(
                                                          Icons.remove,
                                                          size: 16,
                                                          color: (item['quantity'] ??
                                                              1) > 1
                                                              ? primaryGreen
                                                              : Colors
                                                              .grey[400],
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 12,
                                                          vertical: 4),
                                                      child: Text(
                                                        "${item['quantity'] ??
                                                            1}",
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight
                                                              .w600,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () =>
                                                          _incrementQuantity(
                                                              actualIndex),
                                                      borderRadius: BorderRadius
                                                          .circular(4),
                                                      child: Container(
                                                        padding: const EdgeInsets
                                                            .all(4),
                                                        child: Icon(
                                                          Icons.add,
                                                          size: 16,
                                                          color: primaryGreen,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: darkGreen.withOpacity(0.1),
                                              borderRadius: BorderRadius
                                                  .circular(6),
                                            ),
                                            child: Text(
                                              "Subtotal: Rp ${((item['price'] ??
                                                  0.0) *
                                                  (item['quantity'] ?? 1))
                                                  .toStringAsFixed(0)}",
                                              style: TextStyle(
                                                color: darkGreen,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Address Input Section
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
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
                                    color: primaryGreen.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                      Icons.location_on, color: primaryGreen,
                                      size: 20),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  "Alamat Pengiriman",
                                  style: TextStyle(fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _addressController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: "Tulis alamat lengkap Anda...",
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: primaryGreen, width: 2),
                                ),
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Image Preview
                      _buildImagePreview(),

                      const SizedBox(height: 12),

                      // Payment Section
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              primaryGreen.withOpacity(0.02)
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.15),
                              spreadRadius: 3,
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: primaryGreen.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                      Icons.payment, color: primaryGreen,
                                      size: 20),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  "Metode Pembayaran",
                                  style: TextStyle(fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Silakan transfer ke rekening berikut:",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    primaryGreen.withOpacity(0.1),
                                    lightGreen.withOpacity(0.05)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: primaryGreen.withOpacity(0.2)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.account_balance,
                                            color: primaryGreen, size: 20),
                                        const SizedBox(width: 8),
                                        const Text("Bank BCA", style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text("No. Rek: 1234567890",
                                        style: TextStyle(fontSize: 14,
                                            color: Colors.grey[700])),
                                    Text("a.n. PT. Petcare Indonesia",
                                        style: TextStyle(fontSize: 14,
                                            color: Colors.grey[700])),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [primaryGreen, lightGreen],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "Total: Rp ${totalPrice.toStringAsFixed(0)}",
                                style: const TextStyle(fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.upload_file),
                              label: const Text("Unggah Bukti Transfer",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: primaryGreen,
                                side: BorderSide(color: primaryGreen, width: 2),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {
                                if (totalPrice == 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          "Pilih item terlebih dahulu"),
                                      backgroundColor: Colors.orange,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              8)),
                                    ),
                                  );
                                  return;
                                }

                                if (_pickedFile == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          "Mohon unggah bukti pembayaran (SS)"),
                                      backgroundColor: Colors.orange,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              8)),
                                    ),
                                  );
                                  return;
                                }

                                if (_addressController.text
                                    .trim()
                                    .isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          "Mohon isi alamat pengiriman"),
                                      backgroundColor: Colors.orange,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              8)),
                                    ),
                                  );
                                  return;
                                }

                                widget.onConfirm();
                              },
                              child: const Text(
                                "Konfirmasi Pembayaran",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 18),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 4,
                                shadowColor: primaryGreen.withOpacity(0.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}