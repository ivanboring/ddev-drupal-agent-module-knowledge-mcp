# MCP server image for the DDEV add-on.
# Contains the server + embedder + PRE-BAKED model. The docs.db is NOT baked in —
# it is provided at runtime via a volume mount (downloaded by the add-on's install.yaml).
FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1 \
    HF_HOME=/opt/hf

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Pre-download the embedding model into the image so runtime needs no network.
RUN python -c "from model2vec import StaticModel; StaticModel.from_pretrained('minishlab/potion-retrieval-32M')"

COPY embed.py server.py indexer.py ./

# From here on, never reach out to HuggingFace — use the cached model only.
ENV HF_HUB_OFFLINE=1 \
    DOCS_DB=/data/docs.db

EXPOSE 9130

# Non-root for defense in depth.
RUN useradd -m appuser && chown -R appuser /app
USER appuser

CMD ["python", "server.py", "--http", "--host", "0.0.0.0", "--port", "9130"]
