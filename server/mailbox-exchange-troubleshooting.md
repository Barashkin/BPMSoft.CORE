# Mailbox Exchange Troubleshooting

<!-- Версия: 1.0 | Обновлено: 2026-04-28 | Платформа: BPMSoft 1.9 -->
<!-- Теги: MailboxSyncSettings, Exchange, troubleshooting, OAuth, Calendar -->

> Диагностика mailbox sync: ящик не синхронизируется, listener не принимает
> события, OAuth не создаёт настройки, календарь не отправляет приглашения или
> jobs не запускаются.

## Быстрая классификация

| Симптом | Где смотреть |
| ------- | ------------ |
| Ящик не синхронизируется | `MailboxSyncSettings`, jobs, `SynchronizationStopped` |
| Ошибка credentials | `MailboxSettingsService.IsServerValid`, mail server settings |
| Jobs не создаются | `MailboxSettingsService.CreateDeleteSyncJob`, owner mailbox |
| Listener не работает | `ExchangeEventsAppListener`, `ExchangeEventsService`, `ExchangeListenerService` |
| Письма не доходят до Activity | `ProcessFullEmail`, `IEmailEventsProcessor`, process logs |
| Calendar sync не включается | `ActivitySyncSettings`, `EnableNewCalendarSynchronizationProcess` |
| Приглашения не отправляются | `MeetingService`, `MeetingInvitationsMixin`, feature `MeetingInvitation` |
| Office365 OAuth не создал ящик | `Office365OAuthAuthenticator`, `OAuthTokenStorage`, transaction rollback |

## Ящик остановил синхронизацию

Проверьте `MailboxSyncSettings`:

- `EnableMailSynhronization = true`;
- `SynchronizationStopped`;
- `RetryCounter`;
- `ErrorCode`;
- `LastError`;
- `SenderEmailAddress`;
- `OAuthTokenStorage`, если используется OAuth.

`MailSyncJob` сбрасывает остановленные ящики только если включён sys setting
`EnableReSynchronizationMechanism`.

## Jobs не создаются

`MailboxSettingsService` проверяет, что текущий пользователь - владелец mailbox:

```text
mailbox.OwnerId == UserConnection.CurrentUser.Id
```

Если владелец другой, service возвращает пустой результат или localized error в
зависимости от feature `OldEmailIntegration`.

Проверьте:

- mailbox owner;
- interval > 0 для плановой синхронизации;
- process name: mail/contact/activity;
- работу `ISyncJobScheduler` или `IImapSyncJobScheduler`;
- наличие Quartz triggers/jobs.

## Ошибка credentials

Для IMAP/SMTP проверка идёт через
`MailboxSynchronizationSettingsService.IsServerValid`.

Для IntegrationV2 mailbox validation используется
`MailboxSettingsService.IsServerValid`:

- получает `IMailServerService.GetServer`;
- создаёт `Mailbox`;
- вызывает `mailbox.Validate(UserConnection)`;
- ошибки переводит через `SynchronizationErrorHelper`.

Проверьте mail server settings, ports, SSL/StartTLS, anonymous auth и
доступность внешнего сервера с application server.

## Listener не принимает события

Проверьте:

- запланирован ли fail job из `ExchangeEventsAppListener`;
- вызываются ли `ExchangeEventsService.StartListener`/`RecreateListener`;
- доходят ли requests до `ExchangeListenerService`;
- логи `ExchangeListener`;
- mailbox availability через `ProcessMailboxState`.

`ExchangeListenerService` сам не обрабатывает доменную логику: он делегирует в
processors. Если endpoint вызывается, но Activity не создаётся, проверяйте
processor/runtime assemblies и domain logs.

## Calendar sync не работает

Проверьте:

- `ActivitySyncSettings.ImportAppointments`;
- `ActivitySyncSettings.ExportActivities`;
- job `ExchangeUtility.ActivitySyncProcessName`;
- `SyncExchangeActivitiesProcess`;
- `ShowInScheduler`, dates и timezone у `Activity`.

`EnableNewCalendarSynchronizationProcess` при `SyncPeriod = -1` удаляет job, а
иначе включает import/export flags и создаёт новую job.

## Meeting invitations не отправляются

Проверьте:

- feature `MeetingInvitation`;
- `MeetingService.CanUserChangeMeeting`;
- `MeetingService.GetMeetingInvitationInfo`;
- `MeetingService.SendInvitations`;
- logger `Calendar`;
- участников Activity и `CurrentUser.ContactId`.

На клиенте flow проходит через `MeetingInvitationsMixin`.

## Office365 OAuth не завершился

Проверьте:

- доступность Microsoft authorize/token URLs;
- scope/resource;
- наличие `id_token` и claim `unique_name`;
- запись `OAuthTokenStorage`;
- создание `MailboxSyncSettings`;
- создание `ContactSyncSettings` и `ActivitySyncSettings`.

`PostprocessAuthentication` выполняется в транзакции: ошибка любого шага
откатывает весь набор записей.

## Связанные документы

- [Mailbox Exchange Sync Overview](mailbox-exchange-sync-overview.md)
- [Mailbox Exchange Runtime Jobs](mailbox-exchange-runtime-jobs.md)
- [Mailbox Exchange Listener Calendar](mailbox-exchange-listener-calendar.md)
- [Mailbox Exchange OAuth Office365](mailbox-exchange-oauth-office365.md)
- [Services Troubleshooting](services-troubleshooting.md)
- [Quartz Troubleshooting](quartz-troubleshooting.md)
