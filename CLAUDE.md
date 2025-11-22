# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **monorepo** managed by **Melos** containing four Flutter/Dart packages:

- **widgets-pack**: Reusable Flutter widgets collection (tables, forms, video players, pickers)
- **extensions-pack**: Dart/Flutter extensions for common types (String, DateTime, List, etc.)
- **dart_http_client**: HTTP client wrapper built on Dio with structured endpoints
- **my-linter**: Shared linter configuration package used across all packages

## Monorepo Management with Melos

### Bootstrap and Setup

```bash
# Initial setup - install dependencies for all packages
melos bootstrap

# Clean and reinstall all dependencies
melos reset

# Clean all packages
melos clean
```

### Common Development Commands

```bash
# Analyze all packages (runs flutter analyze with --no-fatal-warnings)
melos analyze

# Publish all packages (use with caution)
melos publish
```

### Working with Individual Packages

```bash
# Run commands in a specific package directory
cd widgets-pack
flutter pub get
flutter analyze

# Or use melos exec to run commands across packages
melos exec "flutter pub get"
```

## Code Architecture

### widgets-pack

The largest package, organized as:

- **`lib/widgets/`**: UI components
  - `table_view/`: Complex table widget with filtering, sorting, actions
  - `fields/`: Form input widgets
  - `pickers/`: Date/time picker components
  - `buttons.dart`, `text.dart`, `video_player.dart`, etc.
- **`lib/helpers/`**: Utility classes and action handlers
  - `actions.dart`: Action handling logic
  - `items_fetcher.dart`, `items_handler.dart`: Data management helpers

**Dependencies**: Uses `extensions_pack` extensively, plus Chewie, RxDart, Skeletonizer, video players

### extensions-pack

Provides extension methods organized by type:

- **`lib/extensions/`**: 20+ extension files
  - Type-specific: `string_extension.dart`, `date_time_extension.dart`, `list_extension.dart`
  - Widget: `widget_extension.dart`, `context_extension.dart`
  - Utility: `color.extension.dart`, `form_key.extension.dart`
- **`lib/utils/`**, **`lib/validators/`**, **`lib/formatters/`**: Additional utilities

### dart_http_client

HTTP client abstraction over Dio:

- **`lib/http/`**: HTTP client creation and providers
- **`lib/endpoints/`**: Endpoint definitions
- **`lib/methods/`**: HTTP method implementations (GET, POST, PUT, DELETE)
- **`lib/manager/`**: API manager for coordinating requests
- **`lib/response/`**: Response handling

Uses json_annotation and build_runner for code generation.

### my-linter

Shared linter configuration:

- **`lib/analysis_options.yaml`**: Comprehensive lint rules (190+ rules)
- Enforces: trailing commas, const constructors, single quotes, proper formatting
- Page width: 120 characters
- All other packages include this via `include: package:my_linter/analysis_options.yaml`

## Linting and Formatting

All packages use the shared `my_linter` configuration:

```yaml
# In package's analysis_options.yaml
include: package:my_linter/analysis_options.yaml
```

**Key rules enforced**:
- `require_trailing_commas`
- `prefer_const_constructors`
- `prefer_single_quotes`
- `prefer_final_locals`
- Page width: 120 characters

**Excluded from analysis**: Generated files (`**/*.g.dart`, `**/*.gr.dart`)

### Formatting Code

Format code using Dart formatter:

```bash
# Format a specific package
cd widgets-pack
dart format .

# Format all packages
melos exec "dart format ."
```

## Code Generation

The `dart_http_client` package uses code generation:

```bash
cd dart_http_client
flutter pub run build_runner build
# Or for watch mode:
flutter pub run build_runner watch
```

## Package Dependencies

**Cross-package dependencies**:
- `widgets-pack` depends on `extensions-pack` (currently using published version ^2.5.1)
- All packages use `my_linter` as a dev dependency
- Root `pubspec.yaml` manages `melos` dependency

## Local Development

When running `melos bootstrap`, Melos automatically creates `pubspec_overrides.yaml` files in packages that depend on other packages in the monorepo. This allows local development without modifying `pubspec.yaml`:

**Example: widgets-pack/pubspec_overrides.yaml** (auto-generated):
```yaml
dependency_overrides:
  extensions_pack:
    path: ../extensions-pack
```

This means:
- `pubspec.yaml` keeps published version references (e.g., `^2.5.1`)
- Local changes to `extensions-pack` are immediately available in `widgets-pack`
- No need to manually switch between path and version dependencies

## Testing

Currently, this monorepo does not contain test suites. When adding tests in the future:

```bash
# Run tests in a specific package
cd widgets-pack
flutter test

# Run tests across all packages with Melos
melos exec "flutter test"
```

## Git Workflow

Current branch: **develop**
Main branch: **main** (use for PRs)

## Version Management

Use Melos for coordinated versioning:

```bash
# Bump versions (runs bootstrap and git add as pre-commit hook)
melos version
```

Each package maintains its own version in its `pubspec.yaml`.
