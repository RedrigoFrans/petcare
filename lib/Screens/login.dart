import 'package:flutter/material.dart';
import 'register.dart';
import 'dashboard.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Remove the email and password controllers since we're not using them
  // final TextEditingController _emailController = TextEditingController();
  // final TextEditingController _passwordController = TextEditingController();

  void _login() {
    // Skip email and password validation
    // Just navigate directly to the Dashboard
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Dashboard()), // Replace with your dashboard screen
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login Successful!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo and Title
                      Image.asset(
                        'assets/images/logo.png', // Pastikan logo Anda berada di folder assets/images/
                        height: 170,
                      ),
                      const SizedBox(height: 40),

                      // Skip email and password fields
                      const SizedBox(height: 16),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _login, // Call the login function
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'LOGIN',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Register Text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Belum punya akun?',
                            style: TextStyle(color: Colors.black87),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Register()),
                              );
                            },
                            child: const Text(
                              'klik disini',
                              style: TextStyle(
                                color: Color(0xFF4CAF50),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
        ),
      ),
    );
  }
}






// import 'package:flutter/material.dart';
// import 'register.dart';
// import 'dashboard.dart';

// class Login extends StatefulWidget {
//   const Login({Key? key}) : super(key: key);

//   @override
//   _LoginState createState() => _LoginState();
// }

// class _LoginState extends State<Login> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   void _login() {
//     String email = _emailController.text;
//     String password = _passwordController.text;

//     // Check for the hardcoded credentials
//     if (email == 'frans@gmail.com' && password == '12345678') {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => Dashboard()), // Replace with your dashboard screen
//       );
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Login Successful!')),
//       );
//       // Here you can navigate to another screen if needed
//     } else {
//       // Show error message
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Invalid email or password')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       // Logo and Title
//                       Image.asset(
//                         'assets/images/logo.png', // Pastikan logo Anda berada di folder assets/images/
//                         height: 170,
//                       ),
//                       const SizedBox(height: 40),

//                       // Email Field
//                       TextField(
//                         controller: _emailController, // Set the controller
//                         decoration: InputDecoration(
//                           filled: true,
//                           fillColor: Colors.grey.shade300,
//                           hintText: 'Email Address',
//                           prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8.0),
//                             borderSide: BorderSide.none,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 16),

//                       // Password Field
//                       TextField(
//                         controller: _passwordController, // Set the controller
//                         obscureText: true,
//                         decoration: InputDecoration(
//                           filled: true,
//                           fillColor: Colors.grey.shade300,
//                           hintText: 'Password',
//                           prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8.0),
//                             borderSide: BorderSide.none,
//                           ),
//                         ),
//                       ),

//                       // Forgot Password
//                       Align(
//                         alignment: Alignment.centerRight,
//                         child: TextButton(
//                           onPressed: () {
//                             // Implementasi forgot password
//                           },
//                           child: const Text(
//                             'Forgot Password?',
//                             style: TextStyle(
//                               color: Color(0xFF4CAF50),
//                             ),
//                           ),
//                         ),
//                       ),

//                       // Login Button
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: _login, // Call the login function
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF4CAF50),
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           child: const Text(
//                             'LOGIN',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 20),

//                       // Register Text
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text(
//                             'Belum punya akun?',
//                             style: TextStyle(color: Colors.black87),
//                           ),
//                           TextButton(
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(builder: (context) => Register()),
//                               );
//                             },
//                             child: const Text(
//                               'klik disini',
//                               style: TextStyle(
//                                 color: Color(0xFF4CAF50),
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               // Footer
//               Container(
//                 width: double.infinity,
//                 color: const Color(0xFF4CAF50),
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 child: const Text(
//                   '© All Rights Reserved to Pixel Posse - 2022',
//                   style: TextStyle(color: Colors.white, fontSize: 12),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }