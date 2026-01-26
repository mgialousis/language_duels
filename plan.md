# Language Duel — Project Plan (Single-Phone MVP)

## 📌 Project Summary

**App Name:** Language Duel  
**Mode:** Single-phone, turn-based hot-seat game  
**POC Languages:** Greek ↔ Catalan  
**Level Target:** Beginner A1 (later A2)  
**Tech Stack:**  
- Flutter (Android & iOS)  
- Local storage (Hive/Isar/JSON)  
- Local gameplay only (no backend) for MVP

**Vision:**  
Create a fun, competitive language game where two users share one device and take alternate turns answering mini-game questions to learn each other’s language.

---

## 🎯 Goals for MVP

1. Local hot-seat gameplay with two players sharing one phone  
2. At least 2 mini-games:
   - Vocab Flash Duel  
   - Phrase Builder (Reorder)  
3. Content for Greek ↔ Catalan, A1, one theme (Greetings)  
4. Core UI flows: setup, gameplay, results  
5. Base architecture ready for future online play

---

## 🧠 Features

### 💡 Gameplay
- Local Duel (hot-seat)
- Optional Solo Practice
- Fixed number of rounds
- Turn indicator
- Scoreboard and winner display

### 🎮 Mini-Games (MVP)
1. **Vocab Flash Duel**  
2. **Phrase Builder (Reorder)**

### 📚 Content
- Deck: “Greetings”
- ~30 items (vocab & short phrases)
- Greek & Catalan paired data

### 📌 Persistence
- Local JSON or Hive database to store:
  - Content items
  - Settings
  - Match history (optional)

---

## 📦 Architecture

### 📁 Data Layers
- Models: Language, Deck, ContentItem, LocalizedString
- Repositories: Load local content
- Game Controller: Manages turns, rounds, scoring

### 📱 UI
Screens:
- Home
- Player Setup
- Deck Selection
- Gameplay (round + question)
- Results

### 🧩 State Mgmt
- Riverpod (recommended)

---

## 🗂 Developer Tasks (Summary)

### ☑ Setup
- Initialize Flutter project
- Add state management
- Add local DB (Hive/Isar)

### ☑ Content
- Create local JSON with Greek‐Catalan deck

### ☑ UI
- Home → Setup → Deck select → Gameplay → Results

### ☑ Mini-Games
- Build two mini-games
- Test hot-seat sequencing

### ☑ Misc
- Local persistence
- Settings (theme/language)

---

## 🧾 Success Criteria (MVP)

- Players can complete a duel on one device  
- Score and winner determination works correctly  
- UI is clear and usable without errors  
- Core mini-games feel fun and responsive

---

## 🚀 Future (Post-MVP)

- Async and online competitive modes  
- More languages (expand beyond Greek/Catalan)  
- More themes & mini-games  
- Voice & audio support
