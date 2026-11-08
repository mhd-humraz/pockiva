# Pockiva --- Complete AI Coding Prompts

A consolidated prompt pack for the existing Pockiva Flutter project. Use
the prompts in order. Give each phase to your coding agent separately;
do not ask it to implement everything in one run.

## Project context

-   Project: Pockiva
-   Tagline: **Set a Goal. Make it Happen.**
-   Local project path: `C:\Users\muham\Desktop\humraz\project\trackinf`
-   GitHub: https://github.com/mhd-humraz/pockiva
-   Framework: Flutter / Dart
-   Local persistence: SQLite and SharedPreferences
-   Existing product: offline personal savings tracker
-   Existing Games work: Home and Games tabs, four game cards, 2048
    implementation reported but must be verified
-   Visual direction: forest green, mint, warm ivory; respect existing
    light and dark themes
-   Currency for Fuel Tracker: INR (₹)

## Global rules --- include these in every coding-agent task

1.  Inspect the actual current files before editing. Do not trust
    previous agent summaries.
2.  Work only in the existing Pockiva project. Do not create a
    replacement app.
3.  Preserve savings functionality, existing records, app navigation,
    themes, Android configuration, iOS configuration, and existing
    working features.
4.  Never reset, delete, recreate, or rename the existing SQLite
    database or its savings tables.
5.  Do not change the Android application ID or database filename
    without an explicit migration plan and approval.
6.  Do not overwrite files unnecessarily. Make small, targeted changes.
7.  Do not add dependencies unless needed; inspect existing dependencies
    and compatibility first.
8.  Work in the requested phase only. Do not continue to the next phase.
9.  Run the requested verification commands and report their actual
    output. Never claim tests passed unless they were run successfully.
10. If output generation fails or the task is interrupted, inspect the
    current workspace and continue from existing files. Do not
    regenerate the project or duplicate files.
11. Report created files, modified files, tests, command results, and
    remaining limitations.
12. Keep all essential app features offline. Do not introduce a backend,
    cloud database, ads, or analytics unless explicitly requested.

------------------------------------------------------------------------

# Prompt 1 --- Read-only project inspection (Fuel Tracker Phase 1)

``` text
Act as a Senior Flutter Engineer and Mobile App Architect.

Perform a READ-ONLY inspection of the existing Pockiva Flutter project.

Project path:
C:\Users\muham\Desktop\humraz\project\trackinf

Inspect these files and relevant supporting files:
- pubspec.yaml
- lib/main.dart
- lib/screens/main_screen.dart
- lib/screens/home_screen.dart
- theme definitions and theme persistence
- SQLite helper, especially lib/data/app_database.dart or its actual location
- existing Games screen and game files
- existing tests

Identify and report:

1. Navigation architecture:
   - How MainScreen is constructed.
   - Current bottom-navigation destinations.
   - How tab state is preserved.
   - How theme changes are passed to screens.
   - The safest way to add a Tools destination without creating another navigation system.

2. Theme architecture:
   - Where MaterialApp is configured.
   - Seed color and actual light/dark color palettes.
   - Typography and existing design tokens.

3. Database:
   - Actual database filename and schema version.
   - Existing tables, columns, indexes, foreign keys.
   - Current migration/onUpgrade logic.
   - Existing savings data model and persistence approach.
   - Any game-related tables or preferences.

4. Project structure:
   - Existing relevant files and actual paths.
   - Existing dependencies relevant to SQLite, preferences, GPS, charts, and UI.
   - Android and iOS configuration relevant to location permissions.

5. Risks and recommendations:
   - Database migration risks.
   - Navigation integration risks.
   - GPS/platform compatibility risks.
   - Recommended files to create or modify for Fuel Tracker.

STRICT RULES:
- Do not create, edit, rename, or delete any files.
- Do not run formatters that modify files.
- Do not implement Phase 2.
- Do not assume previous reports are correct.
- Report actual findings from the current workspace.

Return a concise but technically useful inspection report, then STOP.
```

## Phase 1 acceptance checklist

-   [ ] Actual files inspected.
-   [ ] Database filename and version confirmed.
-   [ ] Existing tables and migrations documented.
-   [ ] Navigation and theme flow documented.
-   [ ] No files changed.
-   [ ] Agent stopped before implementation.

