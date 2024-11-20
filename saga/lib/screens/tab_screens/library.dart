import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AudioBook {
  final String id;
  final String title;
  final String author;
  final String imageUrl;
  final String duration;
  final String narrator;
  final String date;
  final String views;
  final String url;
  double progress;

  AudioBook({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.duration,
    required this.narrator,
    required this.date,
    required this.views,
    required this.url,
    this.progress = 0.0,
  });

  factory AudioBook.fromJson(Map<String, dynamic> json) {
    return AudioBook(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      imageUrl: json['imageUrl'],
      duration: json['duration'],
      narrator: json['narrator'] ?? '',
      date: json['date'] ?? '',
      views: json['views'],
      url: json['url'],
    );
  }
}

class Library extends StatefulWidget {
  const Library({super.key});

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  List<AudioBook> books = [];
  bool isLoading = false;
  bool hasMoreBooks = true;
  int currentPage = 1;
  int totalPages = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchBooks();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });

    // Check if we're near the bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreBooks();
    }
  }

  Future<void> _fetchBooks() async {
    if (isLoading || !hasMoreBooks) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://your-api-url/popular?page=$currentPage'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<AudioBook> newBooks = (data['books'] as List)
            .map((book) => AudioBook.fromJson(book))
            .toList();

        setState(() {
          books.addAll(newBooks);
          totalPages = data['total_pages'];
          hasMoreBooks = currentPage < totalPages;
          currentPage++;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        // Handle error
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error
    }
  }

  Future<void> _loadMoreBooks() async {
    if (!isLoading && hasMoreBooks) {
      await _fetchBooks();
    }
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
                childAspectRatio: 0.75,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildBookCard(index),
                childCount: books.length,
              ),
            ),
          ),
          if (isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          if (hasMoreBooks && !isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: FloatingActionButton(
                    backgroundColor: Colors.white,
                    mini: true,
                    child: const Icon(
                      Icons.add,
                      color: Colors.black,
                    ),
                    onPressed: _loadMoreBooks,
                  ),
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
    final book = books[index];
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToListenPage(context, book),
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
              Expanded(
                flex: 4,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        book.imageUrl,
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
                      if (book.progress > 0)
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
                              '${(book.progress * 100).toInt()}%',
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
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
                      book.author,
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
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Colors.white.withOpacity(0.6),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              book.duration,
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

  void _navigateToListenPage(BuildContext context, AudioBook book) {
    HapticFeedback.mediumImpact();
    // TODO: Implement navigation to listen page with book data
    print('Navigating to listen page for: ${book.title}');
  }
}