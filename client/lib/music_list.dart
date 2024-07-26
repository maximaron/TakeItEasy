import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MusicListPage extends StatefulWidget {
  const MusicListPage({Key? key}) : super(key: key);

  @override
  _MusicListPageState createState() => _MusicListPageState();
}

class _MusicListPageState extends State<MusicListPage> {
  final List<Map<String, String>> musicList = [
    {'title': 'Autumn Sky', 'file': 'audio/autumn-sky-meditation-7618.mp3'},
    {'title': 'Deep Meditation', 'file': 'audio/deep-meditation-192828.mp3'},
    {'title': 'The Old Water Mill', 'file': 'audio/the-old-water-mill-meditation-8005.mp3'},
  ];

  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentFilePath;
  PlayerState _playerState = PlayerState.stopped;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playMusic(String filePath) async {
    try {
      if (_playerState == PlayerState.paused && _currentFilePath == filePath) {
        await _audioPlayer.resume();
      } else {
        await _audioPlayer.play(AssetSource(filePath));
        _currentFilePath = filePath;
      }
      setState(() {
        _playerState = PlayerState.playing;
      });
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  Future<void> _pauseMusic() async {
    try {
      await _audioPlayer.pause();
      setState(() {
        _playerState = PlayerState.paused;
      });
    } catch (e) {
      print("Error pausing audio: $e");
    }
  }

  Future<void> _stopMusic() async {
    try {
      await _audioPlayer.stop();
      setState(() {
        _playerState = PlayerState.stopped;
      });
    } catch (e) {
      print("Error stopping audio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music List'),
      ),
      body: ListView.builder(
        itemCount: musicList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(musicList[index]['title']!),
            onTap: () => _playMusic(musicList[index]['file']!),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _playerState == PlayerState.playing ? _pauseMusic : () => _playMusic(_currentFilePath!),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            child: Icon(_playerState == PlayerState.playing ? Icons.pause : Icons.play_arrow),
            tooltip: _playerState == PlayerState.playing ? 'Pause Music' : 'Play Music',
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
