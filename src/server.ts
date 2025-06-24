import "dotenv/config";
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
import { Pool } from "pg";
import { LLM } from "llama-node";
import { LLamaCpp } from "llama-node/dist/llm/llama-cpp.js";
import path from "path";

const server = new McpServer({
  name: "postgres-mcp-server",
  version: "1.0.0",
});

const pool = new Pool(); // uses PG env vars

const llama = new LLM(LLamaCpp);
const llamaConfig = {
  modelPath: path.resolve(process.env.LLAMA_MODEL ?? "model.gguf"),
  enableLogging: false,
  nCtx: 1024,
  seed: 0,
  f16Kv: false,
  logitsAll: false,
  vocabOnly: false,
  useMlock: false,
  embedding: false,
  useMmap: true,
  nGpuLayers: 0,
};

server.registerResource(
  "schema",
  "schema://main",
  {
    title: "Database Schema",
    description: "PostgreSQL database schema",
    mimeType: "text/plain",
  },
  async (uri: URL) => {
    const client = await pool.connect();
    try {
      const result = await client.query(
        "SELECT table_name, column_name, data_type FROM information_schema.columns WHERE table_schema = 'public' ORDER BY table_name, ordinal_position"
      );
      const lines = result.rows.map(
        (r: any) => `${r.table_name}.${r.column_name} ${r.data_type}`
      );
      return {
        contents: [{ uri: uri.href, text: lines.join("\n") }],
      };
    } finally {
      client.release();
    }
  }
);

server.registerTool(
  "query",
  {
    title: "SQL Query",
    description: "Execute a read-only SQL query",
    inputSchema: { sql: z.string() },
  },
  async ({ sql }) => {
    const client = await pool.connect();
    try {
      const result = await client.query(sql);
      return {
        content: [{ type: "text", text: JSON.stringify(result.rows, null, 2) }],
      };
    } catch (err: unknown) {
      return {
        content: [{ type: "text", text: `Error: ${(err as Error).message}` }],
        isError: true,
      };
    } finally {
      client.release();
    }
  }
);

server.registerTool(
  "execute",
  {
    title: "SQL Execute",
    description: "Execute a SQL statement that modifies data",
    inputSchema: { sql: z.string() },
  },
  async ({ sql }) => {
    const client = await pool.connect();
    try {
      const result = await client.query(sql);
      return {
        content: [{ type: "text", text: `Rows affected: ${result.rowCount}` }],
      };
    } catch (err: unknown) {
      return {
        content: [{ type: "text", text: `Error: ${(err as Error).message}` }],
        isError: true,
      };
    } finally {
      client.release();
    }
  }
);

server.registerTool(
  "chat",
  {
    title: "LLM Chat",
    description: "Generate a completion from the local LLM",
    inputSchema: { prompt: z.string() },
  },
  async ({ prompt }) => {
    await llama.load(llamaConfig);
    const params = {
      prompt,
      nThreads: 4,
      nTokPredict: 128,
      topK: 40,
      topP: 0.9,
      temp: 0.7,
      repeatPenalty: 1.1,
    };
    let text = "";
    await llama.createCompletion(params, (res) => {
      text += res.token;
    });
    return { content: [{ type: "text", text }] };
  }
);

async function main() {
  const transport = new StdioServerTransport();
  await llama.load(llamaConfig);
  await server.connect(transport);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
