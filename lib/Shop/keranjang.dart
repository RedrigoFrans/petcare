// keranjang.dart
import 'package:flutter/material.dart';
import 'checkout.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:petcare1/Shop/cart_provider.dart'; // Import CartProvider
import 'package:cached_network_image/cached_network_image.dart'; // Import CachedNetworkImage

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color lightGreen = Color(0xFF81C784);
  static const Color darkGreen = Color(0xFF388E3C);

  @override
  void initState() {
    super.initState();
    // Inisialisasi tidak diperlukan lagi karena data akan diambil dari Provider
  }

  void removeItem(int index) {
    // Dapatkan instance CartProvider
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.removeItem(index);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text("Item berhasil dihapus"),
          ],
        ),
        backgroundColor: primaryGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void increaseQuantity(int index) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final currentItem = cartProvider.cartItems[index];
    final int currentQty = (currentItem['quantity'] as num?)?.toInt() ?? 1;
    cartProvider.updateQuantity(currentItem['id'], currentQty + 1);
  }

  void decreaseQuantity(int index) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final currentItem = cartProvider.cartItems[index];
    final int currentQty = (currentItem['quantity'] as num?)?.toInt() ?? 1;

    if (currentQty > 1) {
      cartProvider.updateQuantity(currentItem['id'], currentQty - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Akses item keranjang dari CartProvider
    final items = Provider.of<CartProvider>(context).cartItems;

    double totalPrice = items.fold(0.0, (sum, item) {
      double price = (item['price'] as num?)?.toDouble() ?? 0.0;
      int qty = (item['quantity'] as num?)?.toInt() ?? 1;
      return sum + price * qty;
    });

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shopping_cart, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text("Keranjang Saya", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryGreen, lightGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Keranjang kamu masih kosong",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Ayo mulai belanja produk pet care terbaik!",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryGreen.withOpacity(0.1), lightGreen.withOpacity(0.05)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: primaryGreen.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_bag, color: primaryGreen),
                      const SizedBox(width: 12),
                      Text(
                        "${items.length} Item${items.length > 1 ? 's' : ''} dalam keranjang",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: darkGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      int qty = (item['quantity'] as num?)?.toInt() ?? 1;
                      double price = (item['price'] as num?)?.toDouble() ?? 0.0;
                      String priceDisplay = item['price_display'] as String? ?? 'Rp. 0';
                      double subtotal = price * qty;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
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
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage( // Menggunakan CachedNetworkImage
                                    imageUrl: item['image']!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[100],
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.orange.shade300,
                                          ),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) {
                                      return Image.asset('assets/images/placeholder.jpg', fit: BoxFit.cover);
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: primaryGreen.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        priceDisplay,
                                        style: TextStyle(
                                          color: darkGreen,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[50],
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.grey[300]!),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              InkWell(
                                                onTap: () => decreaseQuantity(index),
                                                borderRadius: BorderRadius.circular(6),
                                                child: Container(
                                                  padding: const EdgeInsets.all(8),
                                                  child: Icon(
                                                    Icons.remove,
                                                    size: 18,
                                                    color: qty > 1 ? primaryGreen : Colors.grey[400],
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                child: Text(
                                                  '$qty',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () => increaseQuantity(index),
                                                borderRadius: BorderRadius.circular(6),
                                                child: Container(
                                                  padding: const EdgeInsets.all(8),
                                                  child: const Icon(
                                                    Icons.add,
                                                    size: 18,
                                                    color: primaryGreen,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text("Subtotal", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                            Text(
                                              "Rp ${subtotal.toStringAsFixed(0)}",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: darkGreen,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () => removeItem(index),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.delete_outline, color: Colors.red[400], size: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 3,
                        blurRadius: 12,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryGreen.withOpacity(0.1), lightGreen.withOpacity(0.05)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: primaryGreen.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Total Pembayaran", style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                                const SizedBox(height: 4),
                                Text('Rp ${totalPrice.toStringAsFixed(0)}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkGreen)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: primaryGreen.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.account_balance_wallet, color: primaryGreen, size: 28),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
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
                                            'id': item['id'],
                                            'name': item['name'] ?? '',
                                            'price': (item['price'] as num?)?.toDouble() ?? 0.0,
                                            'quantity': (item['quantity'] as num?)?.toInt() ?? 1,
                                          };
                                        }).toList(),
                                        onConfirm: () {
                                          // Clear cart setelah checkout berhasil
                                          Provider.of<CartProvider>(context, listen: false).clearCart();
                                          
                                          Navigator.popUntil(context, (route) => route.isFirst);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: [
                                                  Icon(Icons.check_circle, color: Colors.white),
                                                  SizedBox(width: 8),
                                                  Text("Order placed successfully!"),
                                                ],
                                              ),
                                              backgroundColor: primaryGreen,
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[300],
                            disabledForegroundColor: Colors.grey[500],
                            elevation: 4,
                            shadowColor: primaryGreen.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_cart_checkout, size: 20),
                              SizedBox(width: 8),
                              Text("Checkout Sekarang", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
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
