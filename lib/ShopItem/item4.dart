import 'package:flutter/material.dart';
import 'package:petcare1/Screens/checkout.dart';

class Item4 extends StatelessWidget {
  final String name;
  final String price;
  final String image;
  final Function(Map<String, dynamic>) onAddToCart;

  const Item4({
    super.key,
    required this.name,
    required this.price,
    required this.image,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final parsedPrice = int.tryParse(price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(name, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(image, height: 200, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 24),
                  Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(price, style: const TextStyle(fontSize: 18, color: Colors.green)),
                  const SizedBox(height: 24),
                  const Text("Deskripsi Produk", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                    "//Royal Canin Mother & Babycat adalah makanan khusus untuk induk kucing dan anak kucing usia 1-4 bulan.",
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      onAddToCart({
                        'name': name,
                        'price': parsedPrice,
                        'image': image,
                        'quantity': 1,
                      });
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.shopping_cart_outlined),
                    label: const Text("Masukkan ke Keranjang"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Checkout(
                          cartItems: [
                            {
                              'name': name,
                              'price': parsedPrice.toDouble(),
                            }
                          ],
                          onConfirm: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Pembayaran berhasil!")),
                            );
                          },
                        ),
                      ),
                    );
                  },

                    icon: const Icon(Icons.payment),
                    label: const Text("Beli Sekarang"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
