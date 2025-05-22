import 'package:flutter/material.dart';
import 'package:petcare1/Services/grooming.dart';
import 'package:petcare1/Services/boarding.dart';

void main() {
  runApp(const PetServices());
}

class PetServices extends StatelessWidget {
  const PetServices({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.green,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          primary: Colors.green,
        ),
      ),
      home: const PetServicesScreen(),
    );
  }
}

class PetServicesScreen extends StatelessWidget {
  const PetServicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.black),
          onPressed: () {},
        ),
        title: const Text(
          'Pet Services',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Enjoy new smart pet parenting experience',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Main services grid
                  GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    padding: const EdgeInsets.all(16),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const Grooming()),
                          );
                        },
                        child: const ServiceCard(
                          icon: Icons.pets,
                          title: 'Grooming',
                          iconText: '✂️',
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const Boarding()),
                          );
                        },
                        child: const ServiceCard(
                          icon: Icons.home,
                          title: 'Boarding',
                          iconText: '🏠',
                        ),
                      ),

                      const ServiceCard(
                        icon: Icons.airport_shuttle,
                        title: 'Transportation',
                        iconText: '🐾',
                      ),
                      const ServiceCard(
                        icon: Icons.sports,
                        title: 'Training',
                        iconText: '🦮',
                      ),
                    ],
                  ),
                  
                  // Other helpful links section
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            'Other Helpful Links',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: const [
                            HelpfulLinkIcon(icon: Icons.article, title: 'Blog'),
                            HelpfulLinkIcon(icon: Icons.person, title: 'My Profile'),
                            HelpfulLinkIcon(icon: Icons.help, title: 'App Help'),
                            HelpfulLinkIcon(icon: Icons.pets, title: 'Lost Gem'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Navigation Bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String iconText;

  const ServiceCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.iconText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAE6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                iconText,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class HelpfulLinkIcon extends StatelessWidget {
  final IconData icon;
  final String title;

  const HelpfulLinkIcon({
    Key? key,
    required this.icon,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.green.withOpacity(0.5), width: 2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.green, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

class BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;

  const BottomNavItem({
    Key? key,
    required this.icon,
    required this.label,
    this.isActive = false,
    this.activeColor = Colors.green,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? activeColor : Colors.grey,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? activeColor : Colors.grey,
          ),
        ),
      ],
    );
  }
}