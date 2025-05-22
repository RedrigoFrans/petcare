import 'package:flutter/material.dart';
import 'package:petcare1/ShopItem/item1.dart';
import 'package:petcare1/ShopItem/item2.dart';
import 'package:petcare1/ShopItem/item3.dart';
import 'package:petcare1/ShopItem/item4.dart';
import 'keranjang.dart';

class Shop extends StatefulWidget {
  const Shop({super.key});

  @override
  State<Shop> createState() => _ShopState();
}

class _ShopState extends State<Shop> {
  final List<Map<String, String>> cartItems = [];

  final List<Map<String, String>> products = [
    {
      'name': 'Whiskas Kering Rasa Tuna',
      'price': 'Rp. 35.000,00',
      'image': 'assets/images/whiskas_kering.jpg',
    },
    {
      'name': 'Kalung untuk Kucing',
      'price': 'Rp. 10.000,00',
      'image': 'assets/images/kalung.jpg',
    },
    {
      'name': 'Royal Canin Kaleng Hairball Care',
      'price': 'Rp. 320.000,00',
      'image': 'assets/images/royal_canin.jpg',
    },
    {
      'name': 'Royal Canin First Age',
      'price': 'Rp. 80.000,00',
      'image': 'assets/images/royal_canin_first_age.jpg',
    },
  ];

  void addToCart(Map<String, String> product) {
    setState(() {
      cartItems.add(product);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product['name']} ditambahkan ke keranjang')),
    );
  }

  void openProductDetail(int index) {
    final product = products[index];
    Widget page;

    switch (index) {
      case 0:
        page = Item1(
          name: product['name']!,
          price: product['price']!,
          image: product['image']!,
          onAddToCart: (Map<String, dynamic> p) => addToCart(Map<String, String>.from({
            'name': p['name'] as String,
            'price': p['price'].toString(),
            'image': p['image'] as String,
          })),
        );
        break;
      case 1:
        page = Item2(
          name: product['name']!,
          price: product['price']!,
          image: product['image']!,
          onAddToCart: (Map<String, dynamic> p) => addToCart(Map<String, String>.from({
            'name': p['name'] as String,
            'price': p['price'].toString(),
            'image': p['image'] as String,
          })),
        );
        break;
      case 2:
        page = Item3(
          name: product['name']!,
          price: product['price']!,
          image: product['image']!,
          onAddToCart: (Map<String, dynamic> p) => addToCart(Map<String, String>.from({
            'name': p['name'] as String,
            'price': p['price'].toString(),
            'image': p['image'] as String,
          })),
        );
        break;
      case 3:
        page = Item4(
          name: product['name']!,
          price: product['price']!,
          image: product['image']!,
          onAddToCart: (Map<String, dynamic> p) => addToCart(Map<String, String>.from({
            'name': p['name'] as String,
            'price': p['price'].toString(),
            'image': p['image'] as String,
          })),
        );
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.orange),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Cart(cartItems: cartItems),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      filled: true,
                      fillColor: Colors.grey[200],
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text("Pet Produk", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ),

            // Grid of products
            Expanded(
              child: GridView.builder(
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return GestureDetector(
                    onTap: () => openProductDetail(index),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  product['image']!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product['name']!,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product['price']!,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}