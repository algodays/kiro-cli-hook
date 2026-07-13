# Flutter Skill

Loaded automatically by the skill-auto-loader hook when `pubspec.yaml` is detected.

## Conventions

- Use **state management** consistently: Riverpod, Bloc, or Provider — pick one per project.
- Screens in `lib/screens/`, widgets in `lib/widgets/`, models in `lib/models/`.
- Keep widgets small and composable — extract reusable UI into shared widgets.
- Use **const** constructors wherever possible.

## Testing

- Unit tests: `test/` directory, `*_test.dart` files.
- Widget tests with `flutter test`.
- Integration tests with `integration_test/` package.

## Performance

- Avoid `setState` for complex state — use a state management solution.
- Use `const` widgets to prevent unnecessary rebuilds.
- Lazy-load lists with `ListView.builder`.
