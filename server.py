import os
import asyncpg
import uuid
from mcp.server.fastmcp import FastMCP

# Initialize FastMCP server focused on database utilities
mcp = FastMCP("database agent", "1.0.0")

# Database connection URL
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://maratron:yourpassword@localhost:5432/maratrondb",
)

# Connection pool placeholder
DB_POOL: asyncpg.Pool | None = None


def _quote_ident(name: str) -> str:
    """Safely quote an SQL identifier."""
    if not name.replace("_", "").isalnum():
        raise ValueError("invalid identifier")
    return f'"{name}"'


async def get_pool() -> asyncpg.Pool:
    """Get or create the asyncpg connection pool."""
    global DB_POOL
    if DB_POOL is None:
        DB_POOL = await asyncpg.create_pool(DATABASE_URL)
    return DB_POOL


@mcp.tool()
async def list_tables() -> str:
    """List all tables in the public schema."""
    pool = await get_pool()
    try:
        rows = await pool.fetch(
            "SELECT table_name FROM information_schema.tables "
            "WHERE table_schema='public' ORDER BY table_name"
        )
    except Exception as e:
        return f"Database error: {e}"

    if not rows:
        return "No tables found."

    return "\n".join(row["table_name"] for row in rows)


@mcp.tool()
async def describe_table(table_name: str) -> str:
    """Describe columns for a table."""
    pool = await get_pool()
    try:
        rows = await pool.fetch(
            "SELECT column_name, data_type FROM information_schema.columns "
            "WHERE table_name=$1 ORDER BY ordinal_position",
            table_name,
        )
    except Exception as e:
        return f"Database error: {e}"

    if not rows:
        return f"Table '{table_name}' not found."

    return "\n".join(f"{r['column_name']}: {r['data_type']}" for r in rows)


@mcp.tool()
async def add_user(name: str, email: str) -> str:
    """Insert a new user into the database."""
    pool = await get_pool()
    user_id = str(uuid.uuid4())
    try:
        await pool.execute(
            'INSERT INTO "Users" (id, name, email, "updatedAt") '
            'VALUES ($1, $2, $3, NOW())',
            user_id,
            name,
            email,
        )
    except Exception as e:
        return f"Database error: {e}"

    return f"Inserted user with id {user_id}."


@mcp.tool()
async def count_rows(table_name: str) -> str:
    """Return the number of rows in a table."""
    pool = await get_pool()
    try:
        ident = _quote_ident(table_name)
        row = await pool.fetchrow(f'SELECT COUNT(*) AS cnt FROM {ident}')
    except Exception as e:
        return f"Database error: {e}"

    return f"{row['cnt']} rows in {table_name}" if row else "Table not found."


@mcp.tool()
async def add_run(user_id: str, date: str, duration: str, distance: float,
                  distance_unit: str = "miles") -> str:
    """Insert a minimal run record."""
    pool = await get_pool()
    run_id = str(uuid.uuid4())
    try:
        await pool.execute(
            'INSERT INTO "Runs" (id, date, duration, distance, "distanceUnit", '
            '"updatedAt", "userId") '
            'VALUES ($1, $2, $3, $4, $5, NOW(), $6)',
            run_id,
            date,
            duration,
            distance,
            distance_unit,
            user_id,
        )
    except Exception as e:
        return f"Database error: {e}"

    return f"Inserted run with id {run_id}."


@mcp.tool()
async def list_recent_runs(limit: int = 5) -> str:
    """List recent runs with date and distance."""
    pool = await get_pool()
    try:
        rows = await pool.fetch(
            'SELECT date, distance, "distanceUnit" FROM "Runs" '
            'ORDER BY date DESC LIMIT $1',
            limit,
        )
    except Exception as e:
        return f"Database error: {e}"

    if not rows:
        return "No runs found."

    return "\n".join(
        f"{row['date'].date()}: {row['distance']} {row['distanceUnit']}"
        for row in rows
    )


@mcp.tool()
async def list_users(limit: int = 10) -> str:
    """List user names from the local database.

    Args:
        limit: Maximum number of users to return.
    """
    pool = await get_pool()
    try:
        rows = await pool.fetch('SELECT name FROM "Users" LIMIT $1', limit)
    except Exception as e:
        return f"Database error: {e}"

    if not rows:
        return "No users found."

    names = [row["name"] for row in rows]
    return "\n".join(names)


@mcp.tool()
async def find_user(user_id: str | None = None, email: str | None = None) -> str:
    """Retrieve a user's basic information by id or email."""
    if not user_id and not email:
        return "Provide user_id or email."

    pool = await get_pool()
    query = 'SELECT id, name, email FROM "Users" WHERE '
    params = []
    if user_id:
        query += 'id=$1'
        params.append(user_id)
    else:
        query += 'email=$1'
        params.append(email)

    try:
        row = await pool.fetchrow(query, *params)
    except Exception as e:
        return f"Database error: {e}"

    if row is None:
        return "User not found."
    return f"{row['id']}: {row['name']} <{row['email']}>"


@mcp.tool()
async def list_user_contacts(limit: int = 20) -> str:
    """List user ids and emails."""
    pool = await get_pool()
    try:
        rows = await pool.fetch(
            'SELECT id, email FROM "Users" ORDER BY "createdAt" DESC LIMIT $1',
            limit,
        )
    except Exception as e:
        return f"Database error: {e}"

    if not rows:
        return "No users found."

    return "\n".join(f"{row['id']}: {row['email']}" for row in rows)


