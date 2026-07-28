# AI Agent Project Rules

## Universal Conventions
*(These apply to every project regardless of tech stack — keep this section identical across repos.)*

### Language
All technical comments, documentation, and logic descriptions in the codebase MUST be written in English.

### Documentation Convention
For every public class/method, add a doc comment following the language's standard doc format (e.g. dartdoc for Dart, JSDoc for TypeScript):
- One sentence summarizing purpose (don't repeat the class/method name).
- One line per non-trivial parameter (`@param` or equivalent).
- Return value documentation only if it isn't obvious from the type.
- NO code examples unless the logic is genuinely non-obvious.
- Do not document trivial getters/setters or self-explanatory boilerplate.

### Scope Discipline
- Only read, open, or modify files explicitly named in the task, or files directly imported/referenced by them.
- Do NOT explore or edit files outside the stated scope without first asking for confirmation.
- Exception — the following do NOT require asking first, as they are natural consequences of a task, not scope expansion:
  - Regenerating/updating codegen output files (e.g. `.g.dart`) that correspond to a modified source file.
  - Updating an existing test file that directly tests the modified code, when needed to keep the Mandatory Verification Pipeline passing.
- If the task seems to require touching files beyond the stated scope AND beyond the exceptions above, STOP and report which additional files you believe are needed, and why — before making changes.

### Ambiguity Handling
- If a requirement is ambiguous or underspecified, state your interpretation/assumption explicitly before proceeding, rather than silently guessing.
- Prefer asking one direct clarifying question over implementing multiple speculative variants.

### Dependency Changes
- Do NOT add, remove, or upgrade a dependency without explicitly flagging it in your response (name, version, reason).
- Never introduce a new dependency to solve a problem that can be reasonably solved with existing project dependencies or stdlib.

### Git & Version Control
- Once the full Mandatory Verification Pipeline has passed (all steps green, zero errors, zero failing tests) for a completed, atomic logical change, commit it without asking for permission first.
- Do NOT commit if any pipeline step failed, was skipped, or could not be run — stop and report instead, per Guardrails and Verification Honesty above.
- Write descriptive, atomic commit messages (what changed and why, not just "fix").
- NEVER force-push, rewrite shared history, or delete branches without explicit confirmation.

### Security
- NEVER hardcode API keys, tokens, passwords, or other secrets in source code.
- NEVER commit `.env` files or other files containing local secrets.
- Use environment variables / the platform's secure storage mechanism for anything sensitive.

### Verification Honesty
- NEVER report that a verification step (build, analyze, lint, test) passed unless you actually executed it in this session and observed the output.
- If a step cannot be run (e.g. missing tool, sandboxed environment limitation), say so explicitly instead of assuming or claiming success.
- Do not fabricate or paraphrase tool output — quote or summarize only what was actually returned.

### Debug Artifact Cleanup
- Remove debug print/log statements and commented-out code introduced during iteration before considering a task complete, unless explicitly asked to leave them for further debugging.
- Do not leave stray TODO comments describing unfinished work without flagging them explicitly in your final summary.

### Guardrails
- NEVER delete, skip, or weaken a test to make the verification pipeline pass. Fix the underlying code instead.
- NEVER add lint-suppression comments (e.g. `// ignore:`) or disable analyzer/linter rules to silence errors, unless explicitly instructed.
- If a fix is not obvious after 2 attempts, stop and report the exact error instead of applying a workaround.

### Formatting & Style
- Follow the official style guide / formatter for the language in use (e.g. `dart format .`).
- Ensure all generated files are correctly linked/imported per the framework's conventions (e.g. `part 'filename.g.dart';` for Dart build_runner output).

---

## Project Stack: flutter_bloc_boilerplate
*(Replace this whole section when starting a new project with a different stack.)*

### Build & Generation Commands
- Install dependencies: `flutter pub get`
- Run build runner: `dart run build_runner build --delete-conflicting-outputs`
- Watch build runner: `dart run build_runner watch --delete-conflicting-outputs`
- Code analysis: `flutter analyze`
- Run tests: `flutter test`
- Use `--delete-conflicting-outputs` on build_runner to prevent compilation deadlocks from stale generated files.

### Architecture & Layer Boundaries
This is a Local-First, AI-Native boilerplate utilizing Clean Architecture under a Feature-First approach:
- **Domain Layer** (`lib/features/<feature>/domain/`): Pure Dart logic — entities, repository interfaces, use cases. NO Flutter, BLoC, or GetIt imports allowed here.
- **Data Layer** (`lib/features/<feature>/data/`): Repository implementations, Isar models, mappers, utilizing `isar_community`.
- **Presentation Layer** (`lib/features/<feature>/presentation/`): UI widgets, BLoC/Cubit state management.
- **DI:** GetIt + Injectable (`@injectable`/`@lazySingleton`) for dependency injection. Regenerate after adding/changing annotations via the build runner command above.
- **State Management:** BLoC (`flutter_bloc`) strictly.
- **Data Flow:** UI (`BlocBuilder`/`BlocListener`) -> BLoC (`Bloc`) -> Repository Interface (domain) -> Repository Impl (data) -> Local DB (`isar_community`).
- **Reactivity:** Handled purely via Isar streams. BLoCs listen to Isar collections and emit states accordingly.
- **Automated Import Guardrail:** `import_lint` analyzer plugin — enforces `avoid_infrastructure_imports_in_presentation` in `analysis_options.yaml`, prohibiting presentation layer files (`lib/features/*/presentation/**`) from importing data layer implementations (`lib/features/*/data/**`).
- **Entrypoints:** `lib/main.dart` (DI init + `runApp`) -> `lib/app.dart` (`MultiBlocProvider` + `MaterialApp`). DI is configured via `configureDependencies(Environment.prod)` in `main.dart`.

#### Strict Dependency Rules
- **No data-model leakage into presentation:** Presentation files (`bloc`, `state`, `event`, widgets) must never import `TodoModel`, `UserPreferencesModel`, or any file from `lib/features/*/data/`. Only domain entities (`Todo`, `UserPreferences`) and failure types may be referenced.
- **No Isar annotations in presentation:** `@collection`, `@property`, `@Index`, `Isar.autoIncrement`, and any other Isar-specific annotations or types must not appear in presentation-layer code.
- **Mappers must be stateless:** Mapper functions (e.g. `toDomain()`, `toData()`) must be synchronous, side-effect-free extension methods or top-level functions. They must not hold mutable state, perform I/O, or depend on external services.
- **One-way dependency:** Imports flow inward toward the domain. Presentation imports domain; data imports domain and Isar. Domain imports nothing project-specific.

### Generated Files
- `*.g.dart` files hold Injectable DI config and Isar schemas, use the `part of` directive, and are excluded from `flutter analyze`.
- Regenerate whenever annotations change (see Build & Generation Commands above).

### Lifecycle & Resource Disposal Checklist
Every BLoC/Cubit with a `StreamSubscription` must override `close()` and cancel it there. Before considering any feature involving streams, timers, or animations complete, verify:
- Every `StreamSubscription` is cancelled in `close()`.
- Every `Timer` or `AnimationController` is properly disposed.
- All Isar dynamic query streams are closed or managed via BLoC lifecycle.

### Testing Conventions
- **Golden tests** are tagged with `@Tags(['golden'])` and skipped on non-macOS (`skip: !Platform.isMacOS`); config lives in `dart_test.yaml`.
- **HydratedCubit test setup:** tests for `AppThemeCubit` or any widget using it must set `HydratedBloc.storage = _TestStorage()` (an in-memory `Storage` implementation).
- **Fake repo leak prevention:** `FakeTodoRepository` and `FakeUserPreferencesRepository` expose a `dispose()` method — always call it in `tearDown` to close the internal `StreamController`.
- **Wrap-pattern repos** (e.g. `_FailingOnceTodoRepository`) contain a `FakeTodoRepository` inside them — ensure the inner fake is also disposed in `tearDown`.

### Mandatory Verification Pipeline
After any modification within the `lib/**` directory, you MUST execute the following pipeline in strict order (matches `before_push.sh`):
1. `flutter pub get`
2. `flutter gen-l10n`
3. `dart run build_runner build --delete-conflicting-outputs`
4. `dart format --output=none --set-exit-if-changed lib test bin scripts`
5. `flutter analyze`
6. `flutter test`

A task is NOT considered complete until all steps pass with zero errors and zero failing tests, AND the Lifecycle & Resource Disposal Checklist above has been explicitly verified. Fix any arising issues autonomously, subject to the Guardrails above.
