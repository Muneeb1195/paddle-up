# Paddle Up

A brick-breaking paddle game built with Godot 4.7.

## Game Modes

- **BB Modern** - Classic brick-breaker with progressive difficulty, multiple ball types, and power-ups
- **BB Classic** - Traditional brick-breaking gameplay
- **Pong** - Single-player pong against CPU opponent

## Features

- Multiple brick types (square, triangle, circle) with HP system
- Ball retrieval mechanic (Stop-state balls return to paddle)
- Trajectory preview line for aiming
- Progressive difficulty scaling
- High score tracking per game mode
- Pause menu with save/resume
- Time tracking per level

## Tech Stack

- Godot 4.7 (GDScript, GL Compatibility renderer)
- Object pooling for ball performance (200 pre-instantiated)
- Signal-based ball-brick collision
- Deferred ball removal for physics safety
- Shared `LabelSettings` for UI performance

## Building

### Android

```bash
godot --headless --import
godot --headless --install-android-build-template
godot --headless --export-release "Android" builds/PaddleUp.apk
```

### Requirements

- Godot 4.7 stable
- Android SDK (API 34+)
- Java 17 (for Gradle)

## Project Structure

```
Scripts/
  level_bb.gd           - Base brick logic, collision map, save/load
  level_bb_modern.gd    - BB Modern mode
  level_bb_classic.gd   - BB Classic mode
  level_pong.gd         - Pong mode
  ball.gd               - Ball physics and prediction
  balls_bb.gd           - Ball pool, spawn, state machine
  trajectory.gd         - Aiming line with raycast trajectory
  Enemy.gd              - CPU paddle AI
Globals/
  global.gd             - Save/load, high scores, color palette
  fade.gd               - Scene transitions
  AudioManager          - Sound effects
```

## License

All rights reserved. SoftwareWorks.
