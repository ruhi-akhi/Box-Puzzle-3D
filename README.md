# Amaze GO! 3D Puzzle Game

A beautiful, professional, and highly addictive puzzle game made with Flutter. Tap arrows or segmented worms to clear them from the board.

## How to Run Locally

To run the game on your computer in Chrome:
```bash
flutter run -d chrome
```
C:\Users\WALTON\flutter\bin
To run on an Android or iOS emulator:
```bash


```

---

## How to Build & Publish to Itch.io (HTML5 Web)

To build a standalone Web build that you can upload directly to itch.io:

1. **Build the Web project**:
   Run this command in the project root:
   ```bash
   flutter build web --release --web-renderer canvaskit
   ```
   This will compile the game into HTML, JavaScript, and WebGL assets, located in `build/web/`.

2. **Package the build**:
   - Go to the `build/web/` directory.
   - Select all files inside the `web` folder and compress them into a `.zip` archive (e.g., `amaze_go_web.zip`). **Make sure `index.html` is at the root level of the zip file, not inside a subfolder.**

3. **Upload to Itch.io**:
   - Log in to your [itch.io](https://itch.io/) dashboard and create a new project.
   - Set **Kind of project** to **HTML** (plays in the browser).
   - Under **Uploads**, upload your `amaze_go_web.zip` file.
   - Tick the checkbox **This file will be played in the browser**.
   - Configure the viewport dimensions (e.g., width `480px`, height `720px` to look like a mobile portrait phone).
   - Save and view your page to test!

---

## How to Build for Mobile (Android & iOS)

- **Android (APK)**:
  ```bash
  flutter build apk --release
  ```
  The resulting APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

- **iOS (App Store Bundle)**:
  ```bash
  flutter build ipa --release
  ```
