FROM ghcr.io/astral-sh/uv:0.12.21-python3.13-trixie-slim

WORKDIR /app

ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy

COPY pyproject.toml uv.lock ./
RUN uv sync --locked --no-install-project

COPY tests ./tests
COPY sql/queries.sql ./sql/queries.sql

CMD ["uv", "run", "--no-sync", "pytest"]
