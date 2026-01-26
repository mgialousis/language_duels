# Language Duel - Expansion & Improvement Roadmap

**Version:** 1.0
**Created:** 2026-01-27
**Status:** Planning
**Baseline:** MVP Complete (7 decks, 2 mini-games, hot-seat mode, Greek ↔ Catalan)

---

## Executive Summary

This roadmap outlines the strategic expansion of Language Duel from a local hot-seat MVP to a full-featured competitive language learning platform. The plan is organized into 7 phases, prioritizing user value, technical feasibility, and sustainable growth.

**Current State (MVP):**
- 2 mini-games (Vocab Flash, Phrase Builder)
- 7 content decks (A1-A2 level)
- Hot-seat multiplayer on single device
- Greek ↔ Catalan language pair
- Local storage with match history

**Target State (Full Product):**
- 6+ mini-games with varied mechanics
- 20+ content decks across A1-B2 levels
- Online real-time and async multiplayer
- 10+ language pairs
- Audio/pronunciation support
- Solo learning mode with spaced repetition
- Social features and leaderboards

---

## Phase Overview

| Phase | Name | Duration | Priority | Dependencies |
|-------|------|----------|----------|--------------|
| 1 | Polish & Analytics | 1-2 weeks | P0 | MVP complete |
| 2 | Solo Mode & Learning | 2-4 weeks | P0 | Phase 1 |
| 3 | New Mini-Games | 3-4 weeks | P1 | Phase 1 |
| 4 | Audio & Pronunciation | 2-3 weeks | P1 | Phase 1 |
| 5 | Online Multiplayer | 4-6 weeks | P1 | Phase 2 |
| 6 | Language Expansion | Ongoing | P2 | Phase 1 |
| 7 | Monetization & Growth | Ongoing | P2 | Phase 5 |

---

## Phase 1: Polish & Analytics (1-2 weeks)

### 1.1 Objectives
- Address bugs and UX issues discovered during MVP testing
- Implement analytics to understand user behavior
- Optimize performance for lower-end devices
- Prepare app store assets for launch

### 1.2 Bug Fixes & UX Refinements

| Area | Issue/Improvement | Priority |
|------|-------------------|----------|
| Turn Transition | Ensure answer is fully hidden before transition completes | P0 |
| Timer | Verify timer accuracy under app backgrounding | P0 |
| Phrase Builder | Improve drag-drop responsiveness on slower devices | P1 |
| Results Screen | Add sharing capability (screenshot/text) | P1 |
| Settings | Add "Reset all data" option | P2 |
| Accessibility | Verify screen reader compatibility on all screens | P1 |
| Onboarding | Add optional tutorial/how-to-play flow | P1 |

### 1.3 Analytics Integration

**Recommended: Firebase Analytics (free tier)**

Events to track:
```
- app_open
- duel_started (deck_id, player_count)
- duel_completed (winner, score_diff, duration_seconds)
- mini_game_completed (game_type, player, score, accuracy)
- deck_selected (deck_id)
- settings_changed (setting_name, value)
- error_occurred (error_type, screen)
```

User properties:
```
- total_duels_played
- favorite_deck
- preferred_theme
- days_since_first_launch
```

### 1.4 Performance Optimization

| Target | Metric | Current | Goal |
|--------|--------|---------|------|
| Cold start | Time to interactive | TBD | < 2s |
| Screen transitions | Frame drops | TBD | 0 |
| Memory usage | Peak MB | TBD | < 150MB |
| APK size | Download size | TBD | < 20MB |

### 1.5 App Store Preparation

**Android (Google Play):**
- [ ] App icon (512x512)
- [ ] Feature graphic (1024x500)
- [ ] Screenshots (phone + tablet)
- [ ] Short description (80 chars)
- [ ] Full description (4000 chars)
- [ ] Privacy policy URL
- [ ] Content rating questionnaire

