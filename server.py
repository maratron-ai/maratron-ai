import os
from contextlib import asynccontextmanager
from dataclasses import dataclass
from typing import Any, AsyncIterator

import asyncpg
from mcp.server.fastmcp import Context, FastMCP


@dataclass
class AppContext:
    pool: asyncpg.Pool


async def create_pool() -> asyncpg.Pool:
    return await asyncpg.create_pool(
        host=os.getenv("PGHOST", "localhost"),
        port=int(os.getenv("PGPORT", "5432")),
        user=os.getenv("PGUSER", "postgres"),
        password=os.getenv("PGPASSWORD", ""),
        database=os.getenv("PGDATABASE", "postgres"),
    )


@asynccontextmanager
async def lifespan(app: FastMCP) -> AsyncIterator[AppContext]:
    pool = await create_pool()
    # Ensure chat table exists
    async with pool.acquire() as conn:
        await conn.execute(
            """CREATE TABLE IF NOT EXISTS messages (
                   id SERIAL PRIMARY KEY,
                   chat_id TEXT NOT NULL,
                   sender TEXT NOT NULL,
                   content TEXT NOT NULL,
                   created_at TIMESTAMP DEFAULT NOW()
               )"""
        )
    try:
        yield AppContext(pool=pool)
    finally:
        await pool.close()


mcp = FastMCP("Chat Server", lifespan=lifespan)


@mcp.tool()
async def send_message(chat_id: str, sender: str, content: str, ctx: Context) -> str:
    """Store a chat message in the database."""
    pool = ctx.request_context.lifespan_context.pool
    await pool.execute(
        "INSERT INTO messages (chat_id, sender, content) VALUES ($1,$2,$3)",
        chat_id,
        sender,
        content,
    )
    return "Message stored"


@mcp.tool()
async def list_chats(ctx: Context) -> list[str]:
    """List all active chat IDs."""
    pool = ctx.request_context.lifespan_context.pool
    rows = await pool.fetch("SELECT DISTINCT chat_id FROM messages ORDER BY chat_id")
    return [r["chat_id"] for r in rows]


@mcp.resource("chat://{chat_id}")
async def get_chat(chat_id: str) -> list[dict[str, Any]]:
    """Retrieve all messages for a chat ID."""
    ctx = mcp.get_context()
    pool = ctx.request_context.lifespan_context.pool
    rows = await pool.fetch(
        "SELECT id, sender, content, created_at FROM messages WHERE chat_id=$1 ORDER BY id",
        chat_id,
    )
    return [dict(row) for row in rows]


if __name__ == "__main__":
    mcp.run()