@mcp.tool()
async def get_user(user_id: str) -> str:
    """Retrieve a user's basic information."""
    pool = await get_pool()
    try:
        row = await pool.fetchrow(
            'SELECT name, email FROM "Users" WHERE id=$1',
            user_id,
        )
    except Exception as e:
        return f"Database error: {e}"

    if row is None:
        return "User not found."
    return f"{row['name']} <{row['email']}>"


@mcp.tool()
async def update_user_email(user_id: str, email: str) -> str:
    """Update a user's email address."""
    pool = await get_pool()
    try:
        result = await pool.execute(
            'UPDATE "Users" SET email=$1, "updatedAt"=NOW() WHERE id=$2',
            email,
            user_id,
        )
    except Exception as e:
        return f"Database error: {e}"

    if result.endswith("0"):
        return "User not found."
    return "User updated."


@mcp.tool()
async def delete_user(user_id: str) -> str:
    """Delete a user by id."""
    pool = await get_pool()
    try:
        result = await pool.execute('DELETE FROM "Users" WHERE id=$1', user_id)
    except Exception as e:
        return f"Database error: {e}"

    if result.endswith("0"):
        return "User not found."
    return "User deleted."


@mcp.tool()
async def add_shoe(
    user_id: str,
    name: str,
    max_distance: float,
    distance_unit: str = "miles",
) -> str:
    """Insert a new shoe for a user."""
    pool = await get_pool()
    shoe_id = str(uuid.uuid4())
    try:
        await pool.execute(
            'INSERT INTO "Shoes" (id, name, "maxDistance", "distanceUnit", '
            '"updatedAt", "userId") '
            'VALUES ($1, $2, $3, $4, NOW(), $5)',
            shoe_id,
            name,
            max_distance,
            distance_unit,
            user_id,
        )
    except Exception as e:
        return f"Database error: {e}"

    return f"Inserted shoe with id {shoe_id}."


@mcp.tool()
async def list_shoes(user_id: str, include_retired: bool = False) -> str:
    """List shoes for a user."""
    pool = await get_pool()
    query = (
        'SELECT id, name, retired FROM "Shoes" WHERE "userId"=$1'
        + ("" if include_retired else " AND retired=false")
        + ' ORDER BY "createdAt" DESC'
    )
    try:
        rows = await pool.fetch(query, user_id)
    except Exception as e:
        return f"Database error: {e}"

    if not rows:
        return "No shoes found."

    return "\n".join(
        f"{row['id']}: {row['name']}{' (retired)' if row['retired'] else ''}"
        for row in rows
    )


@mcp.tool()
async def list_runs_for_user(user_id: str, limit: int = 5) -> str:
    """List recent runs for a specific user."""
    pool = await get_pool()
    try:
        rows = await pool.fetch(
            'SELECT date, distance, "distanceUnit" FROM "Runs" '
            'WHERE "userId"=$1 ORDER BY date DESC LIMIT $2',
            user_id,
            limit,
        )
    except Exception as e:
        return f"Database error: {e}"

    if not rows:
        return "No runs found."

    return "\n".join(
        f"{row['date'].date()}: {row['distance']} {row['distanceUnit']}"
        for row in rows
    )


@mcp.tool()
async def list_running_plans(user_id: str) -> str:
    """List running plans for a user."""
    pool = await get_pool()
    try:
        rows = await pool.fetch(
            'SELECT id, name, weeks, active FROM "RunningPlans" '
            'WHERE "userId"=$1 ORDER BY "createdAt" DESC',
            user_id,
        )
    except Exception as e:
        return f"Database error: {e}"

    if not rows:
        return "No plans found."

    return "\n".join(
        f"{row['id']}: {row['name']} ({row['weeks']} weeks)" +
        (" [active]" if row['active'] else "")
        for row in rows
    )


@mcp.tool()
async def add_running_plan(
    user_id: str,
    name: str,
    weeks: int,
    plan_data: str,
    start_date: str | None = None,
) -> str:
    """Add a running plan for a user."""
    pool = await get_pool()
    plan_id = str(uuid.uuid4())
    try:
        await pool.execute(
            'INSERT INTO "RunningPlans" (id, "userId", name, weeks, "planData", "startDate", "updatedAt") '
            'VALUES ($1, $2, $3, $4, $5::jsonb, $6, NOW())',
            plan_id,
            user_id,
            name,
            weeks,
            plan_data,
            start_date,
        )
    except Exception as e:
        return f"Database error: {e}"

    return f"Inserted running plan with id {plan_id}."


@mcp.tool()
async def db_summary() -> str:
    """Return row counts for all tables."""
    pool = await get_pool()
    try:
        tables = await pool.fetch(
            "SELECT table_name FROM information_schema.tables "
            "WHERE table_schema='public'"
        )
    except Exception as e:
        return f"Database error: {e}"

    lines = []
    for row in tables:
        tname = row["table_name"]
        try:
            ident = _quote_ident(tname)
            count_row = await pool.fetchrow(
                f'SELECT COUNT(*) AS cnt FROM {ident}'
            )
            count = count_row["cnt"] if count_row else 0
        except Exception:
            count = "error"
        lines.append(f"{tname}: {count}")

    return "\n".join(lines)


if __name__ == "__main__":
    # Initialize and run the server
    mcp.run(transport='stdio')
