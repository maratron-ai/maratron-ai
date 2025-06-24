# MCP Chat Server

This repository contains a simple [Model Context Protocol](https://modelcontextprotocol.io) server built with the [MCP Python SDK](https://github.com/modelcontextprotocol/python-sdk). The server exposes a small chat system backed by PostgreSQL.

## Features

- **Chat resources** – fetch conversation history via `chat://{chat_id}`
- **Chat tools** – `send_message` to store a message and `list_chats` to list active chats
- Uses `asyncpg` for asynchronous PostgreSQL access
- Automatically creates the `messages` table on startup

## Usage

1. Install dependencies (requires Python 3.12+):
   ```bash
   pip install asyncpg psycopg2-binary "mcp[cli]"
   ```
2. Configure database connection using environment variables or copy `.env.example` and edit values:
   ```env
   PGHOST=localhost
   PGUSER=postgres
   PGPASSWORD=yourpassword
   PGDATABASE=mydb
   PGPORT=5432
   ```
3. Run the server via the MCP CLI:
   ```bash
   mcp dev server.py
   ```
   or install it into a compatible client such as Claude Desktop using `mcp install server.py`.

The server can then be queried by any MCP client. For example, using the MCP Inspector you can call the `send_message` tool or read `chat://{chat_id}` resources.

