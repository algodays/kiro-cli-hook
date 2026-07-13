# Rust Skill

Loaded automatically by the skill-auto-loader hook when `Cargo.toml` is detected.

## Conventions

- Use **clippy** — fix all warnings before committing.
- Use `thiserror` for library errors, `anyhow` for application errors.
- Prefer `&str` for string params, `String` for owned returns.
- Use **Result<T, E>** for fallible operations — never `unwrap()` in production code.

## Testing

- Tests in the same file under `#[cfg(test)] mod tests`.
- Use `assert_eq!` for equality, `assert!` for booleans.
- Test edge cases: empty inputs, max values, overflow.

## Style

- Follow rustfmt defaults.
- Document all public items with `///` doc comments.
