# Multi-sitio: local · AWS · réplica

## Contrato

| Sitio | Variable de ejemplo | Config |
|-------|---------------------|--------|
| local | `http://127.0.0.1:4000/v1` | `config/local.yaml` |
| aws | `https://gateway-aws…/v1` | `config/aws.yaml` |
| replica | `https://gateway-replica…/v1` | `config/replica.yaml` |

Cada sitio es un **proceso LiteLLM independiente**. No es un cluster único multi-región al día 1; es **tres despliegues** con la misma semántica de modelos.

## HA progresiva

1. **Ahora:** tres sitios documentados; operar local + al menos un cloud.
2. **Siguiente:** segundo cloud (replica) siempre on.
3. **Después:** failover automático (DNS o lógica en Cotorr con `URL` + `URL_FALLBACK`).

## Modelo lógico estable

Las apps solo conocen nombres estables:

- `chat-free` — cascada free/barata  

Añadir `chat-paid` u otros en el YAML sin cambiar el código de producto.
