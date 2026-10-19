#!/usr/bin/env bash
set -euo pipefail

BASE="${LLM_GATEWAY_URL:-http://127.0.0.1:4000}"
KEY="${LITELLM_MASTER_KEY:-${LLM_GATEWAY_KEY:-}}"

if [[ -z "${KEY}" && -f .env ]]; then
  # shellcheck disable=SC1091
  set -a
  # leer solo LITELLM_MASTER_KEY del .env sin source completo si hay caracteres raros
  KEY="$(grep -E '^LITELLM_MASTER_KEY=' .env | cut -d= -f2- | tr -d '\r' || true)"
  set +a
fi

if [[ -z "${KEY}" ]]; then
  echo "Falta LITELLM_MASTER_KEY (exporta la var o define en .env)"
  exit 1
fi

echo "→ POST ${BASE}/v1/chat/completions  model=chat-free"
curl -sS "${BASE}/v1/chat/completions" \
  -H "Authorization: Bearer ${KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "chat-free",
    "messages": [{"role": "user", "content": "Di hola en una frase corta."}],
    "max_tokens": 64
  }' | head -c 2000
echo
echo "OK si viste choices[0].message o un error de provider (key faltante)."
