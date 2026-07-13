# Go Skill

Loaded automatically by the skill-auto-loader hook when `go.mod` is detected.

## Conventions

- Use **standard library** first — only add external deps when necessary.
- Keep handlers thin — business logic in separate packages.
- Always check errors: `if err != nil { return err }`.
- Use `context.Context` as the first parameter in all functions that do I/O.

## Testing

- Test files: `*_test.go` next to the source file.
- Use table-driven tests: `[]struct{ name string; input X; want Y }`.
- Run with `go test ./... -race -cover`.

## Style

- Run `gofmt` and `golangci-lint` before committing.
- Exported identifiers need doc comments starting with the identifier name.
