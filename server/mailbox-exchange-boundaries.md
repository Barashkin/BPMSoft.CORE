# Mailbox Exchange Boundaries

<!-- Версия: 1.1 | Обновлено: 2026-04-28 | Платформа: BPMSoft 1.9 -->
<!-- Теги: MailboxSyncSettings, boundaries, Exchange, EmailMining, Activity -->

> Границы Mailbox / Exchange / Calendar Sync Dive с соседними подсистемами.

## Внутри этого dive

К этому разделу относятся:

- `MailboxSyncSettings` и Exchange/Listener extensions;
- IMAP/Exchange validation и mailbox services;
- `MailSyncJob`, sync jobs и generated sync processes;
- Exchange listener endpoints и listener lifecycle;
- Office 365 OAuth для mailbox integration;
- calendar/meeting services `IntegrationV2`;
- mailbox settings UI и meeting invitations UI.

## Activity

Activity Dive описывает сущность `Activity`, email fields, participants,
attachments и отправку писем.

Mailbox sync создаёт/обновляет email activities, встречи и participant state.
Подробности runtime-синхронизации остаются здесь, а модель Activity - в Activity
документах.

## Email Mining

Email Mining начинается после появления email `Activity`.

Mailbox sync отвечает за доставку/создание активности и dedup по `MailHash`.
Email Mining отвечает за cloud parsing, enrichment, `EnrchEmailData`,
`EnrchTextEntity` и изменение `EnrichStatus`.

## Quartz / Scheduler

Quartz Dive описывает общий API jobs/triggers.

Этот dive описывает только domain-specific jobs:

- `MailSyncJob`;
- IMAP jobs через `IImapSyncJobScheduler`;
- Exchange jobs через `ISyncJobScheduler`;
- generated process names для mail/contact/activity sync.

## Auth / OAuth

Auth Dive описывает platform OAuth entities, tokens, SSO and sessions.

Office 365 OAuth в этом dive - mailbox-specific flow, который создаёт
`MailboxSyncSettings`, `ContactSyncSettings` и `ActivitySyncSettings`.

Подробная граница с OAuth20Integration описана в
[Auth OAuth20 Boundaries](auth-oauth20-boundaries.md).

## Integration Tools

Integration Tools Dive описывает Webhook V2 и Web Service V2 designers.

Exchange mailbox sync не является частью Integration Tools: здесь нет
`WebhookSchemaManager`, `ServiceSchemaManager` или `CallServiceSchemaService`.
Общее только то, что оба контура интегрируются с внешними системами.

## NUI / UI

NUI Dive описывает серверные endpoints для grid/workplace/audit/approval.

Mailbox UI использует NUI/UIv2 modules и services, но бизнес-смысл этих modules
относится к mailbox sync.

## Связанные документы

- [Mailbox Exchange Sync Overview](mailbox-exchange-sync-overview.md)
- [Activity Mailbox Sync](activity-mailbox-sync.md)
- [Email Mining Mailbox Sync](email-mining-mailbox-sync.md)
- [Quartz Class Jobs](quartz-class-jobs.md)
- [Auth OAuth20 Apps And Tokens](auth-oauth20-apps-tokens.md)
- [Auth OAuth20 Boundaries](auth-oauth20-boundaries.md)
- [Integration Tools Boundaries](integration-tools-boundaries.md)
