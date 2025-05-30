import 'package:flutter/material.dart';
import 'package:petcare1/Api/api_service.dart';
import 'item_detail.dart';
import 'package:petcare1/Shop/keranjang.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Shop extends StatefulWidget {
  const Shop({super.key});

  @override
  State<Shop> createState() => _ShopState();
}

class _ShopState extends State<Shop> {
  final List<Map<String, dynamic>> cartItems = [];
  List<Map<String, dynamic>> products = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();

  final ApiService _apiService = ApiService();

  // PERBAIKAN: Ganti localhost dengan IP address yang benar
  static const String baseUrl = 'http://127.0.0.1:8000'; // Sesuaikan dengan IP server Anda
  static const bool debugMode = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final fetchedProducts = await _apiService.getProducts();
      if (!mounted) return;

      if (debugMode) {
        print('Raw API Response: $fetchedProducts');
        print('Fetched products count: ${fetchedProducts.length}');
      }

      setState(() {
        products = fetchedProducts.map((p) {
          double priceNumeric;
          if (p['price'] is String) {
            priceNumeric = double.tryParse(p['price'] as String) ?? 0.0;
          } else if (p['price'] is num) {
            priceNumeric = (p['price'] as num).toDouble();
          } else {
            priceNumeric = 0.0;
          }

          final imageUrl = _parseImageUrl(p['image_url']);
          
          if (debugMode) {
            print('Product: ${p['name']}');
            print('Original image: ${p['image_url']}');
            print('Parsed image URL: $imageUrl');
            print('---');
          }

          return {
            'id': p['id'] as int,
            'name': p['name'] as String,
            'price_numeric': priceNumeric,
            'price_display': 'Rp. ${priceNumeric.toStringAsFixed(0)}',
            'image': imageUrl,
            'description': p['description'] as String? ?? 'No description available.'
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load products: ${e.toString()}";
      });
      
      if (debugMode) {
        print('Error fetching products: $e');
      }
    }
  }

// Method _parseImageUrl yang diperbaiki
String _parseImageUrl(dynamic imageUrl) {
  if (debugMode) {
    print('Parsing image URL: $imageUrl (Type: ${imageUrl.runtimeType})');
  }
  
  // Jika null atau empty, return placeholder
  if (imageUrl == null || imageUrl.toString().trim().isEmpty) {
    if (debugMode) print('Image URL is null/empty, using placeholder');
    return 'assets/images/placeholder.jpg';
  }
  
  final url = imageUrl.toString().trim();
  
  // PERBAIKAN: Extract filename untuk menggunakan API endpoint
  String filename = '';
  
  if (url.contains('/storage/')) {
    // Extract filename dari URL storage
    final parts = url.split('/storage/');
    if (parts.length > 1) {
      filename = parts.last;
      // Remove 'products/' prefix if exists
      if (filename.startsWith('products/')) {
        filename = filename.substring(9);
      }
    }
  } else if (url.contains('/')) {
    // Extract filename dari path
    filename = url.split('/').last;
  } else {
    filename = url;
  }
  
  if (filename.isNotEmpty) {
    // PERBAIKAN: Gunakan API endpoint untuk serve image
    final apiImageUrl = '$baseUrl/api/images/$filename';
    if (debugMode) {
      print('Using API image URL: $apiImageUrl');
    }
    return apiImageUrl;
  }
  
  // Fallback ke placeholder jika tidak bisa extract filename
  if (debugMode) print('Could not extract filename, using placeholder');
  return 'assets/images/placeholder.jpg';
}

// PERBAIKAN: Image widget dengan error handling yang lebih baik
Widget _buildImageWidget(String imageUrl, {double? height}) {
  if (debugMode) {
    print('Building image widget for: $imageUrl');
  }

  if (imageUrl.startsWith('assets/')) {
    return Image.asset(
      imageUrl,
      fit: BoxFit.cover,
      height: height,
      errorBuilder: (context, error, stackTrace) {
        if (debugMode) print('Error loading asset: $imageUrl - $error');
        return _buildErrorWidget();
      },
    );
  } else {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      height: height,
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
        if (debugMode) {
          print('Error loading network image: $url');
          print('Error details: $error');
          print('Error type: ${error.runtimeType}');
        }
        return _buildErrorWidget();
      },
      httpHeaders: const {
        'User-Agent': 'Flutter App',
        'Accept': 'image/webp,image/apng,image/jpeg,image/png,image/*,*/*;q=0.8',
        'Cache-Control': 'no-cache',
      },
      fadeInDuration: const Duration(milliseconds: 300),
      memCacheWidth: 400,
      memCacheHeight: 400,
      maxWidthDiskCache: 600,
      maxHeightDiskCache: 600,
    );
  }
}

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            color: Colors.grey[400],
            size: 32,
          ),
          const SizedBox(height: 4),
          Text(
            'No Image',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void addToCart(Map<String, dynamic> product) {
    setState(() {
      final existingIndex = cartItems.indexWhere((item) => item['id'] == product['id']);
      if (existingIndex != -1) {
        cartItems[existingIndex]['quantity'] += product['quantity'] ?? 1;
      } else {
        cartItems.add({
          'id': product['id'],
          'name': product['name'],
          'price': product['price_numeric'] ?? product['price'],
          'price_display': product['price_display'],
          'image': product['image'],
          'quantity': product['quantity'] ?? 1,
        });
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('${product['name']} added to cart'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void openProductDetail(Map<String, dynamic> product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItemDetail(
          productId: product['id'],
          name: product['name'],
          price: product['price_display'],
          numericPrice: product['price_numeric'],
          image: product['image'],
          description: product['description'],
          onAddToCart: addToCart,
        ),
      ),
    );
  }

  List<Map<String, dynamic>> get filteredProducts {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return products;
    
    return products.where((product) {
      return product['name'].toString().toLowerCase().contains(query) ||
             product['description'].toString().toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.orange),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Cart(cartItems: List.from(cartItems)),
                    ),
                  );
                },
              ),
              if (cartItems.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cartItems.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Gagal memuat produk',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _fetchProducts,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchProducts,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Search Bar
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Cari produk...',
                              prefixIcon: const Icon(Icons.search, color: Colors.grey),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {});
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Pet Products",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              "${filteredProducts.length} produk",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Products Grid
                        Expanded(
                          child: filteredProducts.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.pets,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _searchController.text.isNotEmpty
                                            ? "Produk tidak ditemukan"
                                            : "Belum ada produk",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : GridView.builder(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.75,
                                  ),
                                  itemCount: filteredProducts.length,
                                  itemBuilder: (context, index) {
                                    final product = filteredProducts[index];
                                    return GestureDetector(
                                      onTap: () => openProductDetail(product),
                                      child: Card(
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Product Image
                                              Expanded(
                                                child: Container(
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(8),
                                                    color: Colors.grey[100],
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(8),
                                                    child: _buildImageWidget(product['image']),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              
                                              // Product Name
                                              Text(
                                                product['name'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              
                                              // Product Price
                                              Text(
                                                product['price_display'],
                                                style: TextStyle(
                                                  color: Colors.green[700],
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
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
                      ],
                    ),
                  ),
                ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}