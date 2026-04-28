# Integration Tools Overview

<!-- Версия: 1.0 | Обновлено: 2026-04-28 | Платформа: BPMSoft 1.9 -->
<!-- Теги: IntegrationTools, Webhook, ServiceDesigner, WebServiceV2, integrations -->

> Входная точка в Integration Tools Dive. Документ описывает два близких
> конструктора интеграций: `Webhook V2` и `Web Service V2 / ServiceDesigner`.

## Что входит в блок

| Контур | Назначение |
| ------ | ---------- |
| `Webhook` | конструктор Webhook V2, методы, параметры, action rules, auth settings |
| `ServiceDesigner` | конструктор исходящих Web Service V2, REST/SOAP methods, request/response parameters |
| runtime schema managers | `WebhookSchemaManager`, `ServiceSchemaManager` |
| runtime execution | `WebhookService` для auth/token UI, `CallServiceSchemaService` и `IServiceSchemaClient` для Web Service V2 |

Это не OCC webhook pipeline. OCC описывает входящие webhooks омниканальных
каналов, а Integration Tools - настраиваемые интеграционные схемы и дизайнеры.

## Документы пакета

| Документ | Назначение |
| -------- | ---------- |
| [webhook-v2-overview.md](webhook-v2-overview.md) | модель, UI и auth Webhook V2 |
| [webservice-v2-overview.md](webservice-v2-overview.md) | Web Service V2, REST/SOAP designer и runtime call |
| [integration-tools-runtime.md](integration-tools-runtime.md) | managers, auth, service calls и process boundary |
| [integration-tools-boundaries.md](integration-tools-boundaries.md) | границы с Services, OCC, Auth, Process, ExternalAccess |
| [integration-tools-pattern-catalog.md](integration-tools-pattern-catalog.md) | рабочие паттерны Webhook/ServiceDesigner |
| [integration-tools-troubleshooting.md](integration-tools-troubleshooting.md) | диагностика designer, rights, auth, test calls |

## Быстрый выбор

| Задача | Документ |
| ------ | -------- |
| Разобрать Webhook V2 | [webhook-v2-overview.md](webhook-v2-overview.md) |
| Настроить Web Service V2 | [webservice-v2-overview.md](webservice-v2-overview.md) |
| Понять runtime-вызов service schema | [integration-tools-runtime.md](integration-tools-runtime.md) |
| Отличить от OCC webhook | [integration-tools-boundaries.md](integration-tools-boundaries.md) |
| Найти паттерн builder/converter/auth | [integration-tools-pattern-catalog.md](integration-tools-pattern-catalog.md) |
| Диагностировать ошибку | [integration-tools-troubleshooting.md](integration-tools-troubleshooting.md) |

## Ключевые source files

| Область | Файлы |
| ------- | ----- |
| Webhook model | `VwWebhookV2Schema.Webhook.cs`, `WebhookV2FolderSchema.Webhook.cs`, `WebhookV2TagSchema.Webhook.cs` |
| Webhook UI | `WebhookDesigner.Webhook.js`, `WebhookV2Page.Webhook.js`, `WebhookMethodDetail.Webhook.js` |
| Webhook auth | `WebhookAuthInfoSettingsPage.Webhook.js`, `WebhookTokenGeneratorSchema.Webhook.js`, `JWTTokenExpirationNotification.Webhook.cs` |
| Webhook builders | `JsonWebhookRequestBuilder.Webhook.js`, `JsonWebhookResponseBuilder.Webhook.js`, `WebhookMethodBuilder.Webhook.js` |
| Web Service model | `VwWebServiceV2Schema.ServiceDesigner.cs`, `WebServiceV2*Schema.ServiceDesigner.cs` |
| Web Service UI | `WebServicesDesigner.ServiceDesigner.js`, `RestWebServiceV2Page.ServiceDesigner.js`, `SoapWebServiceV2Page.ServiceDesigner.js` |
| Web Service runtime | `CallServiceSchemaService.ServiceDesigner.cs`, `ServiceSchemaClient.ServiceDesigner.cs`, `ServiceSchemaParameterBuilder.ServiceDesigner.cs` |
| Web Service builders | `JsonRequestBuilder.ServiceDesigner.js`, `RawRequestBuilder.ServiceDesigner.js`, `CurlRequestBuilder.ServiceDesigner.js` |

## Связанные документы

- [Services Overview](services-overview.md)
- [Services Outgoing REST](services-outgoing-rest.md)
- [Auth OAuth 2.0 Apps Tokens](auth-oauth20-apps-tokens.md)
- [OCC Omnichannel Overview](occ-omnichannel-overview.md)
- [Process Overview](process-overview.md)
