import 'package:flutter/material.dart';

class Listen extends StatefulWidget {
  const Listen({Key? key}) : super(key: key);

  @override
  _ListenState createState() => _ListenState();
}

class _ListenState extends State<Listen> {
  bool isPlaying = false;
  
  // Mock data for current book
  final Map<String, dynamic> currentBook = {
    'title': 'The Great Gatsby',
    'author': 'F. Scott Fitzgerald',
    'coverUrl': 'https://example.com/cover.jpg',
    'description': 'Set in the summer of 1922 on Long Island, this American classic follows the mysterious millionaire Jay Gatsby and his obsession with Daisy Buchanan.',
    'currentChapter': 'Chapter 3',
    'progress': 0.45,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Now Playing'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Book Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Book Cover and Info
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Book Cover
                          Container(
                            width: 120,
                            height: 180,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.book, size: 50, color: Colors.grey),
                          ),
                          const SizedBox(width: 16),
                          // Book Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentBook['title'],
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'by ${currentBook['author']}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  currentBook['currentChapter'],
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Description
                      Text(
                        currentBook['description'],
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Progress Slider
              Slider(
                value: currentBook['progress'],
                onChanged: (value) {
                  setState(() {
                    currentBook['progress'] = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Player Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Previous Book Button
                  IconButton(
                    icon: const Icon(Icons.skip_previous),
                    iconSize: 32,
                    onPressed: () {
                      // Handle previous book
                    },
                  ),
                  // Rewind 10 seconds
                  IconButton(
                    icon: const Icon(Icons.replay_10),
                    iconSize: 32,
                    onPressed: () {
                      // Handle rewind
                    },
                  ),
                  // Play/Pause Button
                  FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        isPlaying = !isPlaying;
                      });
                    },
                    child: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 32,
                    ),
                  ),
                  // Forward 10 seconds
                  IconButton(
                    icon: const Icon(Icons.forward_10),
                    iconSize: 32,
                    onPressed: () {
                      // Handle forward
                    },
                  ),
                  // Next Book Button
                  IconButton(
                    icon: const Icon(Icons.skip_next),
                    iconSize: 32,
                    onPressed: () {
                      // Handle next book
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}