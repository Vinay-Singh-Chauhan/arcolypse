# Game Design Document: Arcolypse (Working Title)

## 1. Executive Summary & Concept
**Arcolypse** is a strategic survival / tower-defense puzzle game built using Flutter (targeting Web first, with full Android mobile compatibility). Players manage a grid-based territory, construct protective enclosures, rescue civilian hostages, establish fortified sub-bases, and repel waves of infected / insurgent forces.

The game supports two distinct visual and narrative themes:
1. **Zombies Theme**: Classic biological outbreak, roaming undead hordes, mutated infection sources.
2. **Insurgency Theme**: Modern tactical warfare, terrorist cells, hostage situations, fortified militant bases.

---

## 2. Core Game Mechanics

### 2.1 Grid & Cell System
- **Grid Structure**: The playing field is a 2D grid of discrete cells ($N \times M$). Each cell represents a unit of space.
- **Cell Health**: Every cell has a finite health value. Taking damage from infection spread, attacks, or decay reduces cell health.
- **Enclosures**: 
  - Players can build walls around cells to form closed loops or secure boundaries (**Enclosures**).
  - Any cell lying entirely within a completed enclosure is marked as **Protected**. Protected cells take zero infection damage and cannot be breached unless the enclosing walls are destroyed.

### 2.2 Infection Mechanics
- **Infection Sources**: At the start of the game, specific cells are designated as initial infection sources.
- **Spread & Mutation**: 
  - Infection continuously tries to spread to adjacent cells.
  - **Criterion for Source Generation**: If a normal cell is surrounded by infected cells beyond a certain threshold (e.g., $\ge 3$ adjacent infected cells) or meets specific environmental criteria, it mutates and becomes a *new* secondary Source of Infection.

### 2.3 Protagonist & Wall Building
- **Protagonist**: Controlled by the player on the grid.
- **Action - Wall Building**: The player moves the protagonist across grid cells to place and reinforce walls, cutting off encroaching infection paths and enclosing civilians or critical resource nodes.

### 2.4 Civilians, Hostages & Infection Risk
- **Civilians**: Random cells spawn civilian hostages at preset or random intervals.
- **Rescue Mission**: The player must reach or enclose civilians to rescue them.
- **Hostage Corruption**: If the infection reaches a cell containing an unrescued civilian/hostage before extraction, they are corrupted and instantly transformed into **Zombies / Terrorists**.

### 2.5 Bases & Economy
- **Main Base**: 
  - Shielded by default at game start.
  - Represents the core command center with 100% maximum health.
- **Sub-Bases**:
  - Securing specific milestone cells from infection unlocks the ability to establish a **Sub-Base**.
  - Sub-bases function like the main base but possess **75% of the Main Base's health**.
- **Ammo & Weaponry**:
  - To eliminate enemies (Zombies/Terrorists), the player utilizes a ranged or tactical weapon.
  - **Ammo Supply Mechanics**: Ammo replenishment rate and max capacity scale dynamically based on the number of active (undestroyed) bases (Main + Sub-bases).

---

## 3. Themes & Customization
Players can toggle between two thematic skins from the main menu:
- **Zombies Theme**:
  - *Infection*: Biohazard sludge / virus creep.
  - *Enemies*: Shambling/running zombies.
  - *Civilians*: Survivors in ragged clothes.
  - *Bases*: Quarantine zones / makeshift bunkers.
- **Insurgency Theme**:
  - *Infection*: Rebel propaganda / militant territory takeover.
  - *Enemies*: Armed insurgents / terrorists.
  - *Civilians*: Hostages / local officials.
  - *Bases*: Tactical outposts / FOBs (Forward Operating Bases).

---

## 4. User Interface & Game Flow

### 4.1 UI Screens & Elements
1. **Main Menu**:
   - Start Game (Theme Selection: Zombies vs. Insurgency)
   - How to Play (Tutorial / Rules)
   - Stats / Leaderboards / High Scores
   - Terms & Conditions / Credits
   - Settings (Audio, Music Volume, Controls Info)
2. **HUD (Heads-Up Display)**:
   - Base Health (Main Base & Sub-bases health bars)
   - Ammo Counter & Weapon Status
   - Civilians Rescued / Remaining Counter
   - Wave / Infection Spread Meter
   - Pause Button
3. **Pause Menu**:
   - Resume
   - Restart
   - Settings
   - Quit to Main Menu
4. **Game Over / Victory Screens**:
   - Summary stats (Cells saved, enemies eliminated, time survived, score).

---

## 5. Controls (Keyboard & Mouse Independence)
The game is engineered to be fully playable with either keyboard alone, mouse alone, or combined:
- **Keyboard-Only Mode**:
  - Arrow Keys / WASD: Move protagonist.
  - Spacebar: Build / Repair wall.
  - Enter / J: Fire weapon / Attack.
  - Esc: Pause / Open Menu.
- **Mouse-Only Mode**:
  - Click grid cells to move protagonist or build walls.
  - Click UI buttons for actions, firing, and menu navigation.
- **Keyboard + Mouse (Hybrid)**:
  - WASD for movement, Mouse click for targeting and building.

---

## 6. Technical Architecture (Flutter Web & Android)

### 6.1 State Management & Game Loop
- **Game Engine / Loop**: Built using custom Flutter `StatefulWidget` with `Ticker` / `AnimationController` for a smooth 60 FPS tick-based simulation, or using a lightweight state management provider (Provider / Riverpod).
- **Data Models**:
  - `Cell`: coordinates $(x, y)$, health, type (Normal, Infected, Wall, Civilian, Base, SubBase), enclosure ID.
  - `Base`: health, maxHealth, isMain, position.
  - `Entity` (Protagonist, Enemy, Civilian): position, health, state.

### 6.2 Project Directory Structure Plan
```text
lib/
├── models/
│   ├── cell.dart
│   ├── base.dart
│   ├── entity.dart
│   └── game_state.dart
├── services/
│   ├── audio_service.dart
│   └── storage_service.dart
├── themes/
│   ├── game_theme.dart
│   ├── zombie_theme.dart
│   └── insurgency_theme.dart
├── ui/
│   ├── screens/
│   │   ├── main_menu_screen.dart
│   │   ├── game_screen.dart
│   │   ├── how_to_play_screen.dart
│   │   ├── stats_screen.dart
│   │   └── terms_screen.dart
│   └── widgets/
│       ├── game_grid_painter.dart
│       └── hud_overlay.dart
└── main.dart
```
