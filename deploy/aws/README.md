# Despliegue AWS (primario)

Sitio **aws** del diseño multi-sitio. Objetivo: endpoint always-on para chats/servicios.

## Opciones (de más simple a más “prod”)

1. **EC2 / Lightsail** + Docker Compose (rápido de validar).
2. **ECS Fargate** + task definition con imagen `ghcr.io/berriai/litellm:main-latest`.
3. ALB delante + certificado ACM (HTTPS).

## Variables

| Var | Uso |
|-----|-----|
| `LITELLM_MASTER_KEY` | Auth del proxy (distinta de local) |
| `GROQ_API_KEY` / `GEMINI_API_KEY` / `OPENROUTER_API_KEY` | Cascada |
| `DATABASE_URL` | Opcional Postgres (spend / virtual keys) |

Montar `config/aws.yaml` como `/app/config.yaml`.

## Checklist

- [ ] Instancia o servicio always-on (no scale-to-zero que duerma el gateway)
- [ ] Security group: 443 (o 4000 solo desde VPC/ALB)
- [ ] Secrets en SSM Parameter Store o Secrets Manager
- [ ] Health check HTTP al path de liveness de LiteLLM
- [ ] Documentar URL pública: `https://gateway-aws.<dominio>/v1`

## Failover hacia réplica

En una fase posterior: health checks desde la app o DNS (Route53 failover) apuntando a **replica** (GCP/Oracle) si AWS no responde.
