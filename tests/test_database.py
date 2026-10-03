from collections.abc import AsyncIterator
from datetime import date
from decimal import Decimal
import os

import aiomysql
import pytest_asyncio


@pytest_asyncio.fixture
async def pool() -> AsyncIterator[aiomysql.Pool]:
    connection_pool = await aiomysql.create_pool(
        host=os.environ["MYSQL_HOST"],
        port=int(os.environ.get("MYSQL_PORT", "3306")),
        user=os.environ["MYSQL_USER"],
        password=os.environ["MYSQL_PASSWORD"],
        db=os.environ["MYSQL_DATABASE"],
        autocommit=True,
        minsize=1,
        maxsize=2,
    )
    try:
        yield connection_pool
    finally:
        connection_pool.close()
        await connection_pool.wait_closed()


async def test_schema_uses_expected_tables_and_account_id_type(pool: aiomysql.Pool) -> None:
    async with pool.acquire() as connection:
        async with connection.cursor() as cursor:
            await cursor.execute("SHOW TABLES")
            tables = {row[0] for row in await cursor.fetchall()}

            await cursor.execute("SHOW COLUMNS FROM accounts LIKE 'account_id'")
            account_id = await cursor.fetchone()

    assert {"accounts", "balances", "dates"} <= tables
    assert account_id is not None
    assert account_id[1] == "smallint unsigned"
    assert account_id[5] == "auto_increment"


async def test_example_snapshot_has_expected_monthly_total(pool: aiomysql.Pool) -> None:
    async with pool.acquire() as connection:
        async with connection.cursor() as cursor:
            await cursor.execute(
                """
                SELECT
                  b.`date`,
                  SUM(CASE WHEN a.account_type = 'asset' THEN b.amount ELSE 0 END),
                  SUM(CASE WHEN a.account_type = 'liability' THEN b.amount ELSE 0 END),
                  SUM(CASE
                        WHEN a.account_type = 'asset' THEN b.amount
                        WHEN a.account_type = 'liability' THEN -b.amount
                      END)
                FROM balances AS b
                JOIN accounts AS a ON a.account_id = b.account_id
                GROUP BY b.`date`
                """
            )
            snapshot = await cursor.fetchone()

    assert snapshot == (
        date(2026, 9, 14),
        Decimal("97500.00"),
        Decimal("211800.00"),
        Decimal("-114300.00"),
    )
