import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final PageController _pageController = PageController(
    viewportFraction: 0.75, // Reduced from 0.9 to bring items closer together
  );
  double _currentPage = 0.0;

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
      _currentPage = _pageController.page ?? 0;
    });
  }

  int _getActualIndex(int index) {
    return index % 6;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const Positioned(
            top: 10,
            left: 20,
            child: Text(
              'Bonjour',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 400,
              child: PageView.builder(
                controller: _pageController,
                itemBuilder: (context, index) {
                  final actualIndex = _getActualIndex(index);
                  
                  double scale = 1.0;
                  final difference = index - _currentPage;
                  if (difference.abs() <= 1) {
                    scale = 1 - (difference.abs() * 0.1);
                  } else {
                    scale = 0.9;
                  }

                  return TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 200), // Reduced from 350ms to 200ms
                    tween: Tween(begin: scale, end: scale),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5), // Reduced from 10 to 5
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: Text(
                                'Contenu de l\'accueil ${actualIndex + 1}',
                                style: const TextStyle(color: Colors.white),
                              ),
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