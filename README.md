# Bass Scale Visualizer 🎸

A high-performance, landscape-first Flutter application for visualizing musical scales on the bass guitar.

Built with a custom painting engine to render crisp, dynamically scalable fretboards for 4, 5, and 6-string basses.

## Features

* **Dynamic Fretboard Engine:** automatically resizes notes and spacing based on string count (4, 5, or 6 strings).
* **Full Range View:** Scrollable 24-fret neck with standard "Mother of Pearl" style inlays (3, 5, 7, 9, 12, etc.).
* **Music Theory Logic:** * Switch between **Note Names** (C, E, G) and **Intervals** (R, 3, 5).
    * Supports Standard, Low B (5-string), and High C (6-string) tunings.
* **Extensive Scale Library:**
    * Standard: Major, Natural Minor, Pentatonics, Blues.
    * Modes: Dorian, Mixolydian, Phrygian Dominant.
    * Exotic: Prometheus, Harmonic/Melodic Minor.
* **Landscape Optimized:** Designed specifically for phone/tablet landscape usage while practicing.

## Tech Stack

* **Framework:** Flutter (Dart)
* **Rendering:** `CustomPainter` for pixel-perfect, high-performance graphics.
* **State Management:** Native `setState` (Lightweight and efficient).

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