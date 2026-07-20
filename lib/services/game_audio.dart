import 'audio_manager.dart';

/// Extension for common game sound effects
class GameAudio {
  static final AudioManager _audioManager = AudioManager();

  /// Play sound when a path is cleared/matched
  static Future<void> playPathClear() async {
    await _audioManager.playSoundEffect('assets/sounds/match_clear.mp3');
  }

  /// Play sound when victory/level complete
  static Future<void> playVictory() async {
    await _audioManager.playSoundEffect('assets/sounds/victory.mp3');
  }

  /// Play sound when game over/defeat
  static Future<void> playDefeat() async {
    await _audioManager.playSoundEffect('assets/sounds/defeat.mp3');
  }

  /// Play sound for UI button interactions
  static Future<void> playButtonClick() async {
    await _audioManager.playSoundEffect('assets/sounds/button_click.mp3');
  }

  /// Play sound when selecting/tapping a path
  static Future<void> playSelect() async {
    await _audioManager.playSoundEffect('assets/sounds/select_sound.mp3');
  }

  /// Adjust background music volume
  static Future<void> setMusicVolume(double volume) async {
    await _audioManager.setMusicVolume(volume);
  }

  /// Adjust sound effects volume
  static Future<void> setSoundVolume(double volume) async {
    await _audioManager.setSoundVolume(volume);
  }

  /// Toggle music on/off
  static Future<void> toggleMusic() async {
    await _audioManager.toggleMusic();
  }

  /// Toggle sound effects on/off
  static void toggleSoundEffects() {
    _audioManager.toggleSound();
  }

  /// Check if music is playing
  static bool isMusicEnabled() => _audioManager.isMusicEnabled;

  /// Check if sounds are enabled
  static bool isSoundEnabled() => _audioManager.isSoundEnabled;

  /// Play background music (useful for screen transitions)
  static Future<void> playBackgroundMusic(String musicPath) async {
    await _audioManager.playBackgroundMusic(musicPath);
  }

  /// Stop background music
  static Future<void> stopBackgroundMusic() async {
    await _audioManager.stopBackgroundMusic();
  }
}
