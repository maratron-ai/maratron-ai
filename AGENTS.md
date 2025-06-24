# Repository Guidelines

This project contains a simple FastMCP server and SQL schema. The code targets
Python 3.11 and uses `uv` for dependency management.

## Coding style
- Use four spaces for indentation.
- Keep line length under 100 characters when practical.
- Format modified Python files with `black` (version 25.1.0).
- Lint modified Python files with `ruff`.

## Workflow checks
- After editing Python files, run `ruff <files>` and `black --check <files>`.
- Run `pytest` if any tests exist.
- You may ignore lint errors in files you did not modify.

## Running the project
Install dependencies with `uv pip install -e .` and start the demo server using
`python server.py`.
