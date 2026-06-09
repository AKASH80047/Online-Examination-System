# Online Examination System - Implementation TODO

## Phase 1: Foundation + Architecture
- [x] Update `pubspec.yaml` with production dependencies
- [x] Create clean architecture folder structure
- [x] Add app bootstrap (`main.dart`, Firebase init, provider scope)
- [x] Add app theming (Material 3, light/dark)
- [x] Add base routing with placeholder shells
- [x] Add core utilities (failures, constants)
- [x] Add placeholder shells for Admin and User panels

## Phase 2: Authentication + Roles
- [x] Firebase auth service (DataSource & Repository)
- [x] User profile creation in Firestore logic
- [x] Role-based access handling (admin/user)
- [x] One-device login restriction baseline

## Phase 3: Data Layer + Firestore
- [x] Define User profile schema (in Auth logic)
- [x] Implement domain models (exams, questions)
- [x] Implement repositories with repository pattern for exams (including `getAllExams`)
- [x] Implement Firestore services for exams

## Phase 4: Admin Panel
- [x] Admin dashboard with navigation to exam list
- [x] Exam list screen
- [x] Exam creation screen (basic form)
- [x] Exam CRUD (Update and Delete) with publish/unpublish
- [x] Question creation (single/multi-correct, True/False, explanation)
- [x] User management list
- [x] Search and filter exams
- [x] Analytics and result export hooks

## Phase 5: User Exam Experience
- [x] Available exams list screen
- [x] Exam instructions screen
- [x] Exam engine with timer and auto submit
- [x] Question palette and navigation
- [x] Mark for review and answer state tracking
- [x] Instant feedback / final result modes

## Phase 6: Result + Extra Features
- [x] Result computation logic
- [x] Leaderboard and performance analytics
- [x] PDF result export
- [x] Subject-wise reports and history
- [x] Certificate generation
- [x] Push notifications (FCM)

## Phase 7: Security + Hardening
- [x] Firestore security rules
- [x] Storage security rules
- [x] Anti-cheat hooks (lifecycle monitoring)
- [x] Production readiness review and cleanup
gei