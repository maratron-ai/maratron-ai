# maratron-ai

This project contains a simple [Model Context Protocol](https://modelcontextprotocol.io) (MCP) server that exposes a PostgreSQL database to a local LLM.

## Setup

1. Install dependencies including the local LLM runtime:
   ```bash
   npm install
   npm install llama-node @llama-node/llama-cpp
   ```

2. Copy `.env.example` to `.env` and fill in your PostgreSQL connection details and the path to your LLaMA or compatible model. These variables are loaded automatically using the `dotenv` package:
   ```bash
   cp .env.example .env
   # edit .env to match your database settings
   ```

   The server uses standard PostgreSQL variables (`PGHOST`, `PGUSER`, `PGPASSWORD`, `PGDATABASE`, `PGPORT`) and `LLAMA_MODEL` for the `.gguf` model file.

3. Start the server with `ts-node`:
   ```bash
   npx ts-node src/server.ts
   ```
   The server does not expose an HTTP port. It communicates over **stdin/stdout**
   using the Model Context Protocol. When starting, it loads the LLaMA model
   specified by `LLAMA_MODEL`. Run the server as a subprocess of your LLM
   application or interact with it using an MCP-compatible CLI.

## Server Features

- **Resource `schema`** – exposes the database schema as plain text.
- **Tool `query`** – runs read-only SQL queries and returns the result rows as JSON.
- **Tool `execute`** – runs SQL statements that modify data and reports affected rows.
- **Tool `chat`** – generates a response from the local LLM given a prompt.

The server uses the MCP SDK to handle communication and expects a PostgreSQL 15 database accessible with the environment variables mentioned above.