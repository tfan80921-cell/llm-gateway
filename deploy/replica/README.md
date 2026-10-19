# Despliegue réplica (GCP o Oracle Cloud)

Sitio **replica** del diseño multi-sitio. Misma API lógica (`chat-free`), otro proveedor de nube.

## Por qué existe

Si el primario **AWS** tiene incidente regional o de cuenta, las apps pueden apuntar (manual o automático) a este endpoint.

## Opciones

| Cloud | Notas |
|-------|--------|
| **Oracle Cloud** Free Tier | VM always-on posible; buen candidato de presupuesto bajo |
| **GCP** | Cloud Run *no* ideal si escala a cero; preferir GCE o Cloud Run min instances ≥ 1 |

## Config

- Imagen: `ghcr.io/berriai/litellm:main-latest`
- Config: `config/replica.yaml`
- `LITELLM_MASTER_KEY` **distinta** de local y de AWS (o virtual keys por sitio)

## Checklist

- [ ] Elegir GCP vs Oracle
- [ ] VM/contenedor always-on
- [ ] HTTPS (Caddy/Nginx o LB del cloud)
- [ ] Smoke: `scripts/smoke-chat.sh` con `LLM_GATEWAY_URL=https://…`
- [ ] Documentar URL: `https://gateway-replica.<dominio>/v1`

## Apps

Cotorr/prod puede tener:

```bash
LLM_GATEWAY_URL=https://gateway-aws.../v1
LLM_GATEWAY_URL_FALLBACK=https://gateway-replica.../v1   # fase HA en la app
```

La implementación del fallback en cliente es Fase posterior; el **diseño** ya reserva el segundo sitio.
