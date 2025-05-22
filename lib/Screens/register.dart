import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
                    Column(
                      children: [
                        Image.asset(
                          'assets/images/logo.png', // Ganti sesuai dengan path logo kamu
                          height: 170,
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Nama Lengkap
                    TextFormField(
                      decoration: buildInputDecoration('Nama Lengkap', Icons.person),
                    ),
                    const SizedBox(height: 16),

                    // Username
                    TextFormField(
                      decoration: buildInputDecoration('Username', Icons.account_circle),
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: buildInputDecoration('Email Address', Icons.email),
                    ),
                    const SizedBox(height: 16),

                    // Nomor HP
                    TextFormField(
                      keyboardType: TextInputType.phone,
                      decoration: buildInputDecoration('Nomor HP', Icons.phone),
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
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
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password
                    TextFormField(
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
                        onPressed: () {
                          Navigator.pop(context); // Kembali ke halaman login
                        },
                        child: const Text(
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
