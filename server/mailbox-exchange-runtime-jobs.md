# Mailbox Exchange Runtime Jobs

<!-- Версия: 1.0 | Обновлено: 2026-04-28 | Платформа: BPMSoft 1.9 -->
<!-- Теги: MailboxSyncSettings, Exchange, Quartz, MailSyncJob, ISyncJobScheduler -->

> Runtime и фоновые задания mailbox sync: IMAP/Exchange jobs, процессы
> синхронизации, повторная синхронизация остановленных ящиков и EWS helpers.

## Runtime layers

| Слой | Назначение |
| ---- | ---------- |
| `MailboxSynchronizationSettingsService.NUI` | legacy IMAP validation и job management |
| `MailboxSettingsService.IntegrationV2` | unified mailbox management, IMAP/Exchange jobs |
| `ExchangeSyncService.Exchange` | Exchange folder loading и delete sync triggers |
| `ExchangeUtility.Exchange` | facade над `IExchangeUtility`, EWS service, sync jobs |
| generated processes | process entry points for scheduled sync |

## Создание sync jobs

`MailboxSettingsService.CreateDeleteSyncJob`:

```text
senderEmailAddress
  -> GetMailbox(senderEmailAddress)
  -> check mailbox.OwnerId == CurrentUser.Id
  -> Exchange mailbox: CreateDeleteExchageJobs(...)
  -> IMAP mailbox: CreateDeleteImapJob(...)
```

Для Exchange создаются/удаляются jobs по process names:

| Process name | Назначение |
| ------------ | ---------- |
| `ExchangeUtility.MailSyncProcessName` | загрузка почты |
| `ExchangeUtility.ContactSyncProcessName` | синхронизация контактов |
| `ExchangeUtility.ActivitySyncProcessName` | синхронизация встреч/задач |

Для IMAP используется `IImapSyncJobScheduler`.

## MailSyncJob

`MailSyncJob.MailSync.cs` - class job для повторной синхронизации остановленных
ящиков.

SysSettings:

| SysSetting | Назначение |
| ---------- | ---------- |
| `EnableReSynchronizationMechanism` | включает job |
| `MailReSynchronizationFrequency` | частота job в минутах |

Job выбирает `MailboxSyncSettings`, где:

```text
EnableMailSynhronization = true
SynchronizationStopped = true
```

Затем сбрасывает:

- `SynchronizationStopped = false`;
- `RetryCounter = 0`;
- `ErrorCodeId = null`.

Если частота изменилась, job сам перерегистрирует расписание через
`Register(...)`.

## ExchangeSyncService

`ExchangeSyncService.Exchange.cs` предоставляет WCF endpoints:

| Method | Назначение |
| ------ | ---------- |
| `GetMailboxFolders` | загрузить иерархию folders из Exchange |
| `DeleteSyncTriggers` | удалить Quartz triggers/jobs по email |

`GetMailboxFolders`:

- находит существующий password, если он не передан;
- определяет `UseOAuth` через `OAuthTokenStorageId`;
- создаёт EWS service через `ExchangeUtility.CreateExchangeService`;
- возвращает иерархию folders.

## ExchangeUtility

`ExchangeUtility.Exchange.cs` - static facade над `IExchangeUtility`:

- создаёт `ExchangeService`;
- удаляет sync jobs;
- проверяет существование sync job;
- вызывает `SyncExchangeItems`;
- загружает attachments;
- безопасно привязывает EWS item через `SafeBindItem`.

Ошибки `AccessDenied`, `Mailbox not found` и `Occurrence not found` обработаны
отдельно, чтобы не ломать sync из-за ожидаемых EWS-состояний.

## Generated process entry points

Сгенерированные process-схемы лучше рассматривать как entry points:

- `LoadExchangeEmailsProcess.Exchange.cs`;
- `SyncExchangeActivitiesProcess.Exchange.cs`;
- `SyncExchangeContactsProcess.Exchange.cs`;
- `LoadImapEmailsProcess.Base.cs`;
- `SyncImapMail.Base.cs`.

Их параметры обычно включают `SenderEmailAddress`, result message, flags
reminding/notification и domain-specific sync options.

## Calendar enable process

`EnableNewCalendarSynchronizationProcess.IntegrationV2.cs` массово включает или
отключает calendar sync:

- получает mailboxes через `IMailboxService`;
- при `SyncPeriod = -1` удаляет calendar sync job;
- иначе включает `ActivitySyncSettings.ImportAppointments` и
  `ExportActivities`;
- пересоздаёт job через `ISyncJobScheduler.CreateSyncJob`.

## Связанные документы

- [Mailbox Exchange Sync Overview](mailbox-exchange-sync-overview.md)
- [Mailbox Exchange Data Model Settings](mailbox-exchange-data-model-settings.md)
- [Quartz Class Jobs](quartz-class-jobs.md)
- [Quartz AppScheduler API](quartz-appscheduler-api.md)
- [Process Runtime Schema](process-runtime-schema.md)
