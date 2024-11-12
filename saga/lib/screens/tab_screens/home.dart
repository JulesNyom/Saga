import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final PageController _pageController = PageController(
    viewportFraction: 0.75,
  );
  double _currentPage = 0.0;

  // French content for main cards
  final List<Map<String, String>> cardContents = [
    {
      'title': 'Méditation Guidée',
      'description': 'Une séance relaxante pour débutants',
    },
    {
      'title': 'Pleine Conscience',
      'description': 'Pratiques quotidiennes de mindfulness',
    },
    {
      'title': 'Sommeil Profond',
      'description': 'Aide naturelle pour mieux dormir',
    },
    {
      'title': 'Réduction du Stress',
      'description': 'Techniques de respiration apaisante',
    },
    {
      'title': 'Concentration',
      'description': 'Améliorer votre focus au quotidien',
    },
    {
      'title': 'Relaxation',
      'description': 'Détente musculaire progressive',
    },
  ];

  // List of book titles for the grid
  final List<String> bookTitles = [
    'Le Pouvoir du Moment Présent',
    'L\'Art de la Méditation',
    'Respire',
    'La Magie du Matin',
    'Calme et Attentif',
    'Le Miracle du Mindfulness',
    'Méditer Jour Après Jour',
    'La Voie des Émotions',
    'Le Livre du Hygge',
  ];

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

  void _navigateToListenPage(BuildContext context) {
    // TODO: Implement navigation to Listen page
    print('Navigating to Listen page');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                'Bonjour',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            SizedBox(
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
                    duration: const Duration(milliseconds: 200),
                    tween: Tween(begin: scale, end: scale),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTapDown: (_) {
                                // Add haptic feedback for touch
                                HapticFeedback.lightImpact();
                              },
                              onTap: () => _navigateToListenPage(context),
                              borderRadius: BorderRadius.circular(30),
                              child: StatefulBuilder(
                                builder: (context, setState) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Stack(
                                      children: [
                                        // Ripple effect container
                                        Positioned.fill(
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(30),
                                              onTapDown: (_) {
                                                HapticFeedback.lightImpact();
                                              },
                                              onTap: () => _navigateToListenPage(context),
                                            ),
                                          ),
                                        ),
                                        // Content
                                        Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                cardContents[actualIndex]['title']!,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                cardContents[actualIndex]['description']!,
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 16,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 20),
                                              Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  onTapDown: (_) {
                                                    HapticFeedback.lightImpact();
                                                  },
                                                  onTap: () => _navigateToListenPage(context),
                                                  borderRadius: BorderRadius.circular(25),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 30,
                                                      vertical: 12,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(25),
                                                    ),
                                                    child: const Text(
                                                      'Écouter',
                                                      style: TextStyle(
                                                        color: Colors.blue,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
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
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 30, 20, 15),
              child: Text(
                'Plus de livres',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final actualIndex = index % bookTitles.length;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTapDown: (_) {
                      HapticFeedback.lightImpact();
                    },
                    onTap: () => _navigateToListenPage(context),
                    borderRadius: BorderRadius.circular(15),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  bookTitles[actualIndex],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
              itemCount: 105,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}