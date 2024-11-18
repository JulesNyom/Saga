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

  final List<Map<String, dynamic>> featuredBooks = [
    {
      'title': 'Les Misérables',
      'author': 'Victor Hugo',
      'description':
          'Le chef-d\'œuvre de Victor Hugo, une histoire de rédemption',
      'imageUrl':
          'https://example.com/placeholder.jpg', // Replace with actual URLs
      'duration': '24h 30min',
    },
    {
      'title': 'Le Comte de Monte-Cristo',
      'author': 'Alexandre Dumas',
      'description': 'Une histoire de vengeance et de justice',
      'imageUrl': 'https://example.com/placeholder.jpg',
      'duration': '18h 45min',
    },
    {
      'title': 'Madame Bovary',
      'author': 'Gustave Flaubert',
      'description': 'Le roman réaliste par excellence',
      'imageUrl': 'https://example.com/placeholder.jpg',
      'duration': '12h 15min',
    },
  ];

  final List<Map<String, dynamic>> recentBooks = [
    {
      'title': 'Notre-Dame de Paris',
      'author': 'Victor Hugo',
      'imageUrl': 'https://example.com/placeholder.jpg',
      'duration': '16h 20min',
    },
    {
      'title': 'Le Rouge et le Noir',
      'author': 'Stendhal',
      'imageUrl': 'https://example.com/placeholder.jpg',
      'duration': '14h 30min',
    },
    {
      'title': 'Germinal',
      'author': 'Émile Zola',
      'imageUrl': 'https://example.com/placeholder.jpg',
      'duration': '15h 45min',
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
    return index % featuredBooks.length;
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
                'Littérature Audio',
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
                  icon: const Icon(Icons.account_circle_outlined,
                      color: Colors.white),
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
                    'Bienvenue,',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Découvrez nos livres audio',
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
                        child: _buildFeaturedCard(actualIndex),
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
                    'Livres Récents',
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
                childAspectRatio: 0.75, // Modified for book cover proportions
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemBuilder: (context, index) {
                return _buildBookCard(index % recentBooks.length);
              },
              itemCount: 6,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
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
            child: Stack(
              children: [
                // Book Cover Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.network(
                    featuredBooks[index]['imageUrl'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[900],
                        child: const Center(
                          child: Icon(
                            Icons.book,
                            color: Colors.white54,
                            size: 50,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Gradient Overlay
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                        Colors.black.withOpacity(0.9),
                      ],
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        featuredBooks[index]['title'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Par ${featuredBooks[index]['author']}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        featuredBooks[index]['description'],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Wrap(
                        spacing: 15, // Horizontal space between children
                        runSpacing: 10, // Vertical space between lines
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20, // Reduced from 25
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize
                                  .min, // Important: makes Row take minimum space
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize
                                  .min, // Important: makes Row take minimum space
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  featuredBooks[index]['duration'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
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
              ],
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
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book Cover
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Image.network(
                    recentBooks[index]['imageUrl'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[900],
                        child: const Center(
                          child: Icon(
                            Icons.book,
                            color: Colors.white54,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Book Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recentBooks[index]['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recentBooks[index]['author'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          recentBooks[index]['duration'],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
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
