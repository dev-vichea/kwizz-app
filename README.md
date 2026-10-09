# Kwizz - Trivia & Quiz Flutter Application

**Kwizz** is a production-ready Flutter trivia quiz application inspired by modern playful gamification designs. It features real-time OpenTDB (The Trivia API) question fetching, Supabase cloud authentication, player profile synchronization, gems reward economy, and dynamic 3D podium leaderboards.

---

## Features & Highlights

- **Pixel-Accurate UI Design**: Replicated from design mockups featuring:
  - Custom Onboarding Flow with playful illustrations, speech bubbles, and step navigation.
  - Radiant Sunburst header effects and floating capsule navigation.
  - Interactive "Rise Up Quiz Champion" & "Upgrade Pro" banner rewards.
  - "Future of Tech" featured quiz card with vibrant rose gradients and 3D character art.
  - 3D Isometric Podium for 1st, 2nd, and 3rd place scorers (Mint Green, Pastel Yellow, Pink columns).
  - Ranked Leaderboard cards with real-time score indicators, rank trend indicators (▲ / ▼), and month selectors.
- **OpenTDB Integration**:
  - Live fetching from OpenTDB with dynamic query parameters (`amount`, `category`, `difficulty`, `type`).
  - Automatic HTML entity decoding (e.g., `&quot;`, `&#039;`, `&amp;`) via `html_unescape`.
  - Shuffled multi-choice options with zero bias.
  - Offline curated question fallback guaranteeing zero crashes even if the public API rate-limits.
- **Supabase Cloud Backend**:
  - Cloud database hosted on Supabase (`profiles` and `quiz_results` tables).
  - Row Level Security (RLS) policies configured for secure client access.
  - Real-time profile updates: tracks stars, total score, quizzes played, and global rankings.
  - Email/Password authentication & instant Guest Explorer play mode.
- **Quiz Gameplay Mechanics**:
  - 20-second per-question countdown timer with warning states.
  - Streak multipliers (`Streak bonus`) and speed point calculations.
  - In-game lifelines: `50:50` (eliminates 2 wrong answers), `+15s Extra Time`, and `Skip Question`.
  - Instant visual feedback on answer selection (emerald green for correct, soft crimson for incorrect).
- **Clean Architecture & State Management**:
  - MultiProvider state management (`AuthProvider`, `QuizProvider`, `LeaderboardProvider`).
  - Clean directory separation (`screens`, `widgets`, `models`, `services`, `providers`, `utils`, `config`, `theme`).

---

## Project Structure

```
lib/
├── config/
│   └── supabase_config.dart       # Supabase URL & publishable keys
├── models/
│   ├── category_model.dart        # Quiz categories mapped to OpenTDB IDs
│   ├── question_model.dart        # Question parser & HTML entity unescaping
│   ├── quiz_result_model.dart     # Result record schema for Supabase
│   └── user_profile_model.dart    # User profile model & rank serialization
├── services/
│   ├── opentdb_service.dart       # HTTP client for OpenTDB & offline fallback
│   ├── supabase_service.dart      # Supabase Auth, Profiles & Results API
│   └── storage_service.dart       # Local persistence via SharedPreferences
├── providers/
│   ├── auth_provider.dart         # Authentication & player profile state
│   ├── quiz_provider.dart         # Quiz loop, timer, lifelines & score calculation
│   └── leaderboard_provider.dart  # Ranking calculations & podium state
├── theme/
│   └── app_theme.dart             # Plus Jakarta Sans typography & design tokens
├── utils/
│   └── avatar_helper.dart         # 3D avatar color schemes and styling
├── widgets/
│   ├── avatar_circle.dart         # Vector-rendered 3D character avatar
│   ├── custom_bottom_nav.dart     # Floating rounded bottom navigation bar
│   ├── illustrations.dart         # 3D Trophy, Crown, VR Character, Lightbulb & Book
│   ├── podium_widget.dart         # 3D Isometric podium for top 3 champions
│   └── sunburst_background.dart   # Radiant sunburst rays custom painter
├── screens/
│   ├── onboarding_screen.dart     # Brand intro with illustrations & CTA
│   ├── main_nav_screen.dart       # Bottom navigation container
│   ├── home_screen.dart           # Home dashboard matching screenshot 3
│   ├── quiz_explore_screen.dart   # Quiz builder with difficulty & categories
│   ├── quiz_play_screen.dart      # Active question screen with timer & lifelines
│   ├── quiz_result_screen.dart    # Result celebration with gems & score metrics
│   ├── leaderboard_screen.dart    # Podium & global rankings matching screenshot 4
│   ├── profile_screen.dart        # User profile, 3D avatar picker & history
│   └── auth_screen.dart           # Email/Password sign-in & register
└── main.dart                      # App entry point, MultiProvider & initialization
```

---

## Supabase Database Schema

The database is configured with the following tables:

### 1. `public.profiles`
```sql
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY,
    username TEXT NOT NULL,
    full_name TEXT,
    avatar_url TEXT,
    title TEXT DEFAULT 'Student',
    gems INTEGER DEFAULT 30,
    total_score INTEGER DEFAULT 0,
    quizzes_played INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 2. `public.quiz_results`
```sql
CREATE TABLE public.quiz_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID,
    username TEXT NOT NULL,
    category TEXT NOT NULL,
    difficulty TEXT NOT NULL,
    score INTEGER NOT NULL DEFAULT 0,
    total_questions INTEGER NOT NULL DEFAULT 10,
    correct_answers INTEGER NOT NULL DEFAULT 0,
    gems_earned INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 3. Row Level Security Policies
- Enabled RLS on `profiles` and `quiz_results`.
- Public `SELECT` allowed for reading global leaderboards and player profiles.
- Authenticated and anonymous `INSERT` and `UPDATE` allowed for saving quiz progress and profile customizations.

---

## Running the Application

### Prerequisites
- Flutter SDK 3.10+ (tested on Flutter 3.38.4 / Dart 3.10.3)
- Xcode (for iOS / macOS) or Android Studio (for Android)

### Run on iOS Simulator or Device
```bash
cd kwizz
flutter run -d "iPhone 17"
```

### Run on macOS Desktop
```bash
cd kwizz
flutter run -d macos
```

### Run on Google Chrome
```bash
cd kwizz
flutter run -d chrome
```

### Run Tests
```bash
cd kwizz
flutter test
```
All unit tests and widget tests run and pass cleanly.
# kwizz-app
