# Alineación KPIs ↔ este gateway

El contrato completo de los **4 pilares** (costo, uso técnico, negocio, calidad), eventos estructurados y Grafana está en:

**https://github.com/tfan80921-cell/wayuunlingo/blob/main/docs/KPI_FRAMEWORK.md**

## Rol de llm-gateway

| Pilar | Qué aporta LiteLLM aquí |
|-------|-------------------------|
| COSTO | Tokens y spend por modelo/proveedor (fuente de verdad técnica) |
| USO TÉCNICO | Modelo efectivo post-cascada, fallos upstream, latencia del hop proxy |
| NEGOCIO / CALIDAD | No aplica — viven en Cotorr y demás productos |

Multi-sitio (`local` / `aws` / `replica`): si exportas métricas, etiqueta o separa datasources por sitio para no mezclar dev y prod.
