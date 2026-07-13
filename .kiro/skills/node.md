# Node/JavaScript Skill

Loaded automatically by the skill-auto-loader hook when `package.json` is detected.

## Conventions

- Use **CommonJS** (`require`) for plain Node scripts; **ES modules** (`import`) when `"type": "module"` is set in package.json.
- Prefer **Express** for HTTP servers. Route handlers go in `src/routes/`, middleware in `src/middleware/`.
- Keep route handlers thin — put business logic in `src/services/`.
- Always add **input validation** at the route layer (use `express-validator` or manual checks).
- Use **async/await** — never raw `.then()` chains in route handlers.

## Testing

- Use **Jest** or **Vitest**. Test files: `*.test.js` next to the source file.
- Always test the happy path AND at least one error/edge case.

## Security

- Never hardcode secrets — use `process.env` and a `.env` file with `dotenv`.
- Add `.env` to `.gitignore`.
- Use **helmet** and **cors** middleware for production servers.
- Hash passwords with **bcrypt** — never store plaintext.

## Error handling

- Wrap async route handlers in try/catch or use `express-async-handler`.
- Return consistent JSON error shapes: `{ error: "message", code: "ERROR_CODE" }`.
