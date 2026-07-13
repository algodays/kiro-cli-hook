# Python Skill

Loaded automatically by the skill-auto-loader hook when `requirements.txt` or `pyproject.toml` is detected.

## Conventions

- Use **type hints** on all function signatures.
- Use **structlog** or standard `logging` — never `print()` for production code.
- Keep views/serializers thin — business logic belongs in `services.py`.
- Use **dataclasses** or **Pydantic** for structured data.

## Testing

- Use **pytest**. Test files: `test_*.py` in a `tests/` directory.
- Use fixtures for shared setup. Parametrize for multiple inputs.

## Security

- Never hardcode secrets — use `os.environ` or a `.env` file with `python-dotenv`.
- Use parameterized queries — never f-string SQL.
- Validate all external input.

## Style

- Follow **PEP 8**. Use **black** for formatting, **ruff** for linting.
- Max line length: 100 chars.
