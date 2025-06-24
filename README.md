# Maratron AI

This project contains a simple FastMCP server used for demos. It connects
to a local PostgreSQL database and provides utilities for inspecting and
updating data.

## Running the server

Install dependencies and run the server using the MCP CLI:

```bash
pip install -e .
python server.py
```

The server expects a PostgreSQL database specified by the `DATABASE_URL`
environment variable. By default it connects to:

```
postgresql://maratron:yourpassword@localhost:5432/maratrondb
```

## Available tools

- `list_tables()` – Show all tables in the public schema.
- `describe_table(table_name)` – List the columns for a given table.
- `add_user(name, email)` – Insert a basic user record.
- `list_users(limit=10)` – List user names from the database.
- `count_rows(table)` – Show how many records exist in a table.
- `add_run(user_id, date, duration, distance, distance_unit)` – Record a new run.
- `list_recent_runs(limit=5)` – Display recent run summaries.


