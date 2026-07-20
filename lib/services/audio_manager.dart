import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  late AudioPlayer _backgroundMusic;
  late AudioPlayer _soundEffects;
  bool _isMusicEnabled = true;
  bool _isSoundEnabled = true;
  bool _audioAvailable = true; // Track if audio files are available

  factory AudioManager() {
    return _instance;
  }

  AudioManager._internal() {
    _backgroundMusic = AudioPlayer();
    _soundEffects = AudioPlayer();
    _initAudio();
  }

  void _initAudio() {
    _backgroundMusic.setReleaseMode(ReleaseMode.loop);
    _soundEffects.setReleaseMode(ReleaseMode.release);
  }

  /// Play background music (loops) - gracefully handles missing files
  Future<void> playBackgroundMusic(String musicPath) async {
    if (!_isMusicEnabled || !_audioAvailable) return;
    try {
      await _backgroundMusic.play(AssetSource(musicPath));
    } catch (e) {
      _audioAvailable = false;
      print('⚠️ Audio file not found: $musicPath');
      print('📁 Please add your music files to assets/music/ directory');
    }
  }

  /// Stop background music
  Future<void> stopBackgroundMusic() async {
    try {
      await _backgroundMusic.stop();
    } catch (e) {
      // Ignore stop errors
    }
  }

  /// Play sound effect (doesn't loop) - gracefully handles missing files
  Future<void> playSoundEffect(String soundPath) async {
    if (!_isSoundEnabled || !_audioAvailable) return;
    try {
      await _soundEffects.play(AssetSource(soundPath));
    } catch (e) {
      // Silently fail for sound effects to avoid spam
    }
  }

  /// Set background music volume (0.0 to 1.0)
  Future<void> setMusicVolume(double volume) async {
    await _backgroundMusic.setVolume(volume.clamp(0.0, 1.0));
  }

  /// Set sound effects volume (0.0 to 1.0)
  Future<void> setSoundVolume(double volume) async {
    await _soundEffects.setVolume(volume.clamp(0.0, 1.0));
  }

  /// Toggle music on/off
  Future<void> toggleMusic() async {
    _isMusicEnabled = !_isMusicEnabled;
    if (!_isMusicEnabled) {
      await stopBackgroundMusic();
    }
  }

  /// Toggle sound effects on/off
  void toggleSound() {
    _isSoundEnabled = !_isSoundEnabled;
  }

  /// Check if music is enabled
  bool get isMusicEnabled => _isMusicEnabled;

  /// Check if sound is enabled
  bool get isSoundEnabled => _isSoundEnabled;

  /// Dispose audio players
  Future<void> dispose() async {
    await _backgroundMusic.dispose();
    await _soundEffects.dispose();
  }
}
