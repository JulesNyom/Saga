import 'package:flutter/cupertino.dart';

class BooksGridPage extends StatelessWidget {
  BooksGridPage({super.key});

  // Sample book data - in a real app, this would come from your data source
  final List<Map<String, String>> books = List.generate(
    12,
    (index) => {
      'title': 'Book ${index + 1}',
      'imageUrl': 'https://picsum.photos/200/300', // Placeholder image URL
    },
  );

  @override
  Widget build(BuildContext context) {
    // Calculate card width based on screen size (3 cards per row with padding)
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - (4 * 16)) / 3; // 16 is the padding value
    
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      // Navigation bar at the top (iOS style)
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: CupertinoColors.black,
        middle: Text(
          'Books Collection',
          style: TextStyle(color: CupertinoColors.white),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          // CustomScrollView is used for better iOS-style scrolling
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(), // iOS-style bouncing scroll
            slivers: [
              // Grid of books
              SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // Show iOS-style modal when tapping a book
                        showCupertinoModalPopup(
                          context: context,
                          builder: (context) => CupertinoActionSheet(
                            title: Text(books[index]['title']!),
                            actions: [
                              CupertinoActionSheetAction(
                                onPressed: () {
                                  // Handle view details action
                                  Navigator.pop(context);
                                },
                                child: const Text('View Details'),
                              ),
                              CupertinoActionSheetAction(
                                onPressed: () {
                                  // Handle read book action
                                  Navigator.pop(context);
                                },
                                child: const Text('Read Book'),
                              ),
                            ],
                            cancelButton: CupertinoActionSheetAction(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              isDestructiveAction: true,
                              child: const Text('Cancel'),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Image.network(
                                books[index]['imageUrl']!,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              color: CupertinoColors.white,
                              child: Text(
                                books[index]['title']!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: CupertinoColors.black,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: books.length,
                ),
                // Grid layout configuration
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: cardWidth / (cardWidth * 1.5),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}