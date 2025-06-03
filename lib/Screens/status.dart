import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;
  String errorMessage = '';

  // URL API endpoint - sesuaikan dengan URL backend Anda
  final String apiUrl = 'http://127.0.0.1:8000/api/orders';

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // Tambahkan authorization header jika diperlukan
          // 'Authorization': 'Bearer $token',
        },
      );

      print('Debug - Response status: ${response.statusCode}');
      print('Debug - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Debug - Decoded data: $data');
        
        List<Map<String, dynamic>> ordersList = [];
        
        // Cek struktur response
        if (data is Map && data.containsKey('orders')) {
          ordersList = List<Map<String, dynamic>>.from(data['orders']);
        } else if (data is Map && data.containsKey('success') && data['success'] == true) {
          ordersList = List<Map<String, dynamic>>.from(data['orders'] ?? []);
        } else if (data is List) {
          ordersList = List<Map<String, dynamic>>.from(data);
        } else {
          print('Debug - Unexpected data structure: ${data.runtimeType}');
        }
        
        print('Debug - Orders list: $ordersList');
        
        setState(() {
          orders = ordersList;
          isLoading = false;
        });
      } else {
        print('Debug - HTTP Error: ${response.statusCode} - ${response.body}');
        setState(() {
          errorMessage = 'Gagal memuat data pesanan (${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Debug - Exception: $e');
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
        isLoading = false;
      });
    }
  }

  String getStatusText(String status) {
    String cleanStatus = status.trim().toLowerCase();
    
    switch (cleanStatus) {
      case 'pending':
        return 'Pesanan sedang pending';
      case 'paid':
        return 'Pesanan sudah dibayar';
      case 'processing':
        return 'Pesanan sedang diproses';
      case 'shipped':
        return 'Pesanan sedang dikirim';
      case 'completed':
        return 'Pesanan sudah selesai';
      case 'canceled':
      case 'cancelled':
        return 'Pesanan dibatalkan';
      default:
        return 'Status tidak diketahui ($cleanStatus)';
    }
  }

  Color getStatusColor(String status) {
    String cleanStatus = status.trim().toLowerCase();
    switch (cleanStatus) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.blue;
      case 'processing':
        return Colors.purple;
      case 'shipped':
        return Colors.indigo;
      case 'completed':
        return Colors.green;
      case 'canceled':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData getStatusIcon(String status) {
    String cleanStatus = status.trim().toLowerCase();
    switch (cleanStatus) {
      case 'pending':
        return Icons.schedule;
      case 'paid':
        return Icons.payment;
      case 'processing':
        return Icons.build;
      case 'shipped':
        return Icons.local_shipping;
      case 'completed':
        return Icons.check_circle;
      case 'canceled':
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Pesanan'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchOrders,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchOrders,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : errorMessage.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          errorMessage,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: fetchOrders,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  )
                : orders.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Belum ada pesanan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          final status = order['status'] ?? 'unknown';
                          
                          // Ambil nama customer dari data yang sudah ter-join
                          final customerName = order['customer_name'] ?? 'Unknown Customer';
                          final customerEmail = order['customer_email'] ?? '';
                          final customerPhone = order['customer_phone'] ?? order['phone'] ?? '';
                          
                          print('Debug - Order $index: $order');
                          print('Debug - Customer name: $customerName');
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header dengan ID pesanan dan tanggal
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Pesanan #${order['id']}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        order['created_at'] != null
                                            ? _formatDate(order['created_at'])
                                            : '',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Status dengan icon dan warna
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: getStatusColor(status).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: getStatusColor(status).withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          getStatusIcon(status),
                                          size: 16,
                                          color: getStatusColor(status),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          getStatusText(status),
                                          style: TextStyle(
                                            color: getStatusColor(status),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Informasi customer
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey[200]!),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.person,
                                              size: 16,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Customer',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          customerName,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (customerEmail.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            customerEmail,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                        if (customerPhone.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            customerPhone,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Informasi pesanan
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Total: Rp ${_formatCurrency(order['total_amount'])}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (order['payment_proof_path'] != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green[50],
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.green[200]!),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.receipt,
                                                color: Colors.green[600],
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Bukti Bayar',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.green[600],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  
                                  // Alamat
                                  if (order['address'] != null) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            order['address'],
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '0';
    final number = double.tryParse(amount.toString()) ?? 0;
    return number.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}