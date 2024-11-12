import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final PageController _pageController = PageController(
    viewportFraction: 0.8, // This will show parts of adjacent boxes
  );

  int _currentPage = 0;
  final double _scaleFactor = 0.8;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onScroll);
    _pageController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _currentPage = _pageController.page!.round();
    });
  }

  // Helper method to get the actual index for infinite scroll
  int _getActualIndex(int index) {
    return index % 6; // 6 is your total item count
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const Positioned(
            top: 40,
            left: 20,
            child: Text(
              'Bonjour',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          // PageView
          Center(
            child: SizedBox(
              height: 400,
              child: PageView.builder(
                controller: _pageController,
                itemBuilder: (context, index) {
                  // Get the actual index for the content
                  final actualIndex = _getActualIndex(index);
                  
                  // Calculate scale factor based on position
                  double scale = _getActualIndex(_currentPage) == actualIndex 
                      ? 1.0 
                      : _scaleFactor;

                  return TweenAnimationBuilder(
                    tween: Tween<double>(begin: scale, end: scale),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 350,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              'Contenu de l\'accueil ${actualIndex + 1}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}