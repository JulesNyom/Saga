import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final PageController _pageController = PageController(
    viewportFraction: 0.85,
  );
  final ScrollController _scrollController = ScrollController();
  double _currentPage = 0.0;
  double _scrollOffset = 0.0;

  final List<Map<String, dynamic>> cardContents = [
    {
      'title': 'Méditation Guidée',
      'description': 'Une séance relaxante pour débutants',
      'gradient': [const Color(0xFF4158D0), const Color(0xFFC850C0)],
      'icon': Icons.self_improvement,
    },
    {
      'title': 'Pleine Conscience',
      'description': 'Pratiques quotidiennes de mindfulness',
      'gradient': [const Color(0xFF43E97B), const Color(0xFF38F9D7)],
      'icon': Icons.psychology,
    },
    {
      'title': 'Sommeil Profond',
      'description': 'Aide naturelle pour mieux dormir',
      'gradient': [const Color(0xFF0250C5), const Color(0xFF3F51B5)],
      'icon': Icons.nightlight_round,
    },
    {
      'title': 'Réduction du Stress',
      'description': 'Techniques de respiration apaisante',
      'gradient': [const Color(0xFFFF0844), const Color(0xFFFFB199)],
      'icon': Icons.spa,
    },
    {
      'title': 'Concentration',
      'description': 'Améliorer votre focus au quotidien',
      'gradient': [const Color(0xFF396AFC), const Color(0xFF2948FF)],
      'icon': Icons.leak_add,
    },
    {
      'title': 'Relaxation',
      'description': 'Détente musculaire progressive',
      'gradient': [const Color(0xFFFF416C), const Color(0xFFFF4B2B)],
      'icon': Icons.waves,
    },
  ];

  final List<Map<String, dynamic>> books = [
    {
      'title': 'Le Pouvoir du Moment Présent',
      'color': const Color(0xFF1E3D59),
    },
    {
      'title': 'L\'Art de la Méditation',
      'color': const Color(0xFF17B978),
    },
    {
      'title': 'Respire',
      'color': const Color(0xFFFF6B6B),
    },
    {
      'title': 'La Magie du Matin',
      'color': const Color(0xFF4831D4),
    },
    {
      'title': 'Calme et Attentif',
      'color': const Color(0xFFCCF381),
    },
    {
      'title': 'Le Miracle du Mindfulness',
      'color': const Color(0xFF317773),
    },
    {
      'title': 'Méditer Jour Après Jour',
      'color': const Color(0xFFE2D810),
    },
    {
      'title': 'La Voie des Émotions',
      'color': const Color(0xFFD92027),
    },
    {
      'title': 'Le Livre du Hygge',
      'color': const Color(0xFF8E44AD),
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onScroll);
    _scrollController.addListener(_onMainScroll);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onScroll);
    _scrollController.removeListener(_onMainScroll);
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onMainScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
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
    HapticFeedback.mediumImpact();
    // TODO: Implement navigation to Listen page
    print('Navigating to Listen page');
  }

  double get _appBarOpacity {
    const showAt = 20.0;
    const fullyVisibleAt = 100.0;
    
    if (_scrollOffset <= showAt) return 0.0;
    if (_scrollOffset >= fullyVisibleAt) return 1.0;
    
    return (_scrollOffset - showAt) / (fullyVisibleAt - showAt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          child: AppBar(
            backgroundColor: Colors.black.withOpacity(_appBarOpacity),
            elevation: _appBarOpacity * 4,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(_appBarOpacity * 0.8),
                    Colors.black.withOpacity(0.0),
                  ],
                ),
              ),
            ),
            title: Opacity(
              opacity: _appBarOpacity,
              child: const Text(
                'Accueil',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            actions: [
              Opacity(
                opacity: _appBarOpacity,
                child: IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {},
                ),
              ),
              Opacity(
                opacity: _appBarOpacity,
                child: IconButton(
                  icon: const Icon(Icons.account_circle_outlined, color: Colors.white),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 100),
            const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bonjour,',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Que souhaitez-vous écouter ?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 420,
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
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
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    tween: Tween(begin: scale, end: scale),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value,
                        child: _buildCard(actualIndex),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Plus de livres',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Voir tout',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemBuilder: (context, index) {
                final actualIndex = index % books.length;
                return _buildBookCard(actualIndex);
              },
              itemCount: 6,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: cardContents[index]['gradient'],
          ),
          boxShadow: [
            BoxShadow(
              color: cardContents[index]['gradient'][0].withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () => _navigateToListenPage(context),
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    cardContents[index]['icon'],
                    size: 45,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cardContents[index]['title'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        cardContents[index]['description'],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Écouter',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookCard(int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToListenPage(context),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: books[index]['color'],
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: books[index]['color'].withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  Icons.book,
                  size: 100,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      books[index]['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}