------------------------------------------------------------------------

# Prompt 2 --- Critical Flutter build repair

Use this prompt if `flutter analyze` or `flutter test` reports the
errors previously observed:

-   `HomeScreen()` undefined in `main.dart`.
-   Missing `lib/games/2048/game_2048_screen.dart`.
-   `Game2048Screen` undefined.
-   Invalid function invocation in `games_screen.dart`.
-   Old `package:vibetracker/main.dart` import in
    `test/widget_test.dart`.
-   `MyApp` test widget not found.

``` text
Act as a Senior Flutter Engineer.

Repair the existing Pockiva project using the actual compiler and test errors.

Project:
C:\Users\muham\Desktop\humraz\project\trackinf

First inspect the actual files. Do not trust previous summaries.

CRITICAL RULES:
- Do not recreate the project.
- Preserve savings functionality and all SQLite records.
- Preserve the existing navigation architecture.
- Preserve working 2048 game logic and tests.
- Do not change Android application ID or database filename.
- Do not implement Fuel Tracker.
- Do not delete tests to make the test suite pass.
- Fix only verified issues.

A. main.dart
Inspect main.dart, main_screen.dart, home_screen.dart and splash-screen flow.
Ensure imports and widget references are correct.
The splash flow should lead to MainScreen.
MainScreen should own bottom navigation and show HomeScreen and GamesScreen.
Remove unused imports.

B. Missing 2048 screen
Inspect the actual contents of lib/games/2048/.
Determine whether game_2048_screen.dart is missing, differently named, or stored elsewhere.
If genuinely missing, implement it using the existing engine/controller. Do not duplicate game logic.
Ensure Game2048Screen exists and supports gameplay, score, best score, swipe, undo, restart, win and game-over states, and theme support.

C. games_screen.dart
Fix incorrect imports, undefined classes, invalid function calls, and navigation references.
Keep cards for 2048, Snake, Tic-Tac-Toe and Memory Match.
Only 2048 needs to be playable at this stage; the other games may remain placeholders.

D. widget_test.dart
Inspect pubspec.yaml to identify the actual package name and actual application root widget.
Update the test import and widget construction accordingly.
Do not blindly rename the package or app.
Do not remove the widget test.

E. Code quality
Fix the unused variable in game_2048.dart and other directly related issues.
Avoid unrelated redesigns or broad refactoring.

VERIFICATION:
Run:
flutter pub get
flutter analyze
flutter test

If a command fails, inspect the real error, fix it, and rerun.
Report exact results. Do not claim success without successful command output.

FINAL REPORT:
- Root cause of each issue.
- Files created and modified.
- Actual flutter analyze result.
- Actual flutter test result.
- Confirmation that savings functionality and data remain intact.
- Confirmation that 2048 opens and works.
- Remaining warnings.

Stop after repair.
```

## Repair acceptance checklist

-   [ ] `flutter analyze` completes without errors.
-   [ ] `flutter test` completes successfully.
-   [ ] Do not claim zero tests unless that is the actual result.
-   [ ] Home and savings flow work.
-   [ ] Games tab opens.
-   [ ] 2048 opens and is playable.
-   [ ] No database reset or destructive migration.

------------------------------------------------------------------------

# Prompt 3 --- Games navigation foundation (Phase 2)

Use only if the existing navigation still needs the Home/Games
structure. If it is already implemented and verified, do not recreate
it.

``` text
Act as a Senior Flutter Engineer.

Implement or repair the Pockiva main navigation foundation only.

Inspect the current project first.

Requirements:
- MainScreen owns a single Material 3 NavigationBar.
- Destinations: Home and Games.
- Use IndexedStack or an equivalent state-preserving approach.
- Reuse the existing HomeScreen unchanged.
- GamesScreen displays cards for 2048, Snake, Tic-Tac-Toe and Memory Match.
- Until implemented, games open clearly labelled placeholder screens.
- Respect existing light/dark theme and theme toggle.
- Do not add unnecessary packages.
- Do not change savings logic, SQLite schema, app ID, or database filename.
- Do not create duplicate MainScreen or GamesScreen files.
- Do not start implementing any game in this phase.

Run:
flutter analyze
flutter test

Report actual results and stop.
```

------------------------------------------------------------------------

# Prompt 4 --- Implement 2048 (Games Phase 3)

``` text
Act as a senior Flutter game developer.

Implement a complete, polished, offline 2048 game in the existing Pockiva app.

Inspect the actual project first.

RULES:
- Reuse the existing GamesScreen and navigation.
- Replace only the 2048 placeholder destination.
- Do not modify Home savings functionality.
- Do not modify other game placeholders.
- Do not recreate MainScreen or GamesScreen unnecessarily.
- Do not duplicate existing game logic.
- Do not add unnecessary dependencies.
- Do not change database schema or savings data.

GAMEPLAY:
- 4 x 4 grid.
- Initial tiles are 2 or 4.
- Swipe in four directions.
- Matching adjacent tiles merge.
- A tile can merge only once per move.
- Score increases by the merged tile value.
- Spawn a new tile only after a valid move.
- Detect a 2048 tile and show a win state.
- Detect game over when no moves remain.

UI:
- Pockiva forest-green, mint and ivory visual system.
- Current score and best score.
- Animated 4 x 4 board.
- New Game.
- Undo previous valid move.
- Win dialog with Continue option.
- Game-over dialog with Restart.
- Theme-aware light and dark appearance.
- Responsive layout.

ARCHITECTURE:
Separate game engine, controller, storage and screen.
Suggested paths:
lib/games/2048/game_2048.dart
lib/games/2048/game_2048_controller.dart
lib/games/2048/game_2048_storage.dart
lib/games/2048/game_2048_screen.dart

Adapt to actual project conventions.

PERSISTENCE:
Persist best score locally using the existing storage approach or already-installed SharedPreferences.
Do not put game scores in savings tables.

TESTS:
Test grid initialization, four directional moves, merging, no double merge, score, invalid moves, tile spawning, win, game over, undo and controller behavior.

Run:
flutter analyze
flutter test

Fix all introduced errors. Report actual results and stop after 2048.
```

------------------------------------------------------------------------

# Prompt 5 --- Implement Snake (Games Phase 4)

``` text
Act as a senior Flutter game developer.

Implement a complete, polished Snake game in the existing Pockiva Flutter application.

Inspect the actual project first.

RULES:
- Preserve the working 2048 game.
- Preserve Home, savings data, navigation and theme.
- Replace only the Snake placeholder.
- Do not recreate MainScreen or GamesScreen unnecessarily.
- Do not start Tic-Tac-Toe or Memory Match.
- Do not add unnecessary packages.
- Work in small steps and continue from actual files if interrupted.

GAMEPLAY:
- Grid-based snake movement.
- Four directional controls and swipe controls.
- Food spawns at random valid grid positions.
- Snake grows when food is collected.
- Score increases when food is collected.
- Game ends on wall or self collision.
- Pause and resume.
- Restart.
- Prevent immediate reversal into the opposite direction.
- Never spawn food inside the snake.

UI:
- Game title, score and best score.
- Game board.
- Pause/resume and restart.
- Game-over dialog and New Game action.
- Pockiva green/mint/ivory styling.
- Light and dark theme support.

ARCHITECTURE:
Keep logic separate from UI.
Suggested files:
lib/games/snake/snake_game.dart
lib/games/snake/snake_controller.dart
lib/games/snake/snake_storage.dart
lib/games/snake/snake_screen.dart

Persist best score locally using existing SharedPreferences if available.
Do not use savings tables.

TESTS:
- Initial snake position.
- Movement in all directions.
- Direction reversal prevention.
- Food collection and growth.
- Wall and self collision.
- Food spawning.
- Pause/resume.
- Restart.
- Score updates.

Run:
flutter analyze
flutter test

Report actual results and stop after Snake.
```

------------------------------------------------------------------------

# Prompt 6 --- Implement Tic-Tac-Toe (Games Phase 5)

``` text
Act as a senior Flutter developer.

Implement a complete offline Tic-Tac-Toe game in Pockiva.

Inspect the current project first.

RULES:
- Preserve savings, navigation, 2048 and Snake.
- Replace only the Tic-Tac-Toe placeholder.
- Do not recreate existing screens unnecessarily.
- Do not start Memory Match.
- No backend or internet.

GAME MODES:
- Two players on the same device.
- Optional single-player mode against a simple AI if it can be implemented cleanly.
- If AI is included, make difficulty selection clear.

GAMEPLAY:
- 3 x 3 board.
- X and O turns.
- Detect rows, columns and diagonals.
- Detect draw.
- Prevent moves after game ends.
- Restart and play again.

UI:
- Player turn indicator.
- Scoreboard for X, O and draws.
- Clear win/draw state.
- Pockiva visual system and theme support.
- Responsive layout.

PERSISTENCE:
Persist local best/session statistics using existing local storage.
Do not store in savings tables.

TESTS:
- Valid and invalid moves.
- Turn changes.
- All win combinations.
- Draw.
- No moves after terminal state.
- Restart.
- AI tests if AI is included.

Run flutter analyze and flutter test. Report actual results and stop.
```

------------------------------------------------------------------------

# Prompt 7 --- Implement Memory Match (Games Phase 6)

``` text
Act as a senior Flutter developer.

Implement a complete offline Memory Match card game in Pockiva.

Inspect the current project first.

RULES:
- Preserve savings, navigation, 2048, Snake and Tic-Tac-Toe.
- Replace only the Memory Match placeholder.
- Do not recreate existing screens unnecessarily.
- No backend or internet.

GAMEPLAY:
- Matching pairs of cards.
- Cards flip when tapped.
- Only two unmatched cards can be face-up at once.
- Matching pair remains visible.
- Non-matching cards flip back after a short delay.
- Count moves.
- Track elapsed time.
- Detect completion.
- Restart game.

DIFFICULTY:
- Easy: 4 pairs.
- Medium: 6 pairs.
- Hard: 8 pairs.

UI:
- Responsive card grid.
- Move count.
- Timer.
- Difficulty selector.
- Completion dialog.
- Best result.
- Pockiva visual system and light/dark themes.

PERSISTENCE:
Persist best results locally.
Do not store game statistics in savings tables.

TESTS:
- Pair generation.
- Card flipping.
- Match detection.
- Mismatch behavior.
- Move counting.
- Completion.
- Restart.
- Difficulty configuration.

Run flutter analyze and flutter test. Report actual results and stop.
```

------------------------------------------------------------------------

# Prompt 8 --- Fuel Tracker complete architecture and implementation (without odometer)

