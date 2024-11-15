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

  // Expanded books list with additional details
  final List<Map<String, dynamic>> books = [
    {
      'title': 'Le Pouvoir du Moment Présent',
      'author': 'Eckhart Tolle',
      'duration': '8h 30min',
      'color': const Color(0xFF1E3D59),
    },
    {
      'title': 'L\'Art de la Méditation',
      'author': 'Matthieu Ricard',
      'duration': '6h 15min',
      'color': const Color(0xFF17B978),
    },
    {
      'title': 'Respire',
      'author': 'James Nestor',
      'duration': '7h 45min',
      'color': const Color(0xFFFF6B6B),
    },
    {
      'title': 'La Magie du Matin',
      'author': 'Hal Elrod',
      'duration': '5h 20min',
      'color': const Color(0xFF4831D4),
    },
    {
      'title': 'Calme et Attentif',
      'author': 'Susan Kaiser Greenland',
      'duration': '4h 50min',
      'color': const Color(0xFFCCF381),
    },
    {
      'title': 'Le Miracle du Mindfulness',
      'author': 'Thich Nhat Hanh',
      'duration': '6h 40min',
      'color': const Color(0xFF317773),
    },
    {
      'title': 'Méditer Jour Après Jour',
      'author': 'Christophe André',
      'duration': '9h 15min',
      'color': const Color(0xFFE2D810),
    },
    {
      'title': 'La Voie des Émotions',
      'author': 'Clarisse Gardet',
      'duration': '5h 55min',
      'color': const Color(0xFFD92027),
    },
    {
      'title': 'Le Livre du Hygge',
      'author': 'Meik Wiking',
      'duration': '4h 30min',
      'color': const Color(0xFF8E44AD),
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
                    'Découvrez notre vaste collection de livres audio gratuits.',
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
                childAspectRatio: 0.8,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildExpandedBookCard(index),
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

  Widget _buildExpandedBookCard(int index) {
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
                  children: [
                    Text(
                      books[index]['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      books[index]['author'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.white.withOpacity(0.7),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          books[index]['duration'],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Écouter',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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