**iOS (App Store):**
- [ ] App icon (1024x1024)
- [ ] Screenshots (6.7", 6.5", 5.5")
- [ ] App preview video (optional)
- [ ] Description and keywords
- [ ] Privacy policy and data usage

### 1.6 Deliverables
- [ ] Bug-free release build
- [ ] Analytics dashboard configured
- [ ] Performance benchmarks documented
- [ ] App store listings prepared

---

## Phase 2: Solo Mode & Learning Features (2-4 weeks)

### 2.1 Objectives
- Enable single-player practice mode
- Implement spaced repetition for effective learning
- Track individual progress across sessions
- Identify and target weak vocabulary

### 2.2 Solo Practice Mode

**User Story:** "As a learner, I want to practice vocabulary alone so I can improve before challenging a friend."

**Features:**
- Practice any deck without opponent
- No time pressure option (relaxed mode)
- Immediate feedback with explanations
- Session summary with accuracy stats

**UI Changes:**
- Home screen: Add "Solo Practice" button
- New screen: Solo deck selection (same as duel, different flow)
- New screen: Solo practice gameplay (no turn transitions)
- New screen: Solo session summary

### 2.3 Spaced Repetition System (SRS)

**Algorithm:** Modified SM-2 (SuperMemo 2)

```dart
class SRSItem {
  final String itemId;
  final int repetitions;      // Times reviewed correctly in a row
  final double easeFactor;    // 1.3 - 2.5, default 2.5
  final int interval;         // Days until next review
  final DateTime nextReview;
  final DateTime lastReview;
}

// After each review:
if (correct) {
  if (repetitions == 0) interval = 1;
  else if (repetitions == 1) interval = 6;
  else interval = (interval * easeFactor).round();

  repetitions++;
  easeFactor = max(1.3, easeFactor + (0.1 - (5 - quality) * 0.08));
} else {
  repetitions = 0;
  interval = 1;
}
```

**Data Model:**
```dart
class LearnerProfile {
  final String oderId;
  final Map<String, SRSItem> itemProgress;  // itemId -> SRS state
  final Map<String, DeckProgress> deckProgress;
  final List<String> weakItems;  // Items with low ease factor
  final int totalReviews;
  final int streak;  // Consecutive days practiced
}
```

### 2.4 Progress Tracking

**Metrics per learner:**
- Overall vocabulary mastery (% of items at interval > 21 days)
- Per-deck progress (% mastered, % learning, % new)
- Daily review count
- Streak (consecutive days)
- Accuracy trend (last 7/30 days)

**UI: Progress Dashboard**
```
┌─────────────────────────────────────┐
│  Your Progress                       │
├─────────────────────────────────────┤
│  [====------] 42% Mastered          │
│                                      │
│  🔥 7-day streak                     │
│  📚 156 words reviewed               │
│  ✅ 78% accuracy (7d avg)            │
│                                      │
│  ┌─────────────────────────────┐    │
│  │ Greetings     [████████░░]  │    │
│  │ Colors        [██████░░░░]  │    │
│  │ Numbers       [████░░░░░░]  │    │
│  └─────────────────────────────┘    │
│                                      │
│  [Review Weak Words] (12 due)       │
└─────────────────────────────────────┘
```

### 2.5 Weak Words Review

**Identification criteria:**
- Ease factor < 1.8
- Answered incorrectly 2+ times recently
- Not reviewed in 14+ days

**Feature:**
- Dedicated "Review Weak Words" mode
- Pulls items across all decks
- Focuses only on struggling vocabulary
- Extra feedback with mnemonics/tips (future)

### 2.6 Data Storage Updates

**New Hive boxes:**
```dart
// Learner profile storage
@HiveType(typeId: 10)
class LearnerProfileAdapter { ... }

// SRS item storage
@HiveType(typeId: 11)
class SRSItemAdapter { ... }
```

### 2.7 Deliverables
- [ ] Solo practice mode functional
- [ ] SRS algorithm implemented and tested
- [ ] Progress dashboard screen
- [ ] Weak words review mode
- [ ] Data migration for existing users (empty profile)

---

## Phase 3: New Mini-Games (3-4 weeks)

### 3.1 Objectives
- Add variety to gameplay with 4 new mini-games
- Cover different learning modalities (visual, auditory, active recall)
- Maintain consistent scoring across games
- Keep games fun and competitive

### 3.2 Mini-Game: Listening Challenge

**Concept:** Hear a word/phrase, select the correct written form.

**Mechanics:**
- Audio plays automatically (TTS or recorded)
- 4 written options displayed
- 10-second timer
- Can replay audio once (costs 2 points)

**Scoring:**
- Correct: 10 points + speed bonus (same as Vocab Flash)
- Replay penalty: -2 points

**Requirements:**
- Text-to-speech integration (see Phase 4)
- Audio playback controls

**Difficulty variants:**
- A1: Single words, clear pronunciation
- A2: Short phrases, natural speed
- B1: Longer phrases, faster speech

### 3.3 Mini-Game: Spelling Bee

**Concept:** See/hear a word in source language, type the translation.

**Mechanics:**
- Source word displayed (with audio option)
- On-screen keyboard or device keyboard
- Letter-by-letter feedback (optional)
- 20-second timer

**Scoring:**
- Perfect spelling: 15 points + speed bonus
- Minor errors (1-2 chars): 8 points (shows correction)
- Major errors: 0 points

**Error tolerance:**
- Ignore accents for partial credit
- Allow common misspellings as "close enough" feedback

### 3.4 Mini-Game: Speed Round

**Concept:** Rapid-fire true/false questions.

**Mechanics:**
- "Is [word] = [translation]?" (50% true, 50% false)
- 5-second per question
- 10 questions per round
- No answer review between questions

**Scoring:**
- Correct: 5 points
- Wrong: 0 points
- No speed bonus (already time-pressured)
- Max 50 points per round

**Design notes:**
- False translations should be plausible (semantic siblings)
- Keep pacing intense and fun

### 3.5 Mini-Game: Match Madness

**Concept:** Connect pairs of words (source-target) before time runs out.

**Mechanics:**
- 6 source words on left, 6 target translations on right (shuffled)
- Tap source, then tap matching target
- Correct match: both disappear
- Wrong match: brief shake, try again
- 45-second timer for all 6 pairs

**Scoring:**
- Base: 3 points per correct match (18 max)
- Time bonus: +1 point per 5 seconds remaining
- Max ~27 points per round

### 3.6 Mini-Game Selection Strategy

**Duel mode:**
- Currently: Vocab Flash (5Q) → Phrase Builder (3P)
- Expanded: Player chooses 2 of 6 mini-games before duel starts
- Or: Random selection from pool

**Solo mode:**
- Practice any individual mini-game
- Suggested: SRS-driven game selection

### 3.7 Implementation Order

| Order | Game | Complexity | Dependencies |
|-------|------|------------|--------------|
| 1 | Speed Round | Low | None |
| 2 | Match Madness | Medium | None |
| 3 | Listening Challenge | Medium | Phase 4 (audio) |
| 4 | Spelling Bee | Medium | Keyboard handling |

### 3.8 Deliverables
- [ ] Speed Round mini-game
- [ ] Match Madness mini-game
- [ ] Listening Challenge mini-game (after Phase 4)
- [ ] Spelling Bee mini-game
- [ ] Game selection UI for duels
- [ ] Updated scoring documentation

---

## Phase 4: Audio & Pronunciation (2-3 weeks)

### 4.1 Objectives
- Add text-to-speech for vocabulary pronunciation
- Enable audio-based learning and mini-games
- Provide pronunciation guides and tips
- Support future voice input features

### 4.2 Text-to-Speech Integration

**Recommended package:** `flutter_tts` (cross-platform, free)

**Implementation:**
```dart
class AudioService {
  final FlutterTts _tts = FlutterTts();

  Future<void> init() async {
    await _tts.setSharedInstance(true);
    await _tts.setSpeechRate(0.45);  // Slower for learners
  }

  Future<void> speak(String text, String languageCode) async {
    await _tts.setLanguage(_mapLanguage(languageCode));
    await _tts.speak(text);
  }

  String _mapLanguage(String code) {
    return switch (code) {
      'el' => 'el-GR',  // Greek
      'ca' => 'ca-ES',  // Catalan
      _ => 'en-US',
    };
  }
}
```

**Challenges:**
- Catalan TTS support varies by device
- Greek TTS quality varies
- Fallback: Use phonetic hints if TTS unavailable

### 4.3 Audio UI Components

**SpeakerButton widget:**
```dart
class SpeakerButton extends StatelessWidget {
  final String text;
  final String languageCode;
  final double size;

  // Tapping plays audio, shows brief animation
}
```

**Integration points:**
- Flash card: Speaker icon next to source word
- Phrase Builder: Speaker icon for full phrase
- Answer feedback: Auto-play correct answer (optional setting)
- Solo mode: Always available

### 4.4 Pronunciation Guide Enhancement

**Current:** Phonetic hints in content JSON

**Enhanced:**
- Visual syllable breakdown
- Stress markers (bold or underline)
- IPA toggle for advanced learners
- Audio slow mode (0.3x speed)

### 4.5 Audio Settings

```dart
class AudioSettings {
  bool ttsEnabled;           // Master toggle
  bool autoPlayOnReveal;     // Play correct answer automatically
  double speechRate;         // 0.3 - 1.0 (default 0.45)
  bool slowModeAvailable;    // Show slow playback option
}
```

### 4.6 Deliverables
- [ ] AudioService with TTS integration
- [ ] SpeakerButton widget
- [ ] Audio settings UI
- [ ] Flash card audio integration
- [ ] Listening Challenge mini-game enabled
- [ ] Fallback handling for unsupported languages

---

## Phase 5: Online Multiplayer (4-6 weeks)

### 5.1 Objectives
- Enable real-time duels between remote players
- Support asynchronous challenge mode
- Implement friend system and matchmaking
- Build scalable backend infrastructure

### 5.2 Architecture Decision

**Recommended:** Firebase (Firestore + Cloud Functions + Authentication)

**Rationale:**
- Free tier sufficient for launch
- Real-time sync built-in
- No server management
- Easy authentication (Google, Apple, anonymous)
- Scales automatically

**Alternative:** Supabase (PostgreSQL + real-time + auth)
- Open source, self-hostable
- Better for complex queries
- Requires more setup

### 5.3 Backend Data Model

```
users/
  {userId}/
    displayName: string
    avatarUrl: string
    createdAt: timestamp
    stats: {
      totalDuels: number
      wins: number
      losses: number
      draws: number
      rating: number  // ELO-style
    }

matches/
  {matchId}/
    status: 'waiting' | 'active' | 'completed'
    mode: 'realtime' | 'async'
    createdAt: timestamp
    players: [userId, userId]
    deckId: string
    currentTurn: userId
    rounds: [{
      gameType: string
      player1Score: number
      player2Score: number
    }]
    winner: userId | null

challenges/
  {challengeId}/
    from: userId
    to: userId
    status: 'pending' | 'accepted' | 'declined' | 'expired'
    deckId: string
    createdAt: timestamp
    expiresAt: timestamp

friends/
  {userId}/
    friends: [userId]
    pending: [userId]
    blocked: [userId]
```

### 5.4 Real-Time Duel Flow

```
1. Player A creates match (status: 'waiting')
2. Matchmaking finds Player B (or friend invite)
3. Both players join, match status: 'active'
4. Firestore listeners sync game state
5. Turn-based: each player submits answers
6. Server validates and updates scores
7. Match ends, status: 'completed', winner set
8. Stats updated for both players
```

**Latency handling:**
- Optimistic UI updates
- Server reconciliation
- Timeout for unresponsive players (30s)

### 5.5 Async Challenge Mode

**User Story:** "I want to challenge a friend who's not online right now."

**Flow:**
1. Player A completes their half of duel
2. Challenge sent to Player B (push notification)
3. Player B has 24 hours to respond
4. Player B completes their half
5. Results revealed to both

**Benefits:**
- No need for simultaneous availability
- Works across time zones
- Less pressure, more thoughtful play

### 5.6 Authentication

**Supported methods:**
- Anonymous (try before signup)
- Google Sign-In
- Apple Sign-In (required for iOS)
- Email/password (optional)

**Account linking:** Anonymous → full account preserves data

### 5.7 Matchmaking

**Quick Match:**
- Find opponent with similar rating (ELO ±200)
- Timeout after 30s → expand range or offer bot

**Friend Challenge:**
- Select from friends list
- Send invite with deck selection
- Push notification to friend

**Rating System (ELO):**
```dart
int calculateNewRating(int myRating, int oppRating, double score) {
  const k = 32;
  double expected = 1 / (1 + pow(10, (oppRating - myRating) / 400));
  return (myRating + k * (score - expected)).round();
}
// score: 1.0 = win, 0.5 = draw, 0.0 = loss
```

### 5.8 Security Rules (Firestore)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    match /matches/{matchId} {
      allow read: if request.auth.uid in resource.data.players;
      allow create: if request.auth != null;
      allow update: if request.auth.uid in resource.data.players;
    }
  }
}
```

### 5.9 Offline Handling

- Queue actions when offline
- Sync when connection restored
- Show offline indicator
- Disable online features gracefully

### 5.10 Deliverables
- [ ] Firebase project setup
- [ ] Authentication flow (anonymous, Google, Apple)
- [ ] User profile screen
- [ ] Real-time duel implementation
- [ ] Async challenge mode
- [ ] Friends list and invites
- [ ] Matchmaking system
- [ ] Leaderboard screen
- [ ] Push notifications

---

## Phase 6: Language Expansion (Ongoing)

### 6.1 Objectives
- Support additional language pairs
- Build scalable content pipeline
- Enable community contributions
- Maintain quality across languages

### 6.2 Priority Language Pairs

**Tier 1 (High demand, good TTS support):**
| Source | Target | Rationale |
|--------|--------|-----------|
| English | Spanish | Largest learner population |
| English | French | Global demand |
| Spanish | English | Large market |
| English | German | Business demand |

**Tier 2 (Medium demand):**
| Source | Target | Rationale |
|--------|--------|-----------|
| English | Italian | Tourism, culture |
| English | Portuguese | Brazil market |
| English | Japanese | Pop culture appeal |
| English | Korean | K-pop, K-drama fans |

**Tier 3 (Niche/regional):**
- Greek ↔ Catalan (current)
- Regional European pairs
- Heritage language pairs

### 6.3 Content Pipeline

**Per language pair, per deck:**
1. **Source creation** (native speaker)
   - Vocabulary selection (frequency lists)
   - Phrase creation
   - Cultural notes

2. **Translation** (native speaker of target)
   - Accurate translations
   - Natural phrasing
   - Regional variants noted

3. **Phonetic annotation**
   - Romanization (if applicable)
   - Phonetic hints
   - IPA (optional)

4. **Quality review**
   - A1/A2 level verification
   - Gameplay testing
   - Distractor validation

5. **Technical validation**
   - JSON schema compliance
   - Character encoding
   - TTS compatibility

### 6.4 Content Management System (Future)

**Web-based CMS for content creators:**
- Deck creation wizard
- Translation interface (side-by-side)
- Preview in-app
- Publish workflow with approval
- Version control

### 6.5 Community Contributions

**Model:** Curated user submissions

**Flow:**
1. User submits deck via CMS
2. Review by language expert
3. Testing by beta users
4. Publication with attribution

**Quality control:**
- Native speaker requirement
- Plagiarism check
- Gameplay balance review

### 6.6 Localization

**App UI localization:**
- English (default)
- Spanish
- French
- German
- Add languages based on user base

**Content metadata localization:**
- Deck names in user's language
- Category names
- Help text

### 6.7 Deliverables
- [ ] Language pair selection UI
- [ ] Content pipeline documentation
- [ ] 2+ new language pairs (Tier 1)
- [ ] Localized app UI (2+ languages)
- [ ] Contributor guidelines

---

## Phase 7: Monetization & Growth (Ongoing)

### 7.1 Objectives
- Establish sustainable revenue model
- Maintain free core experience
- Drive user acquisition and retention
- Build community and brand

### 7.2 Monetization Strategy

**Freemium model:**

| Feature | Free | Premium |
|---------|------|---------|
| Hot-seat duels | ✅ | ✅ |
| Solo practice | ✅ Limited | ✅ Unlimited |
| A1 decks | ✅ All | ✅ All |
| A2+ decks | ❌ | ✅ All |
| Online duels | ✅ 3/day | ✅ Unlimited |
| SRS review | ✅ 20 items/day | ✅ Unlimited |
| Ad-free | ❌ | ✅ |
| Offline mode | ❌ | ✅ |
| Statistics | Basic | Advanced |

**Pricing:**
- Monthly: $4.99/month
- Annual: $29.99/year (50% savings)
- Lifetime: $79.99 (one-time)

### 7.3 Alternative Revenue Streams

**Deck packs (one-time purchase):**
- Business vocabulary pack: $2.99
- Travel pack (5 decks): $4.99
- Complete A2 bundle: $9.99

**Cosmetics (optional):**
- Avatar customization
- Victory animations
- Profile badges

**Ads (free tier only):**
- Interstitial after every 3 duels
- Banner on results screen
- Rewarded video for hints

### 7.4 Growth Strategy

**Acquisition channels:**
1. **App Store Optimization (ASO)**
   - Keywords: "language learning", "language game", "learn Spanish"
   - Screenshots showing gameplay
   - Video preview

2. **Social sharing**
   - Share duel results to social media
   - Challenge friends via link
   - Referral rewards

3. **Content marketing**
   - Blog: language learning tips
   - YouTube: gameplay videos
   - TikTok: quick learning clips

4. **Influencer partnerships**
   - Language learning YouTubers
   - Polyglot community
   - Education reviewers

5. **Cross-promotion**
   - Partner with language schools
   - Educational app bundles

### 7.5 Retention Strategy

**Daily engagement:**
- Daily review reminder (push notification)
- Streak maintenance rewards
- Daily challenge (new vocabulary)

**Weekly engagement:**
- Weekly leaderboard reset
- New content drops
- Friend activity digest

**Long-term engagement:**
- Achievement system
- Level progression
- Seasonal events

### 7.6 Metrics to Track

**Acquisition:**
- Downloads (daily, weekly, monthly)
- Install source attribution
- Cost per install (if paid)

**Activation:**
- First duel completion rate
- Day 1 retention
- Tutorial completion

**Retention:**
- Day 7, Day 30 retention
- Monthly active users (MAU)
- Daily active users (DAU)
- DAU/MAU ratio

**Revenue:**
- Monthly recurring revenue (MRR)
- Average revenue per user (ARPU)
- Conversion rate (free → paid)
- Lifetime value (LTV)

**Engagement:**
- Duels per user per day
- Session duration
- Vocabulary mastery rate

### 7.7 Deliverables
- [ ] Payment integration (RevenueCat recommended)
- [ ] Premium feature gates
- [ ] Ad integration (AdMob)
- [ ] Referral system
- [ ] Achievement system
- [ ] Analytics dashboard

---

## Implementation Timeline

```
Month 1-2:   Phase 1 (Polish) + Phase 2 (Solo Mode)
Month 2-3:   Phase 3 (New Mini-Games) + Phase 4 (Audio)
Month 4-5:   Phase 5 (Online Multiplayer)
Month 6+:    Phase 6 (Languages) + Phase 7 (Monetization)
```

**Recommended team scaling:**
- Month 1-3: 1-2 developers
- Month 4-6: 2-3 developers + 1 content creator
- Month 7+: 3+ developers + content team + marketing

---

## Technical Debt & Maintenance

### Ongoing Considerations

1. **Dependency updates** — Monthly review of pub.dev updates
2. **Flutter upgrades** — Test on new Flutter stable releases
3. **Platform changes** — iOS/Android policy compliance
4. **Content freshness** — Regular deck updates and corrections
5. **Bug triage** — Weekly review of crash reports and feedback
6. **Performance monitoring** — Monthly benchmarks

### Code Quality

- Maintain test coverage > 70%
- Document public APIs
- Review PR size (< 500 lines)
- Refactor as complexity grows

---

## Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| TTS quality issues | Medium | Medium | Fallback to phonetic hints |
| Online play complexity | High | High | Start with async mode |
| Content quality at scale | Medium | High | Strict review process |
| Low user acquisition | Medium | High | Focus on organic/ASO first |
| Firebase costs scaling | Low | Medium | Monitor usage, optimize queries |
| Competitor launches | Medium | Medium | Differentiate on fun factor |

---

## Success Metrics

**Phase 1-2 (3 months):**
- 1,000+ downloads
- 4.0+ app store rating
- 20% Day-7 retention

**Phase 3-5 (6 months):**
- 10,000+ downloads
- 500+ DAU
- 5% premium conversion

**Phase 6-7 (12 months):**
- 50,000+ downloads
- 2,000+ DAU
- $5,000+ MRR

---

## Appendix A: Mini-Game Comparison Matrix

| Game | Type | Timer | Max Points | Skills Tested |
|------|------|-------|------------|---------------|
| Vocab Flash | Recognition | 10s | 75 | Vocabulary recall |
| Phrase Builder | Construction | 30s | 75 | Word order, grammar |
| Speed Round | Recognition | 5s×10 | 50 | Quick recall |
| Match Madness | Association | 45s | ~27 | Pairing, memory |
| Listening | Comprehension | 10s | 75 | Listening, reading |
| Spelling Bee | Production | 20s | ~75 | Spelling, recall |

---

## Appendix B: Content Deck Roadmap

| Deck | Level | Status | Phase |
|------|-------|--------|-------|
| Greetings | A1 | ✅ Done | MVP |
| Numbers | A1 | ✅ Done | MVP |
| Colors | A1 | ✅ Done | MVP |
| Family | A1 | ✅ Done | MVP |
| Travel Basics | A1 | ✅ Done | MVP |
| Travel Instructions | A2 | ✅ Done | MVP |
| House & Cleaning | A2 | ✅ Done | MVP |
| Food & Drink | A1 | Planned | Phase 6 |
| Time & Calendar | A1 | Planned | Phase 6 |
| Weather | A1 | Planned | Phase 6 |
| Shopping | A2 | Planned | Phase 6 |
| Health | A2 | Planned | Phase 6 |
| Work & Business | B1 | Planned | Phase 6 |
| Technology | B1 | Planned | Phase 6 |

---

*This roadmap is a living document. Review and update quarterly based on user feedback, market conditions, and technical learnings.*
