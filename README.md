# llm-gateway

**LiteLLM Proxy** como gateway canónico multi-proveedor (cascada / fallback, orientado a free tiers + keys propias).

Usado por [cotorr](https://github.com/tfan80921-cell/cotorr) y, más adelante, el resto de productos. La **venta al cliente** vive en cada producto; este repo solo opera tokens y enrutado.

Plan de producto (Cotorr): [docs/LLM_GATEWAY_PLAN.md](https://github.com/tfan80921-cell/cotorr/blob/main/docs/LLM_GATEWAY_PLAN.md)

---

## Diseño multi-sitio (mínimo 3)

Desde el día 1 el despliegue contempla **tres contextos** independientes (misma familia de config, secrets distintos):

| Sitio | Rol | Runtime típico |
|-------|-----|----------------|
| **local** | Desarrollo en portátil | Docker Compose en el laptop |
| **aws** | Producción primaria (chats / servicios) | ECS/EC2/Lightsail + opcional ALB |
| **replica** | Continuidad si AWS falla | **GCP** o **Oracle Cloud** (Free Tier posible) |

```text
        ┌──────────── local (dev) ────────────┐
Cotorr ─┤                                     ├─► proveedores
 / apps ┤  aws (primario)                      │
        └─ replica (GCP u Oracle) ────────────┘
```

- Cada sitio tiene su propio `LITELLM_MASTER_KEY` y API keys de proveedores (o las mismas keys con presupuestos distintos).
- Las apps eligen endpoint por entorno (`LLM_GATEWAY_URL`), no un solo DNS mágico al inicio.
- Más adelante: DNS failover / health checks entre **aws** y **replica** (Fase HA).

---

## Estructura del repo

```text
config/
  base.yaml           # modelos y cascada compartida (referencia)
  local.yaml          # overrides locales
  aws.yaml            # prod primaria
  replica.yaml        # segundo cloud
docker-compose.yml    # local (y plantilla)
deploy/
  aws/                # notas / plantillas AWS
  replica/            # notas GCP u Oracle
.env.example
scripts/
  smoke-chat.sh       # prueba /v1/chat/completions
```

---

## Arranque local (Fase 1a)

**Requisitos:** Docker, keys opcionales (`GROQ_API_KEY`, `GEMINI_API_KEY`, `OPENROUTER_API_KEY`). Con al menos una key la cascada tiene sentido.

```bash
cp .env.example .env
# Editar .env — mínimo LITELLM_MASTER_KEY y una provider key

docker compose up -d
./scripts/smoke-chat.sh
```

- Proxy: `http://127.0.0.1:4000`
- Modelo lógico de cascada: **`chat-free`**
- UI admin (si está habilitada en la imagen): ver docs LiteLLM; auth con `LITELLM_MASTER_KEY`

Cotorr (cuando Fase 2):

```bash
LLM_GATEWAY_ENABLED=true
LLM_GATEWAY_URL=http://127.0.0.1:4000/v1
LLM_GATEWAY_KEY=<mismo LITELLM_MASTER_KEY o virtual key>
```

---

## Cascada por defecto (`chat-free`)

Orden orientativo (ajustable en `config/*.yaml`):

1. Groq (rápido / free tier)  
2. Gemini  
3. OpenRouter (ruta free si aplica)  

Si un escalón falla (429/5xx), LiteLLM prueba el siguiente (`order` + retries).

---

## AWS y réplica

Ver `deploy/aws/README.md` y `deploy/replica/README.md`.

Principios:

- Misma imagen Docker oficial LiteLLM.
- Config montada o embebida por entorno (`aws.yaml` / `replica.yaml`).
- **Always-on** (sin free tier que duerma el proceso).
- Health: `GET /health` o `/health/liveliness` según versión.
- No compartir `master_key` entre local y prod.

---

## Seguridad

- Nunca commitear `.env` ni keys reales.
- `LITELLM_MASTER_KEY` distinto en local / aws / replica.
- En cloud: solo HTTPS público; DB/Redis privados.

---

## Estado

| Fase | Estado |
|------|--------|
| Repo + config + Compose local | En curso |
| Smoke local | Tras `docker compose up` |
| AWS primario | Plantilla en `deploy/aws` |
| Réplica GCP/Oracle | Plantilla en `deploy/replica` |
| Integración Cotorr | Tras smoke local verde |
