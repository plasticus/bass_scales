# Bass Scale Visualizer 🎸

A high-performance, landscape-first Flutter application for visualizing musical scales and intervals on the bass and guitar. Engineered by LowEndLabs.

Built with a custom painting engine to render crisp, dynamically scalable fretboards that stretch up to 24 frets, complete with customizable luthier options and deep space aesthetics.

## Features

* **Dynamic Fretboard Engine:** Automatically resizes notes and spacing based on the selected instrument.
  * **Bass:** Supports 4, 5 (Low B), and 6-string (High C) tunings.
  * **Guitar:** Supports standard 6-string and 7-string extended tunings.
* **Full Range View:** Scrollable 24-fret neck featuring a dedicated "Open String" zone and a pronounced Nut.
* **Luthier's Shop Customization:** * Choose your fretboard wood (Rosewood, Maple, or Clear).
  * Customize your inlays (Classic Dots, Blocks, or our custom "Quasar" design).
* **Music Theory Logic:** * Toggle the display labels between **Note Names** (C, E, G) and **Intervals** (1, 3, 5).
* **Extensive Scale Library:**
  * *Standard:* Major, Natural Minor, Pentatonics, Blues.
  * *Modes:* Dorian, Mixolydian, Phrygian Dominant.
  * *Exotic:* Prometheus, Harmonic/Melodic Minor.
* **Persistent Settings:** Uses local storage to remember your exact configuration (instrument, scale, visual settings) between jam sessions.
* **Performance Mode:** Built-in Wakelock toggle prevents your screen from going to sleep while you are practicing.
* **Cosmic Aesthetics:** Optional adjustable starfield background for late-night inspiration.

## Tech Stack

* **Framework:** Flutter (Dart)
* **Rendering:** `CustomPainter` for pixel-perfect, high-performance graphics.
* **Local Storage:** `shared_preferences` for saving user configurations.
* **Device Control:** `wakelock_plus` for keeping the device screen active.

## Getting Started

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/plasticus/bass_scales.git](https://github.com/plasticus/bass_scales.git)
    cd bass_scales
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the app:**
    ```bash
    flutter run
    ```
