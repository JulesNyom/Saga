import 'package:flutter/material.dart';

class Listen extends StatefulWidget {
  const Listen({Key? key}) : super(key: key);

  @override
  _ListenState createState() => _ListenState();
}

class _ListenState extends State<Listen> {
  bool isPlaying = false;
  
  final Map<String, dynamic> currentBook = {
    'title': 'Gatsby le Magnifique',
    'author': 'F. Scott Fitzgerald',
    'coverUrl': 'https://example.com/cover.jpg',
    'description': 'Se déroulant pendant l\'été 1922 à Long Island, ce classique américain suit le mystérieux millionnaire Jay Gatsby et son obsession pour Daisy Buchanan.',
    'currentChapter': 'Chapitre 3',
    'progress': 0.45,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'En lecture',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book Cover
              Center(
                child: Container(
                  width: 300,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.book, size: 80, color: Colors.white54),
                ),
              ),
              const SizedBox(height: 32),
              
              // Book Title and Author
              Center(
                child: Column(
                  children: [
                    Text(
                      currentBook['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'par ${currentBook['author']}',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentBook['currentChapter'],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Progress Slider
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.grey[800],
                  thumbColor: Colors.white,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayColor: Colors.white.withOpacity(0.2),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                ),
                child: Slider(
                  value: currentBook['progress'],
                  onChanged: (value) {
                    setState(() {
                      currentBook['progress'] = value;
                    });
                  },
                ),
              ),
              
              // Time indicators
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '14:22',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    Text(
                      '32:04',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Player Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous),
                    iconSize: 32,
                    color: Colors.white70,
                    onPressed: () {},
                    tooltip: 'Chapitre précédent',
                  ),
                  IconButton(
                    icon: const Icon(Icons.replay_10),
                    iconSize: 32,
                    color: Colors.white70,
                    onPressed: () {},
                    tooltip: 'Reculer de 10 secondes',
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: FloatingActionButton(
                      backgroundColor: Colors.white,
                      onPressed: () {
                        setState(() {
                          isPlaying = !isPlaying;
                        });
                      },
                      tooltip: isPlaying ? 'Pause' : 'Lecture',
                      child: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 32,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.forward_10),
                    iconSize: 32,
                    color: Colors.white70,
                    onPressed: () {},
                    tooltip: 'Avancer de 10 secondes',
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next),
                    iconSize: 32,
                    color: Colors.white70,
                    onPressed: () {},
                    tooltip: 'Chapitre suivant',
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Additional controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.volume_up),
                    color: Colors.white70,
                    onPressed: () {},
                    tooltip: 'Volume',
                  ),
                  const SizedBox(width: 32),
                  IconButton(
                    icon: const Icon(Icons.speed),
                    color: Colors.white70,
                    onPressed: () {},
                    tooltip: 'Vitesse de lecture',
                  ),
                  const SizedBox(width: 32),
                  IconButton(
                    icon: const Icon(Icons.timer),
                    color: Colors.white70,
                    onPressed: () {},
                    tooltip: 'Minuterie de sommeil',
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