``` text
# MASTER IMPLEMENTATION PROMPT: Pockiva Fuel Tracker Without an Odometer

Act as a Senior Flutter Engineer, Mobile App Architect, GPS Tracking Engineer, Database Engineer and UI/UX Designer.

Implement a complete offline-first Fuel Tracker inside the existing Pockiva Flutter application.

The feature must support motorcycles and cars WITHOUT requiring an odometer or trip meter.

Users must measure distance using:
1. Manual distance entry.
2. GPS-based ride tracking.

Both methods must integrate into the same fuel tracking and analytics system.

PRODUCT:
- App: Pockiva
- Tagline: Set a Goal. Make it Happen.
- Feature: Fuel Tracker
- Location: Tools section
- Vehicles: motorcycles and cars
- Fuel types: Petrol, Diesel, CNG
- Currency: INR (₹)
- Database: existing SQLite database
- Essential functionality: offline

NO ODOMETER REQUIREMENT.

## 1. Project protection

Inspect the current repository before implementation.

Preserve:
- Existing savings functionality and records.
- Existing Games section and all working games.
- Existing navigation.
- Existing theme configuration.
- Existing Android and iOS configuration.
- Existing database filename and migration history.
- Existing Codemagic workflow.

Never reset the database, delete savings tables, change the app ID unnecessarily, or replace the architecture.

## 2. Tools navigation

Add a Tools destination to the existing main navigation. Do not create a second navigation system.

Preserve Home and Games. Tools should open a ToolsScreen containing a Fuel Tracker entry.

Use the existing MainScreen and theme approach.

## 3. Fuel Tracker dashboard

Create a premium dashboard with:
- Total fuel expenses.
- Total fuel purchased.
- Total recorded distance.
- Distance since last fuel entry.
- Average verified mileage only when enough data exists.
- Vehicle selector.
- Recent fuel and ride activity.

Quick actions:
- Add Fuel.
- Start GPS Ride.
- Enter Distance Manually.
- History.
- Analytics.

Provide helpful empty states.

## 4. Vehicle management

Support motorcycles and cars.

Vehicle fields:
- Name.
- Category.
- Manufacturer.
- Model.
- Fuel type.
- Optional nickname.
- Notes.

Allow create, edit, delete with confirmation, switch active vehicle, and view vehicle-specific records.

Never require odometer readings.

## 5. Fuel purchase entries

Fields:
- Amount paid.
- Litres purchased.
- Fuel type.
- Date and time.
- Refill type: partial or full tank.
- Optional notes.

Quick amount options:
₹50, ₹100, ₹200, ₹500 and custom.

Calculate price per litre from amount and quantity.

Store amount as integer paise and quantity as integer millilitres. Avoid floating-point money storage.

Validate positive amounts and quantities and prevent accidental duplicate submissions.

Adding fuel must not require an odometer.

## 6. Manual distance tracking

Create a manual distance entry screen.

Fields:
- Vehicle.
- Distance travelled in kilometres.
- Date/time.
- Optional duration.
- Optional notes.
- Optional related fuel entry.

Example:
- Refill: ₹100.
- Ride 1: 10 km.
- Ride 2: 15 km.
- Ride 3: 20 km.
- Total recorded distance: 45 km.

Display ride distance and cumulative distance between fuel purchases.

Allow edit/delete.

Validate positive and reasonable distances.

Do not assume all distance after a purchase was powered by only that purchase's fuel. Remaining tank fuel may exist.

## 7. GPS ride tracking

Use a compatible location package such as geolocator only after checking current Flutter and platform compatibility.

Features:
- Select vehicle.
- Explain and request location permission when needed.
- Explicit Start Ride action.
- Live distance.
- Elapsed time.
- Pause, resume and stop.
- Save ride distance, duration, start/end times and tracking method.
- Ride history and summary.

GPS safety:
- Track only after explicit user action.
- Filter poor-accuracy readings and implausible jumps.
- Avoid double counting.
- Handle GPS loss and disabled location services.
- Handle permission denial.
- Handle app interruption.
- Never silently track.
- Never upload route coordinates.
- Do not require internet for GPS distance measurement.

Background tracking requires platform-specific implementation and explicit user consent:
- Android foreground service and persistent notification.
- iOS background location configuration and permissions.

If background tracking is not implemented in the first version, clearly explain that tracking requires the app to remain active. Do not claim uninterrupted tracking.

Store only necessary route points locally and allow deletion.

## 8. Data model

Suggested SQLite tables:

vehicles:
- id
- name
- category
- manufacturer
- model
- fuel_type
- registration_nickname
- notes
- created_at
- updated_at

fuel_entries:
- id
- vehicle_id
- amount_paise
- quantity_ml
- refill_type
- entry_date
- notes
- created_at

ride_sessions:
- id
- vehicle_id
- distance_meters
- duration_seconds
- tracking_method (gps/manual)
- started_at
- ended_at
- status
- notes
- created_at

fuel_economy_records:
- id
- vehicle_id
- start_fuel_entry_id
- end_fuel_entry_id
- distance_meters
- fuel_consumed_ml
- mileage_milli_km_per_litre
- created_at

Adjust the schema if justified by the actual database and architecture.

Add indexes and foreign keys. Use transactions for related operations.

## 9. Migration safety

Inspect the actual database version and migration logic first.

Implement a versioned migration that preserves all existing savings goals, entries, game records and other tables.

Never drop or recreate existing tables.

Test migration from the current installed database and verify savings records remain intact.

## 10. Fuel calculations — critical correctness rules

Never confuse distance per purchase with actual km/L mileage.

A. Distance per refill period:
- Sum accepted ride distances between fuel entries.
- Label as "Distance travelled between fuel entries."
- Do not call it verified mileage.

B. Full-to-full mileage:
1. Record a full-tank baseline.
2. Record subsequent partial refills.
3. Record the next full-tank refill.
4. Sum distance between the two full-tank events.
5. Sum litres purchased after the starting full-tank event, including the ending full-tank refill.
6. Exclude the starting full-tank purchase from consumed fuel.
7. Calculate km/L = distance / fuel consumed.

Example:
- Starting full tank recorded.
- Intermediate refill: 2 L.
- Ending full tank refill: 3 L.
- Distance: 180 km.
- Fuel consumed: 5 L.
- Verified mileage: 36 km/L.

Only calculate when both full-tank events exist, quantity values are available, distance records cover the interval, and the interval is valid.

If the user starts with a partial tank, explain that verified full-to-full mileage cannot be calculated until a valid full baseline and ending full-tank event exist.

## 11. Analytics

Provide:
- Total fuel expenses.
- Total litres.
- Total recorded kilometres.
- Average verified km/L.
- Distance per refill period.
- Monthly spending chart.
- Distance over time.
- Verified mileage trends.
- Fuel purchase history.
- Ride history.

Filters:
- Vehicle.
- Date range.
- Fuel type.
- GPS/manual method.

Never label estimates as verified mileage.

## 12. Screens

Suggested:
- ToolsScreen.
- FuelDashboardScreen.
- VehicleManagementScreen.
- AddVehicleScreen.
- AddFuelEntryScreen.
- ManualDistanceScreen.
- GpsRideScreen.
- RideSummaryScreen.
- FuelHistoryScreen.
- FuelAnalyticsScreen.

Adapt to the existing file structure.

## 13. Offline and privacy

No backend, authentication, cloud database, ads, analytics SDK, online map requirement, or silent location tracking.

Manual tracking and fuel entries must work without internet.

GPS can use device location services offline.

## 14. Tests

Test:
- Fuel entry creation, edit, delete, validation.
- Partial and full refills.
- Manual distance validation and editing.
- GPS distance between points.
- Poor GPS accuracy and jumps.
- Permission denial.
- Pause/resume/stop.
- Duplicate coordinate handling.
- Full-to-full mileage.
- Multiple partial refills.
- Incomplete cycles.
- Missing distance.
- Mixed manual and GPS distance.
- Historical edits/deletion.
- Database migration.
- Preservation of savings records and foreign-key integrity.

Run:
flutter analyze
flutter test

Fix introduced errors.

## 15. Phased workflow

Implement separately:

Phase 1: Read-only project inspection and baseline report.
Phase 2: Tools destination and Fuel Tracker dashboard shell.
Phase 3: Vehicle management.
Phase 4: Fuel entry management.
Phase 5: Manual distance tracking.
Phase 6: GPS ride tracking.
Phase 7: Distance aggregation.
Phase 8: Verified full-to-full mileage.
Phase 9: History and analytics.
Phase 10: Safe database migration and regression tests.
Phase 11: Android and iOS compatibility verification.

After each phase:
- Report created/modified files.
- Run relevant tests.
- Report actual errors and results.
- Stop before the next phase if critical issues remain.

Final deliverables:
- Implemented features.
- Files created/modified.
- Dependencies.
- Database migration details.
- GPS permissions.
- Manual and GPS tracking explanation.
- Mileage calculation explanation.
- Tests and actual results.
- Android/iOS build status.
- Remaining limitations.
- Run/build commands.

The result must be a reliable, privacy-conscious, offline Fuel Tracker that never requires an odometer.
```

## Recommended execution order

1.  Run **Prompt 1** to inspect the current project.
2.  If the current errors remain, run **Prompt 2** and stabilize the
    project.
3.  Run Prompts 3--7 only for game work that is still missing.
4.  Run Prompt 8 in separate phases for Fuel Tracker.

Do not run multiple coding-agent phases simultaneously. Verify each
phase before moving forward.

## PowerShell verification commands

``` powershell
cd "C:\Users\muham\Desktop\humraz\project\trackinf"

flutter pub get
flutter analyze
flutter test
git status
```

For an Android debug run:

``` powershell
flutter run
```

For a release APK:

``` powershell
flutter build apk --release
```
