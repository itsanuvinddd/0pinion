# 0pinion Project Tracker

This file tracks the implementation progress of **0pinion**, a monochrome, text-first mobile debate platform built with Flutter, Riverpod, Supabase, and PostgreSQL.

---

## Overall Progress Summary

- **Phase 1: UI & UX Design (Stitch)**: 100% Complete (17/17 screens designed)
- **Phase 2: Project Setup & Infrastructure**: 100% Complete
- **Phase 3: Database & Backend (Supabase/PostgreSQL)**: 0% Complete
- **Phase 4: Core Features (Authentication, Profiles, Feed)**: 70% Complete (UI done, backend pending)
- **Phase 5: Interactive Features (Debates, Zeroes, Cooking)**: 70% Complete (UI done, backend pending)
- **Phase 6: Live Rooms (Realtime Text)**: 50% Complete (UI done, realtime pending)
- **Phase 7: Notifications & Moderation**: 10% Complete (Report UI done, FCM/moderation pending)
- **Phase 8: Polish, Testing & Deployment**: 10% Complete (flutter analyze clean)

---

## Detailed Task Checklist

### Phase 1: UI & UX Design (Stitch)
*Goal: Design the screen states, typography, layouts, and components in light/dark monochrome style.*
- [x] Create project design system on Stitch (`assets/13244779772264007188`)
- [x] Design Onboarding Flow:
  - [x] **Splash Screen** (`86c923624a21413ea6c5681cb96c10ea`)
  - [x] **Sign Up Screen** (`ea32217f0fe0468caf5c6a2073d5683d`)
  - [x] **Username Setup Screen** (`9d6d1f73e30d4419812043713fa58bf5`)
  - [x] **Select Zeroes Screen** (`77b52816415843408158908324a1abd7`)
  - [x] **Welcome Screen** (`33f4c566a5c24749ba1188b08315b159`)
- [x] Design Main App Screens:
  - [x] **Home Feed** (`208ed311707045248d4b4344510df3fd`)
  - [x] **Search** (`14333c7a75614018abb0243d247fd003`)
  - [x] **Create Opinion** (`f1544b732549478293d5e171eff9d0b1`)
  - [x] **Live Rooms** (`58a687fbc1444db8befca58229d54733`)
  - [x] **Profile Screen**
- [x] Design Detail & Flow Screens:
  - [x] **Opinion Detail Screen**
  - [x] **Debate View (Support/Oppose/Question Tabs)**
  - [x] **Write Argument Screen**
  - [x] **Browse Zeroes Screen**
  - [x] **Cooking Feed Screen**
  - [x] **Live Room Chat Screen**
  - [x] **Report Flow Modal**
- [ ] Create Dark Mode variants in Stitch

---

### Phase 2: Project Setup & Infrastructure
*Goal: Initialize the codebase, install libraries, and set up state management and local storage structure.*
- [x] Initialize Flutter Mobile Application (`0pinion_app`)
- [x] Define folder structure (feature-first approach: `features/auth`, `features/feed`, etc.)
- [x] Configure pubspec.yaml with all dependencies (Riverpod, GoRouter, Supabase, Dio, Hive, Google Fonts, etc.)
- [x] Set up Design System (`app_colors.dart`, `app_typography.dart`, `app_theme.dart`)
- [x] Set up GoRouter with ShellRoute for bottom navigation
- [x] Create data models (Opinion, Argument, Zero, UserProfile, LiveRoom, ChatMessage)
- [x] Create mock data for development
- [x] Build shared widgets (OpinionCard, ZeroChip, PrimaryButton, AvatarWidget, CustomNavigationDock)
- [x] Flutter analyze — 0 issues
- [ ] Configure Riverpod providers for state management
- [ ] Integrate Dio networking package:
  - [ ] Set up interceptors for Supabase authentication headers
  - [ ] Configure base URL and request timeout limits
- [ ] Setup Local Storage:
  - [ ] Hive for caching feed data, reading history, and joined Zeroes
  - [ ] Flutter Secure Storage for tokens and secrets
- [ ] Configure Sentry for error tracking and crash reporting

---

### Phase 3: Database & Backend (Supabase/PostgreSQL)
*Goal: Set up database tables, constraints, functions, security rules (RLS), and Edge Functions.*
- [ ] Schema Creation:
  - [ ] `profiles` (username, display_name, avatar_pattern, reputation_score)
  - [ ] `zeroes` (name, display_name, description, opinions_count)
  - [ ] `zero_members` (user_id, zero_id)
  - [ ] `opinions` (title, content, author_id, is_anonymous, created_at)
  - [ ] `opinion_zeroes` (opinion_id, zero_id)
  - [ ] `arguments` (opinion_id, author_id, type: support/oppose/question, content, is_anonymous, created_at)
  - [ ] `argument_replies` (argument_id, author_id, content, created_at)
  - [ ] `reports` (reporter_id, content_type, content_id, reason, details)
  - [ ] `live_rooms` (title, host_id, active_participants_count, created_at)
- [ ] Row-Level Security (RLS):
  - [ ] Configure read permissions for opinions, arguments, zeroes
  - [ ] Configure write permissions (anonymous features must secure creator identity)
- [ ] PostgreSQL Triggers & Functions:
  - [x] Trigger to update reputation scores based on votes/arguments
  - [ ] Trigger to increment/decrement `opinions_count` on Zeroes
  - [ ] Function to compute "Cooking" feed trending score

---

