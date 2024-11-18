import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Library extends StatefulWidget {
  const Library({super.key});

  @override
  State<Library> createState() => _BooksPageState();
}

class _BooksPageState extends State<Library> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  final List<Map<String, dynamic>> books = [
    {
      'title': 'Les Misérables',
      'author': 'Victor Hugo',
      'duration': '24h 30min',
      'imageUrl': 'https://example.com/placeholder.jpg', // Replace with actual URLs
      'progress': 0.3, // Optional: Add reading progress
    },
    {
      'title': 'Le Comte de Monte-Cristo',
      'author': 'Alexandre Dumas',
      'duration': '18h 45min',
      'imageUrl': 'https://example.com/placeholder.jpg',
      'progress': 0.5,
    },
    {
      'title': 'Madame Bovary',
      'author': 'Gustave Flaubert',
      'duration': '12h 15min',
      'imageUrl': 'https://example.com/placeholder.jpg',
      'progress': 0.0,
    },
    {
      'title': 'Notre-Dame de Paris',
      'author': 'Victor Hugo',
      'duration': '16h 20min',
      'imageUrl': 'https://example.com/placeholder.jpg',
      'progress': 0.7,
    },
    {
      'title': 'Le Rouge et le Noir',
      'author': 'Stendhal',
      'duration': '14h 30min',
      'imageUrl': 'https://example.com/placeholder.jpg',
      'progress': 0.0,
    },
    {
      'title': 'Germinal',
      'author': 'Émile Zola',
      'duration': '15h 45min',
      'imageUrl': 'https://example.com/placeholder.jpg',
      'progress': 0.2,
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onMainScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onMainScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onMainScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  void _navigateToListenPage(BuildContext context) {
    HapticFeedback.mediumImpact();
    // TODO: Implement navigation to Library page
    print('Navigating to Library page');
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
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75, // Modified for book cover proportions
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildBookCard(index),
                childCount: books.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 30),
          ),
        ],
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
                flex: 4, // Increased flex ratio for cover
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        books[index]['imageUrl'],
                        fit: BoxFit.cover,
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
                      // Progress Overlay
                      if (books[index]['progress'] > 0)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${(books[index]['progress'] * 100).toInt()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
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
                  mainAxisSize: MainAxisSize.min, // Added this
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      books[index]['title'],
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
                      books[index]['author'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8), // Reduced spacing
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Colors.white.withOpacity(0.6),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              books[index]['duration'],
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
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