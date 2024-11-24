// ignore_for_file: unused_local_variable, dead_code

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WavyTopBorderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 40);

    final firstControlPoint = Offset(size.width / 4, 0);
    final firstEndPoint = Offset(size.width / 2, 20);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    final secondControlPoint = Offset(size.width * 3 / 4, 40);
    final secondEndPoint = Offset(size.width, 0);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  final ScrollController _scrollController = ScrollController();
  double _currentPage = 0.0;
  double _scrollOffset = 0.0;

  List<Map<String, dynamic>> featuredBooks = [];
  List<Map<String, dynamic>> recentBooks = [];
  bool isLoading = true;

  // Cache gradients to avoid recreating them
  static final List<List<Color>> gradients = [
    [const Color(0xFF1A2980), const Color(0xFF26D0CE)],
    [const Color(0xFF4568DC), const Color(0xFFB06AB3)],
    [const Color(0xFFFF416C), const Color(0xFFFF4B2B)],
    [const Color(0xFF654EA3), const Color(0xFFEAAFC8)],
    [const Color(0xFF00B4DB), const Color(0xFF0083B0)],
    [const Color(0xFFad5389), const Color(0xFF3c1053)],
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onPageScroll);
    _scrollController.addListener(_onMainScroll);
    fetchBooks();
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _scrollController.removeListener(_onMainScroll);
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchBooks() async {
    setState(() => isLoading = true);
    try {
      final response =
          await http.get(Uri.parse('http://localhost:8000/api/v1'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          featuredBooks =
              List<Map<String, dynamic>>.from(data['featured_books']);
          recentBooks = List<Map<String, dynamic>>.from(data['recent_books']);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load books: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading books: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      });
    }
  }

  void _onMainScroll() {
    if (mounted) {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    }
  }

  void _onPageScroll() {
    if (mounted) {
      setState(() {
        _currentPage = _pageController.page ?? 0;
      });
    }
  }

  int _getActualIndex(int index) => index % featuredBooks.length;

  void _navigateToListenPage(BuildContext context, Map<String, dynamic> book) {
    HapticFeedback.mediumImpact();
    // TODO: Implement navigation to Listen page
    print('Navigating to Listen page for: ${book['title']}');
  }

  double get _appBarOpacity {
    const showAt = 20.0;
    const fullyVisibleAt = 100.0;

    if (_scrollOffset <= showAt) return 0.0;
    if (_scrollOffset >= fullyVisibleAt) return 1.0;

    return ((_scrollOffset - showAt) / (fullyVisibleAt - showAt))
        .clamp(0.0, 1.0);
  }

  Widget _buildBookCard(int index) {
    final book = recentBooks[index];
    final gradientIndex = book['title'].hashCode.abs() % gradients.length;
    final gradient = gradients[gradientIndex];

    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;

        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            tween: Tween<double>(
              begin: 1.0,
              end: isHovered ? 1.05 : 1.0,
            ),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTapDown: (_) => setState(() => isHovered = true),
                    onTapUp: (_) => setState(() => isHovered = false),
                    onTapCancel: () => setState(() => isHovered = false),
                    onTap: () => _navigateToListenPage(context, book),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Hero(
                              tag: 'book-${book['id']}',
                              child: Image.network(
                                book['imageUrl'] ?? '',
                                fit: BoxFit.cover,
                                height: double.infinity,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: gradient,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.book,
                                        color: Colors.white70,
                                        size: 40,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          if (book['progress'] != null && book['progress'] > 0)
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      gradient[0].withOpacity(0.85),
                                      gradient[1].withOpacity(0.85),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '${(book['progress'] * 100).toInt()}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: ClipPath(
                              clipper: WavyTopBorderClipper(),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                child: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 32, 12, 12),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(
                                      bottom: Radius.circular(20),
                                    ),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        gradient[0].withOpacity(0.3),
                                        gradient[1].withOpacity(0.3),
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        book['title'] ?? 'Unknown Title',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          height: 1.2,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        book['author'] ?? 'Unknown Author',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                color: Colors.white
                                                    .withOpacity(0.9),
                                                size: 12,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                book['duration'] ?? 'Unknown',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.9),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.play_arrow_rounded,
                                              color: Colors.white,
                                              size: 16,
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
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFeaturedCard(int index) {
    final book = featuredBooks[index];
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
            onTap: () => _navigateToListenPage(context, book),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.network(
                    book['imageUrl'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      final gradientIndex =
                          book['title'].hashCode.abs() % gradients.length;
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
                Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book['title'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Par ${book['author']}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Wrap(
                        spacing: 15,
                        runSpacing: 10,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
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
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  book['duration'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
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
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.headphones,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${book['views']} écoutes',
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          color: Colors.transparent,
          child: AppBar(
            elevation: _appBarOpacity * 4,
            backgroundColor: Colors.black.withOpacity(_appBarOpacity),
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
            title: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
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
              AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: _appBarOpacity,
                child: IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {},
                ),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
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
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification is ScrollUpdateNotification) {
            setState(() {
              _scrollOffset = notification.metrics.pixels;
            });
          }
          return true;
        },
        child: RefreshIndicator(
          onRefresh: fetchBooks,
          color: Colors.white,
          backgroundColor: Colors.black,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: kToolbarHeight + 20),
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
                if (featuredBooks.isNotEmpty) ...[
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
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: _buildFeaturedCard(actualIndex),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
                if (recentBooks.isNotEmpty) ...[
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    ),
                    itemBuilder: (context, index) {
                      final actualIndex = index % recentBooks.length;
                      return _buildBookCard(actualIndex);
                    },
                    itemCount: recentBooks.length,
                  ),
                ],
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
