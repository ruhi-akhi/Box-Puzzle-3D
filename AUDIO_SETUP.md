# Music & Audio Setup Guide

## ✅ Audio System is Ready!

Your game now has a complete audio system with **graceful handling** of missing files. The app will run fine even without audio files—just add them when you're ready!

---

## Step 1: Download Professional Music

Get royalty-free music from these websites:

- **OpenGameArt.org** - Best for game music
- **Freesound.org** - Community sound effects
- **itch.io/sounds** - Game-specific audio
- **Zapsplat.com** - No registration needed
- **Pixabay** - High-quality free music

**Recommended Search Terms:**

- "puzzle game background music"
- "casual game music"
- "ambient gameplay music"

**Audio Requirements:**

- Format: **MP3** (best for web/mobile) or WAV/OGG
- Bitrate: 128-192 kbps for music, 64-128 kbps for effects
- Sample Rate: 44.1kHz or 48kHz
- Background Music Length: 1-3 minutes (loops automatically)

---

## Step 2: Add Audio Files to Your Project

### 1. Place Background Music

- Download an MP3 file (e.g., `background_music.mp3`)
- Move it to: `assets/music/background_music.mp3`
- File size: Keep under 2-5 MB for optimal loading

### 2. Place Sound Effects (Optional)

Create these sound effect files in `assets/sounds/`:

- `match_clear.mp3` - When a path is cleared (~0.5-1 sec)
- `victory.mp3` - Level complete (~1-2 sec)
- `defeat.mp3` - Game over (~1-2 sec)
- `button_click.mp3` - UI clicks (~0.2-0.5 sec)
- `select_sound.mp3` - Path selection (~0.3-0.5 sec)

**Where to find sound effects:**

- Freesound.org (search: "puzzle click", "victory sound", etc.)
- itch.io/sounds/
- OpenGameArt.org



## Step 3: Test Your Changes

1. **Run the game:**

   ```bash
   flutter run -d chrome    # Web
   flutter run              # Mobile emulator
   ```

2. **Check the Settings ⚙️** in the home screen to:
   - Toggle background music on/off
   - Toggle sound effects on/off

3. **No audio files yet?** No problem! The app works perfectly without them.



## Step 4: Use Audio in Your Game Code

When you want to play sounds during gameplay, use the `GameAudio` helper:

```dart
import 'services/game_audio.dart';

// When a path is matched
await GameAudio.playPathClear();

// When player wins a level
await GameAudio.playVictory();

// When player loses
await GameAudio.playDefeat();

// For UI button clicks
await GameAudio.playButtonClick();


## Quick Audio File Recommendations

**For Background Music:**

- "Carefree" by Kevin MacLeod (8-bit style)
- "Retro Platformer" series (OpenGameArt.org)
- Search "casual puzzle game background" on YouTube Audio Library

**For Sound Effects:**

- "Classic 8-bit Sounds" pack
- "UI Sounds" packs on itch.io
- "Casual Game Sounds" collections



## Troubleshooting

### ❌ "Audio file not found" message

- Check that `assets/music/` folder exists
- Verify file names match exactly (case-sensitive)
- Run `flutter pub get` after adding files

### ❌ Web build doesn't play audio

- Ensure MP3 files are included in web build
- Web audio requires HTTPS or localhost (not file://)
- Check browser console for errors

### ❌ Audio too loud or quiet

- Adjust in code:
  dart
  await GameAudio.setMusicVolume(0.5);   // 50%
  await GameAudio.setSoundVolume(0.7);   // 70%




## Audio System Features

✅ **Automatic background music looping**  
✅ **Independent music/sound effect toggles**  
✅ **Settings UI in-game** (⚙️ button)  
✅ **Web/Mobile/Desktop compatible**  
✅ **Gracefully handles missing files**  
✅ **Volume control**



## File Structure


assets/
├── music/
│   └── background_music.mp3
└── sounds/
    ├── match_clear.mp3
    ├── victory.mp3
    ├── defeat.mp3
    ├── button_click.mp3
    └── select_sound.mp3

lib/services/
├── audio_manager.dart      # Core audio system
└── game_audio.dart         # Easy-to-use helpers


Ready to add audio? Download a track and drop it into `assets/music/`! 🎵
