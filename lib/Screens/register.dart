import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();

  // Controller untuk input form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController(); // ✅ Tambah controller address
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false; // ✅ Tambah loading state

  InputDecoration buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[700]),
      floatingLabelStyle: TextStyle(color: Colors.grey[700]),
      filled: true,
      fillColor: Colors.grey.shade300,
      prefixIcon: Icon(icon, color: Colors.grey[700]),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> registerUser() async {
    // ✅ Ganti dengan URL Laravel API yang sebenarnya
    // Sesuaikan dengan IP/domain server Laravel Anda
    final url = Uri.parse('http://127.0.0.1:8000/api/register'); // atau http://localhost:8000/api/register
    
    setState(() {
      _isLoading = true;
    });

    try {
      print('Sending request to: $url'); // Debug log
      
      // ✅ Kirim data dalam format JSON dengan header yang benar
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': _nameController.text.trim(),
          'username': _usernameController.text.trim(), // Backend mungkin tidak memerlukan username
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(), // ✅ Tambah address yang diperlukan backend
          'password': _passwordController.text.trim(),
          'password_confirmation': _confirmPasswordController.text.trim(), // ✅ Tambah konfirmasi password
        }),
      );

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 201) { // ✅ Backend return 201 untuk created
        // Registrasi sukses
        final responseData = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message'] ?? 'Registrasi berhasil, silakan login'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        // Error dari backend
        final error = jsonDecode(response.body);
        if (mounted) {
          String errorMessage = 'Gagal registrasi';
          
          // Handle validation errors
          if (error['errors'] != null) {
            Map<String, dynamic> errors = error['errors'];
            List<String> errorMessages = [];
            errors.forEach((key, value) {
              if (value is List) {
                errorMessages.addAll(value.cast<String>());
              }
            });
            errorMessage = errorMessages.join('\n');
          } else if (error['message'] != null) {
            errorMessage = error['message'];
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error: $e'); // Debug log
      // Error koneksi atau lain-lain
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan koneksi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose(); // ✅ Dispose address controller
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Logo dan Judul
                    // ✅ Gunakan placeholder jika tidak ada logo
                        SizedBox(
                          height: 170,
                          width: 170,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(85),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                    const SizedBox(height: 30),

                    // Nama Lengkap
                    TextFormField(
                      controller: _nameController,
                      decoration: buildInputDecoration('Nama Lengkap', Icons.person),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama lengkap wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Username - ✅ Opsional karena backend tidak memerlukan
                    TextFormField(
                      controller: _usernameController,
                      decoration: buildInputDecoration('Username', Icons.account_circle),
                      validator: (value) {
                        // Username opsional
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: buildInputDecoration('Email Address', Icons.email),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email wajib diisi';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Nomor HP
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: buildInputDecoration('Nomor HP', Icons.phone),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nomor HP wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ✅ Tambah field Address yang diperlukan backend
                    TextFormField(
                      controller: _addressController,
                      decoration: buildInputDecoration('Alamat', Icons.location_on),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Alamat wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: buildInputDecoration('Password', Icons.lock).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey[700],
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password wajib diisi';
                        }
                        if (value.length < 6) {
                          return 'Password minimal 6 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: buildInputDecoration('Confirm Password', Icons.lock_outline).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey[700],
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Password tidak cocok';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Tombol Register
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _isLoading ? null : () { // ✅ Disable saat loading
                          if (_formKey.currentState!.validate()) {
                            registerUser();
                          }
                        },
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white) // ✅ Show loading
                          : const Text(
                              'REGISTER',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),

          // Footer
          Container(
            width: double.infinity,
            color: const Color(0xFF4CAF50),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: const Text(
              '© All Rights Reserved to Pixel Posse - 2022',
              style: TextStyle(color: Colors.white, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}