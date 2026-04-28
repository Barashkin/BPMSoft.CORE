# Integration Tools Boundaries

<!-- Версия: 1.2 | Обновлено: 2026-04-28 | Платформа: BPMSoft 1.9 -->
<!-- Теги: IntegrationTools, boundaries, Webhook, ServiceDesigner, OCC, Auth -->

> Границы Integration Tools Dive: что относится к Webhook V2 и Web Service V2,
> а что должно оставаться в соседних документационных блоках.

## Внутри Integration Tools

К этому dive относятся:

- `VwWebhookV2`, `WebhookDesigner`, `WebhookV2Page`, webhook methods/parameters;
- webhook auth UI, JWT token generation flow, JWT expiration reminders;
- `VwWebServiceV2`, `WebServicesDesigner`, REST/SOAP service pages;
- request/response builders, converters, parameter grids;
- `CallServiceSchemaService`, `IServiceSchemaClient`,
  `IServiceSchemaParameterBuilder`;
- граница с `WebhookSchemaManager` и `ServiceSchemaManager`.

## Services Dive

Services Dive описывает WCF/REST как платформенный механизм: `[ServiceContract]`,
`WebInvoke`, routes, response models и client calls.

Integration Tools описывает metadata-driven designers и execution через schema
managers. Для Web Service V2 не нужно писать новый WCF-класс на каждый внешний
method: schema сохраняет metadata, а runtime вызывает её через
`ServiceSchemaManager`.

## OCC

OCC webhooks - это входящие callbacks каналов и connector pipeline:
`BPMSoftOCCChatRequestService`, request handlers, status callbacks, routing.

Webhook V2 в Integration Tools - отдельный конструктор webhook schemas,
actions, auth и методов. Не смешивайте OCC request pipeline с Webhook designer.

## Auth / OAuth

Auth Dive покрывает платформенные OAuth applications, tokens, SSO, SAML/OIDC и
sessions.

Integration Tools auth settings описывают credentials для конкретного webhook
или web service:

- Webhook: `None`, `Basic`, `JWT`;
- Web Service V2: `None`, `Basic`, `Digest`, `OAuth20`.

OAuth20 в ServiceDesigner - это способ авторизации исходящего вызова, а не
регистрация пользователя или portal login.

Подробное разделение OAuth20Integration и ServiceDesigner auth type описано в
[Auth OAuth20 Boundaries](auth-oauth20-boundaries.md).

## Process

Process Dive описывает execution engine, parameters, logs и user tasks.

Integration Tools касается Process только в точках:

- webhook action rule `START_BP`;
- runtime-вызов настроенного service schema из custom/process logic;
- процесс `JWTTokenExpirationNotification` как housekeeping вокруг JWT.

## ExternalAccess / SSP

ExternalAccess и SSP описывают внешний доступ к порталу, временные ссылки и
portal mobile сценарии.

Webhook endpoints и service schemas - другой механизм. Даже если integration
URL публичный, это не делает его частью ExternalAccess.

## Scheduler / Queues

Quartz/Scheduler Dive покрывает jobs, triggers и recovery. Integration Tools не
вводит отдельный scheduler-контур, кроме связанных процессов/напоминаний,
например JWT expiration notification.

## IntegrationV2

Пакет `IntegrationV2` в найденном коде относится в основном к Exchange,
MailboxSettings, MeetingService и ActivityParticipant. Это календарные/email
интеграции, а не Webhook V2 или ServiceDesigner.

Подробности по этому контуру вынесены в
[Mailbox Exchange Sync Overview](mailbox-exchange-sync-overview.md).

## Связанные документы

- [Integration Tools Overview](integration-tools-overview.md)
- [Services Overview](services-overview.md)
- [OCC Omnichannel Overview](occ-omnichannel-overview.md)
- [Auth OAuth 2.0 Apps Tokens](auth-oauth20-apps-tokens.md)
- [Auth OAuth20 Boundaries](auth-oauth20-boundaries.md)
- [Mailbox Exchange Sync Overview](mailbox-exchange-sync-overview.md)
- [Process Overview](process-overview.md)
