import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tab_screens/about.dart';
import 'tab_screens/listen.dart';
import 'tab_screens/home.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isPlaying = false;
  double _playbackProgress = 0.0;
  String _currentBookTitle = 'Le Pouvoir du Moment Présent';
  String _currentChapter = 'Chapitre 3 - La Conscience de Soi';
  Duration _currentPosition = const Duration(minutes: 14, seconds: 23);
  Duration _totalDuration = const Duration(minutes: 45, seconds: 30);

  final List<Widget> _screens = const [
    Home(),
    Listen(),
    About(),
  ];

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    // Add your audio player logic here
  }

  void _seekTo(double value) {
    setState(() {
      _playbackProgress = value;
      _currentPosition = Duration(
        seconds: (value * _totalDuration.inSeconds).round(),
      );
    });
    // Add your audio seek logic here
  }

  void _rewind10Seconds() {
    final newPosition = _currentPosition - const Duration(seconds: 10);
    setState(() {
      _currentPosition = newPosition.isNegative ? Duration.zero : newPosition;
      _playbackProgress = _currentPosition.inSeconds / _totalDuration.inSeconds;
    });
    // Add your audio seek logic here
  }

  void _forward30Seconds() {
    final newPosition = _currentPosition + const Duration(seconds: 30);
    setState(() {
      _currentPosition = newPosition > _totalDuration ? _totalDuration : newPosition;
      _playbackProgress = _currentPosition.inSeconds / _totalDuration.inSeconds;
    });
    // Add your audio seek logic here
  }

  Widget _buildPlaybackBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.9),
            const Color(0xFF1E1E1E),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                const SizedBox(height: 12),
                // Book info and controls
                Row(
                  children: [
                    // Book cover
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF4158D0),
                            Color(0xFFC850C0),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.book,
                        color: Colors.white54,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title and chapter
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentBookTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _currentChapter,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Playback controls
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.replay_10_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: _rewind10Seconds,
                        ),
                        Container(
                          height: 48,
                          width: 48,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.blue[400]!,
                                Colors.blue[600]!,
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue[400]!.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              _isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: _togglePlayPause,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.forward_30_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: _forward30Seconds,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPlaybackBar(),
          Theme(
            data: ThemeData(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: Container(
              color: Colors.black,
              padding: const EdgeInsets.only(
                top: 12,
                bottom: 32,
                left: 24,
                right: 24,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(
                    0,
                    "Accueil",
                    Icons.home_rounded,
                  ),
                  _buildNavItem(
                    1,
                    "Bibliothèque",
                    Icons.menu_book_rounded,
                  ),
                  _buildNavItem(
                    2,
                    "A propos",
                    Icons.person_rounded,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E1E1E) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 26,
            ),
            const SizedBox(height: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}