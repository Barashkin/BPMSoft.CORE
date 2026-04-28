# Mailbox Exchange Data Model Settings

<!-- Версия: 1.0 | Обновлено: 2026-04-28 | Платформа: BPMSoft 1.9 -->
<!-- Теги: MailboxSyncSettings, MailServer, ActivitySyncSettings, ContactSyncSettings -->

> Модель данных для mailbox sync: базовые настройки почтового ящика,
> Exchange-расширения, папки, server type и sync settings для Activity/Contact.

## MailboxSyncSettings Base

`MailboxSyncSettingsSchema.Base.cs` задаёт базовую entity:

- наследуется от `BaseEntitySchema`;
- primary display column - `UserName`;
- owner column - `CreatedBy`;
- `SysAdminUnit` по умолчанию равен текущему пользователю;
- `UserPassword` хранится как `SecureText`;
- `EnableMailSynhronization` по умолчанию `true`;
- содержит поля для IMAP/SMTP, подписи, OAuth token, ошибок и retry.

Ключевые колонки:

| Колонка | Назначение |
| ------- | ---------- |
| `SysAdminUnit` | владелец ящика |
| `MailServer` | провайдер/сервер |
| `UserName` / `MailboxName` | login/mailbox name |
| `UserPassword` | secure password |
| `SenderEmailAddress` | email-адрес отправителя |
| `EnableMailSynhronization` | включить синхронизацию |
| `AutomaticallyAddNewEmails` | добавлять новые письма |
| `CyclicallyAddNewEmails` | циклическая загрузка |
| `EmailsCyclicallyAddingInterval` | интервал |
| `LastSyncDate` | последняя синхронизация |
| `OAuthTokenStorage` | ссылка на OAuth token storage |
| `RetryCounter` | счётчик повторов |
| `ErrorCode` / `LastError` | ошибка синхронизации |
| `SynchronizationStopped` | sync остановлен после ошибки |

## Exchange extension

`MailboxSyncSettingsSchema.Exchange.cs` расширяет базовую схему:

| Колонка | Назначение |
| ------- | ---------- |
| `MailSyncPeriod` | период синхронизации |
| `ExchangeAutoSynchronization` | автосинхронизация Exchange |
| `ExchangeSyncInterval` | интервал почты |
| `ContactSyncInterval` | интервал контактов |
| `ExchangeAutoSyncActivity` | автосинхронизация календаря/активностей |
| `SyncDateMinutesOffset` | offset даты синхронизации, default `5` |

`EmailsCyclicallyAddingInterval` переопределяется так, чтобы брать default из
system setting `MailboxSyncInterval`.

## Settings by domain

| Схема | Назначение |
| ----- | ---------- |
| `ActivitySyncSettingsSchema.Exchange.cs` | импорт/экспорт встреч, задач и календарей |
| `ContactSyncSettingsSchema.Exchange.cs` | импорт/экспорт контактов |
| `MailboxFoldersCorrespondenceSchema.Exchange.cs` | соответствие remote folders и локальных folders |
| `MailboxContactFolderSchema.Exchange.cs` | папки контактов mailbox |
| `MailSyncPeriodSchema.Exchange.cs` | справочник периодов |
| `MailServerSchema.Exchange.cs` | параметры mail server/Exchange |
| `MailServerTypeSchema.Exchange.cs` | типы mail server |

## Listener extension

`MailboxSyncSettingsSchema.ExchangeListener.cs` добавляет listener-specific
поля и events process для обслуживания настроек listener-синхронизации.

## Ошибки и retries

`SynchronizationStopped`, `RetryCounter` и `ErrorCode` важны для `MailSyncJob`.
Job ищет включённые mailbox settings, у которых синхронизация остановлена, и
сбрасывает эти поля для повторной попытки.

## Связанные документы

- [Mailbox Exchange Sync Overview](mailbox-exchange-sync-overview.md)
- [Mailbox Exchange Runtime Jobs](mailbox-exchange-runtime-jobs.md)
- [Activity Mailbox Sync](activity-mailbox-sync.md)
- [Security Schema Record Rights](security-schema-record-rights.md)
