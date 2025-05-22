import 'dart:async';

import 'package:flutter/material.dart';
import 'petservices.dart';
import 'profile.dart';
import 'shop.dart';
import 'package:petcare1/Services/grooming.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(
        onAskFidoTap: () => setState(() => _currentIndex = 3),
      ),
      const Shop(),
      const PetServices(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Shop"),
          BottomNavigationBarItem(icon: Icon(Icons.design_services), label: "Services"),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: "Ask Fido"),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final VoidCallback onAskFidoTap;

  const HomeScreen({
    super.key,
    required this.onAskFidoTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _pageController;
  late Timer _timer;
  int _currentPage = 0;

  final List<String> _sliderImages = [
    'assets/images/slider1.jpg',
    'assets/images/slider2.jpg',
    'assets/images/slider3.jpg',
    'assets/images/slider4.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentPage < _sliderImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade200, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildSliderBanner(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: widget.onAskFidoTap,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                child: const Text("Go to Ask Fido", style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle("Shop For"),
              _buildShopCategories(),
              const SizedBox(height: 20),
              _buildSectionTitle("Pet Services"),
              _buildServiceCategories(context),
              const SizedBox(height: 20),
              _buildMyPetsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Enjoy your day,\nUser  User",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            const SizedBox(width: 12),
            Stack(
              children: [
                const Icon(Icons.notifications_none, size: 28, color: Colors.green),
                Positioned(
                  right: 0,
                  child: CircleAvatar(
                    radius: 6,
                    backgroundColor: Colors.orange,
                    child: const Text('1', style: TextStyle(fontSize: 8, color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));
              },
              child: const CircleAvatar(child: Text("UU")),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSliderBanner() {
    return SizedBox(
      height: 300,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _sliderImages.length,
        itemBuilder: (context, index) {
          return _sliderImage(_sliderImages[index]);
        },
        onPageChanged: (index) {
          _currentPage = index;
        },
      ),
    );
  }

  Widget _sliderImage(String path) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(path, fit: BoxFit.cover),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildShopCategories() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            ShopCategory(icon: Icons.pets, label: "All"),
            ShopCategory(icon: Icons.pets, label: "Dog"),
            ShopCategory(icon: Icons.pets, label: "Cat"),
            ShopCategory(icon: Icons.pets, label: "Bird"),
            ShopCategory(icon: Icons.pets, label: "Horse"),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCategories(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Grooming()),
                );
              },
              child: const ServiceCategory(icon: Icons.content_cut, label: "Grooming"),
            ),
            const ServiceCategory(icon: Icons.home, label: "Boarding"),
            const ServiceCategory(icon: Icons.airplanemode_active, label: "Transportation"),
            const ServiceCategory(icon: Icons.school, label: "Training"),
          ],
        ),
      ),
    );
  }

  Widget _buildMyPetsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text("My Pets", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("See All", style: TextStyle(color: Colors.green)),
          ],
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Oops! Looks like no pets are added yet", style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text("Create a pet profile now"),
                    ],
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ShopCategory extends StatelessWidget {
  final IconData icon;
  final String label;

  const ShopCategory({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Icon(icon, color: Colors.green),
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}

class ServiceCategory extends StatelessWidget {
  final IconData icon;
  final String label;

  const ServiceCategory({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Icon(icon, color: Colors.green),
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}
