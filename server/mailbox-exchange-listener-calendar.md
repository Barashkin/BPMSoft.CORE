# Mailbox Exchange Listener Calendar

<!-- Версия: 1.0 | Обновлено: 2026-04-28 | Платформа: BPMSoft 1.9 -->
<!-- Теги: ExchangeListener, IntegrationV2, MeetingService, Calendar, Activity -->

> Exchange listener и календарный слой `IntegrationV2`: endpoints для событий
> почты, mailbox state, listener control и meeting invitations.

## ExchangeEventsAppListener

`ExchangeEventsAppListener.ExchangeListener.cs` запускается на старте
приложения и планирует fail-handling job:

```text
OnAppStart
  -> IListenerServiceFailJobFactory.ScheduleListenerServiceFailJob
```

Это housekeeping вокруг внешнего listener service: если listener падает или
теряет состояние, отдельная job должна восстановить обработку.

## ExchangeListenerService

`ExchangeListenerService.IntegrationV2.cs` принимает callbacks от Exchange
listener service.

| Method | BodyStyle | Назначение |
| ------ | --------- | ---------- |
| `NewEmail` | `Wrapped` | событие о новых email item ids |
| `ProcessBinarySerializedEmail` | stream | binary serialized `LoadEmailCommand` |
| `ProcessFullEmail` | `Bare` | полный email payload |
| `ProcessMailboxState` | `Bare` | состояние mailbox availability |
| `RefreshToken` | `Bare` | запрос refresh access token |

Обработчики не содержат бизнес-логику напрямую: они логируют событие и
делегируют в domain processors:

- `IExchangeEventsProcessor`;
- `IEmailEventsProcessor`;
- `IMailboxStateEventsProcessor`;
- `IMailboxEventsProcessor`.

## ExchangeEventsService

`ExchangeEventsService.IntegrationV2.cs` управляет listener lifecycle:

| Method | Назначение |
| ------ | ---------- |
| `StartListener(Guid mailboxId)` | запустить listener для mailbox |
| `StopListener(Guid mailboxId)` | остановить listener |
| `RecreateListener(Guid mailboxId)` | пересоздать listener |

Manager получается через:

```text
IListenerManagerFactory.GetExchangeListenerManager(UserConnection)
```

## MeetingService

`MeetingService.IntegrationV2.cs` - WCF facade для календарных встреч:

| Method | Назначение |
| ------ | ---------- |
| `SendInvitations(Guid meetingId)` | отправить приглашения участникам |
| `GetMeetingInvitationInfo(Guid meetingId)` | получить состояние invite/sync |
| `CanUserChangeMeeting(Guid meetingId)` | можно ли менять встречу |
| `CanUserChangeCalendar(string senderEmailAddress)` | можно ли менять календарь |

Внутри используется `IMeetingService` через `ClassFactory` и текущий
`CurrentUser.ContactId`.

Ошибки логируются в logger `Calendar`, а `SendInvitations` возвращает
`BaseResponse` с `ErrorInfo`.

## Client meeting flow

`MeetingInvitationsMixin.IntegrationV2.js` вызывает `MeetingService` через
`ServiceHelper`:

```text
CanUserChangeMeeting
  -> GetMeetingInvitationInfo
  -> confirmation
  -> SendInvitations
```

Feature flag:

```text
MeetingInvitation
```

Если feature выключен, миксин пропускает invitation-specific checks.

## Activity boundary

Календарь хранится в `Activity`, участниках и sync settings, но listener/calendar
runtime относится к этому dive. Подробности по базовой модели Activity остаются
в Activity Dive.

## Связанные документы

- [Mailbox Exchange Sync Overview](mailbox-exchange-sync-overview.md)
- [Mailbox Exchange Runtime Jobs](mailbox-exchange-runtime-jobs.md)
- [Activity Overview](activity-overview.md)
- [Notifications Reminders Overview](notifications-reminders-overview.md)
- [Services Overview](services-overview.md)
