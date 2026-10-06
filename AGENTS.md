# Repository Guidelines

## Project Structure & Module Organization

This directory is currently an empty Godot boilerplate workspace. No source files, tests, assets, or Git metadata are present. When initializing the project, place `project.godot` at the repository root and use the following structure:

- `scenes/`: reusable scenes and their associated scripts.
- `scripts/`: shared gameplay logic and utilities.
- `assets/`: textures, audio, fonts, and other source assets.
- `tests/`: automated tests once a test framework is selected.

Keep related scenes and scripts together where practical. Exclude generated `.godot/` data and exported build artifacts from version control.

## Build, Test, and Development Commands

No build scripts or test commands are configured yet. After creating `project.godot` and installing a compatible Godot version, use these commands; replace `godot` with the executable available on your system:

- `godot --editor --path .`: open the project in the editor.
- `godot --path .`: run the configured main scene.
- `godot --headless --path . --editor --quit`: import resources and check editor startup without a window.

Configure export presets before exporting builds. Document the required Godot version and any additional commands when introducing them.

## Coding Style & Naming Conventions

For GDScript, use tabs for indentation, `snake_case` for files, functions, and variables, `PascalCase` for class names, and `UPPER_SNAKE_CASE` for constants. Prefer explicit types and small scripts with a clear responsibility. No formatter or linter is configured.

## Testing Guidelines

No test framework or coverage threshold exists. For now, run affected scenes and verify the main scene starts without errors. Record reproduction steps and expected behavior for fixes. If automated testing is added, keep tests in `tests/`, use descriptive names such as `test_player_movement.gd`, and document the runner command.

## Commit & Pull Request Guidelines

There is no Git history to establish existing conventions. Use concise, imperative commit subjects, such as `Add player movement scene`. Keep changes focused. Pull requests should explain the change, link relevant issues, describe validation performed, and include screenshots or recordings for visible changes.
