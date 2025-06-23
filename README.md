# maratron-ai

This project contains a simple [Model Context Protocol](https://modelcontextprotocol.io) (MCP) server that exposes a PostgreSQL database to a local LLM.

## Setup

1. Install dependencies:
   ```bash
   npm install
   ```

2. Set PostgreSQL connection environment variables if needed (`PGHOST`, `PGUSER`, `PGPASSWORD`, `PGDATABASE`, etc.). By default the `pg` library uses these variables.

3. Start the server with `ts-node`:
   ```bash
   npx ts-node src/server.ts
   ```
   The server communicates over stdio and can be used with any MCP-compatible client.

## Server Features

- **Resource `schema`** – exposes the database schema as plain text.
- **Tool `query`** – runs read-only SQL queries and returns the result rows as JSON.
- **Tool `execute`** – runs SQL statements that modify data and reports affected rows.

The server uses the MCP SDK to handle communication and expects a PostgreSQL 15 database accessible with the environment variables mentioned above.
