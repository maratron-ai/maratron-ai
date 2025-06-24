# Maratron AI

This project contains a simple FastMCP server used for demos. It exposes
weather utilities as well as a tool to query a local PostgreSQL database.

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

- `get_alerts(state)` – Fetch active weather alerts for a US state.
- `get_forecast(latitude, longitude)` – Retrieve the forecast for a
  given latitude/longitude.
- `list_users(limit=10)` – List user names from the database.


## Notes
- using `uv` as python package manager
- run `mcp dev server.py` to view mcp ui
- restart claude desktop then should be able to see tools

## Resources
- https://modelcontextprotocol.io/introduction
- https://github.com/modelcontextprotocol/python-sdk
- https://modelcontextprotocol.io/quickstart/server#mac-os-linux