### Phase 4: Core Features (Auth, Profile, Feed)
*Goal: Implement authentication screens, profile settings, and feed listings.*
- [x] Screen UI:
  - [x] Splash Screen with animations
  - [x] Sign Up Screen with email/password + Google auth
  - [x] Username Setup Screen with avatar generator
  - [x] Home Feed with For You / Cooking / Latest tabs
  - [x] Profile Screen with reputation, stats, and tabbed content
- [ ] Backend Integration:
  - [ ] Email Sign Up / Sign In with Supabase Auth
  - [ ] Google Sign-In authentication flow
  - [ ] Username availability check
  - [ ] Feed pagination with Supabase queries

---

### Phase 5: Interactive Features (Debates, Zeroes, Cooking)
*Goal: Implement writing opinions, posting arguments, joining Zeroes, and the Cooking trending algorithms.*
- [x] Screen UI:
  - [x] Create Opinion Screen with title/content/zeroes/anonymous toggle
  - [x] Opinion Detail Screen with debate zone (Support/Oppose/Question tabs)
  - [x] Write Argument Screen with position selector + anonymous toggle
  - [x] Search Screen with Opinions/Zeroes/Users tabs, search history caching, and custom placeholder
  - [x] Browse Zeroes Screen with join/leave state
- [ ] Backend Integration:
  - [ ] Create/Edit/Delete opinions with Supabase
  - [ ] Post arguments to Support/Oppose/Question zones
  - [ ] Join / Leave Zeroes (database + local cache)
  - [ ] Cooking feed algorithm (activity-based momentum)

---

### Phase 6: Live Rooms (Realtime Text)
*Goal: Implement real-time, text-only chat rooms.*
- [x] Screen UI:
  - [x] Live Rooms browser with room cards
  - [x] Live Room Chat with message list + input field
- [ ] Backend Integration:
  - [ ] Supabase Realtime / WebSockets for message delivery
  - [ ] Join / Leave room tracking (presence channels)

---

### Phase 7: Notifications & Moderation
*Goal: Build push notifications with platform-specific tone guidelines and moderation capabilities.*
- [x] Screen UI:
  - [x] Report Flow screen with reason picker + submit
- [ ] Notification System:
  - [ ] FCM Integration for Android & iOS
  - [ ] Tone implementation (Gen Z friendly, conversational, e.g., "Your debate is cooking.")
  - [ ] In-app notification center screen and badges
- [ ] Moderation System:
  - [ ] Edge Function integrating with OpenAI Moderation API for automatic toxic text filtering
  - [ ] Admin / Mod queue in backend to handle flagged entries

---

### Phase 8: Polish, Testing & Deployment
*Goal: Verify WCAG contrast guidelines, test code, configure CI/CD pipelines, and prepare store listings.*
- [x] Flutter analyze — 0 issues found
- [ ] Accessibility:
  - [ ] Verify WCAG AA compliance (high contrast black/white borders, scalable font sizes)
  - [ ] Support Screen Readers (Semantics widgets)
- [ ] Testing:
  - [ ] Unit tests for Riverpod providers and state transitions
  - [ ] Integration tests for authentication and debate posting flows
- [ ] CI/CD & Deployment:
  - [ ] GitHub Actions workflows for testing and linting
  - [ ] Configure Fastlane for App Store & Play Store distributions

---

## Log of Custom Changes

### June 13, 2026 - Bottom Navigation Bar Redesign
- **Change**: Replaced the default Scaffold `BottomNavigationBar` with a custom floating navigation dock (`custom_navigation_dock.dart`).
- **Details**:
  - Implemented a centered, pill-shaped container.
  - Used dark gray background `#1E1E1E` with 90% opacity and `BackdropFilter` (glassmorphism blur) to make it float seamlessly over page content.
  - Set `extendBody: true` on the shell Scaffold to allow body content to scroll beneath the transparent floating navigation dock.
  - Custom capsule highlight background with opacity transitions on active tabs (using `AnimatedContainer` over 250ms).
  - Updated layout (June 13 Follow-up): Removed text labels and decreased the dock height to 60.0 with a corner radius of 30.0 for a more minimal, sleeker icon-only appearance.
  - Clean implementation without altering go_router routes, providers, or screen logic.

### June 13, 2026 - Search History Caching & Custom Search Bar
- **Change**: Added search history caching, delete button capability, and updated placeholder on the search screen.
- **Details**:
  - Imported and integrated the `shared_preferences` package.
  - Replaced the search hint text with `"Search here"`.
  - Added text field `onSubmitted` logic to save search entries dynamically.
  - Renders a list of recent search entries (up to 10) in the empty state, complete with individual delete buttons and a global "Clear All" button.
  - Tapping a search history entry triggers search and updates its priority order.

### June 13, 2026 - Single-Stance Constraint & Argument Deletion
- **Change**: Enforced a single-stance constraint (support/oppose limitation) per opinion, and enabled argument deletion for users.
- **Details**:
  - Appended a partial unique index `unique_user_stance_per_opinion` in `supabase_schema.sql` to restrict users to at most one Support or Oppose argument per opinion at the database layer.
  - Added the `deleteArgument(String argumentId)` method in `argument_repository.dart` to perform delete queries.
  - Refactored `_ArgumentTile` in `opinion_detail_screen.dart` to a `ConsumerWidget` to check the current user and display a confirmation dialog + "Delete" option for owned arguments.
  - Implemented pre-submission check in `write_argument_screen.dart` to prevent submitting another stance if one is already active for the user.




