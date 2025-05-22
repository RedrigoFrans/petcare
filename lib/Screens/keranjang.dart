import 'package:flutter/material.dart';
import 'checkout.dart';

class Cart extends StatefulWidget {
  final List<Map<String, String>> cartItems;

  const Cart({super.key, required this.cartItems});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  late List<Map<String, dynamic>> items;

  @override
  void initState() {
    super.initState();
    // Copy list dan set quantity default = 1 kalau belum ada
    items = widget.cartItems.map((item) {
      return {
        ...item,
        'quantity': item['quantity'] ?? 1,
      };
    }).toList();
  }

  void removeItem(int index) {
    setState(() {
      items.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Item berhasil dihapus"),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  void increaseQuantity(int index) {
    setState(() {
      items[index]['quantity'] = (items[index]['quantity'] ?? 1) + 1;
    });
  }

  void decreaseQuantity(int index) {
    setState(() {
      int currentQty = items[index]['quantity'] ?? 1;
      if (currentQty > 1) {
        items[index]['quantity'] = currentQty - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Hitung total harga dengan quantity
    int totalPrice = items.fold(0, (sum, item) {
      String rawPrice = (item['price'] ?? '').replaceAll(RegExp(r'[^0-9]'), '');
      int price = int.tryParse(rawPrice) ?? 0;
      int qty = item['quantity'] ?? 1;
      return sum + price * qty;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Keranjang Saya"),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: items.isEmpty
          ? const Center(child: Text("Keranjang kamu masih kosong"))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                int qty = item['quantity'] ?? 1;
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: Image.asset(item['image']!, width: 50, height: 50, fit: BoxFit.cover),
                    title: Text(item['name'] ?? ''),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['price'] ?? '', style: const TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF4CAF50)),
                              onPressed: () => decreaseQuantity(index),
                            ),
                            Text('$qty', style: const TextStyle(fontSize: 16)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: Color(0xFF4CAF50)),
                              onPressed: () => increaseQuantity(index),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => removeItem(index),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Total: Rp $totalPrice',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50)),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: items.isEmpty
                        ? null
                        : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Checkout(
                            cartItems: items.map((item) {
                              return {
                                'name': item['name'] ?? '',
                                'price': double.tryParse(
                                    item['price']
                                        ?.replaceAll(RegExp(r'[^0-9]'), '') ??
                                        '0') ??
                                    0.0,
                                'quantity': item['quantity'] ?? 1,
                              };
                            }).toList(),
                            onConfirm: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Pembayaran berhasil!"),
                                  backgroundColor: Color(0xFF4CAF50),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey,
                    ),
                    child: const Text("Checkout Sekarang"),
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
