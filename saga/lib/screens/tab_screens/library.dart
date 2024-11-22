import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

class Library extends StatefulWidget {
  const Library({super.key});

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  List<Map<String, dynamic>> featuredBooks = [];
  List<Map<String, dynamic>> recentBooks = [];
  bool isLoading = false;
  bool hasMoreBooks = true;
  int currentPage = 1;
  int totalPages = 1;

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
    _scrollController.addListener(_onScroll);
    fetchBooks();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;

    setState(() {
      _scrollOffset = _scrollController.offset;
    });

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreBooks();
    }
  }

  Future<void> fetchBooks() async {
    if (isLoading || !hasMoreBooks || !mounted) return;

    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/v1/popular?page=$currentPage'),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          if (currentPage == 1) {
            featuredBooks =
                List<Map<String, dynamic>>.from(data['featured_books']);
            recentBooks = List<Map<String, dynamic>>.from(data['recent_books']);
          } else {
            recentBooks
                .addAll(List<Map<String, dynamic>>.from(data['recent_books']));
          }

          totalPages = data['total_pages'];
          hasMoreBooks = currentPage < totalPages;
          currentPage++;
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

  Future<void> _loadMoreBooks() async {
    if (!isLoading && hasMoreBooks) {
      await fetchBooks();
    }
  }

  double get _appBarOpacity {
    const showAt = 20.0;
    const fullyVisibleAt = 100.0;

    if (_scrollOffset <= showAt) return 0.0;
    if (_scrollOffset >= fullyVisibleAt) return 1.0;

    return (_scrollOffset - showAt) / (fullyVisibleAt - showAt);
  }

  Widget _buildBookCard(Map<String, dynamic> book) {
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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
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
                'Bibliothèque',
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
            ],
          ),
        ),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 100, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bibliothèque',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Découvrez notre collection de livres audio classiques.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (featuredBooks.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
                child: Text(
                  'Les plus populaires',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildBookCard(featuredBooks[index]),
                  childCount: featuredBooks.length,
                ),
              ),
            ),
          ],
          if (recentBooks.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 15),
                child: Text(
                  'Autres livres',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildBookCard(recentBooks[index]),
                  childCount: recentBooks.length,
                ),
              ),
            ),
          ],
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : hasMoreBooks
                        ? FloatingActionButton(
                            backgroundColor: Colors.white,
                            mini: true,
                            onPressed: _loadMoreBooks,
                            child: const Icon(
                              Icons.add,
                              color: Colors.black,
                            ),
                          )
                        : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
