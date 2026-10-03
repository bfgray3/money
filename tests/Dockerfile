FROM ghcr.io/astral-sh/uv:0.12.21-python3.13-trixie-slim

WORKDIR /app

ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy

COPY pyproject.toml ./
RUN uv sync --no-install-project

COPY tests ./tests

CMD ["uv", "run", "--no-sync", "pytest"]
