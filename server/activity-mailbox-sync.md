# Activity Mailbox Sync

<!-- Версия: 1.2 | Обновлено: 2026-04-28 | Платформа: BPMSoft 1.9 -->
<!-- Теги: MailboxSyncSettings, Exchange, ActivitySynchronizer, EmailSyncSettings, EmailMining -->

> Почтовые ящики, Exchange-синхронизация и связь с `Activity`.
> Подробный runtime, listener, Office 365 OAuth и calendar sync описаны в
> [Mailbox Exchange Sync Overview](mailbox-exchange-sync-overview.md).

## MailboxSyncSettings

`MailboxSyncSettings` хранит настройки почтового ящика и владельца синхронизации.

В ExchangeListener-слое:

- `SysAdminUnit` по умолчанию равен current user;
- `MailSyncPeriod` получает default value;
- добавлены flags `PersonalMetrics` и `MarkEmailsAsSynchronized`;
- есть EventsProcess для удаления/обслуживания настроек.

## Activity sync settings

Exchange-пакеты добавляют:

- `ActivitySyncSettings`;
- `ActivitySynchronizer`;
- `MailboxFoldersCorrespondence`;
- настройки календарей и импорта встреч.

Это связывает remote mailbox/calendar object с local `Activity`.

## Email direction and state

Для синхронизации важно различать:

- `MessageType` — входящее или исходящее;
- `EmailSendStatus` — состояние отправки/обработки;
- `GlobalActivityID` — внешний идентификатор;
- `MailHash` — дедупликация;
- `HeaderProperties` — заголовки письма.

## Calendar sync

Встречи и задачи используют `ShowInScheduler`, `StartDate`, `DueDate`, `TimeZone`, participant responses и mailbox calendars.

Если встреча не появляется в календаре, проверяйте не только `Activity`, но и sync settings.

## Synchronization errors

`EmailSender` очищает или пишет synchronization errors через helper, особенно для legacy integration. Ошибки отправки также попадают в `Activity.ErrorOnSend`.

## Связь с Email Mining

Mailbox sync создает или обновляет email `Activity`, а Email Mining уже
обрабатывает такие активности через `EmailMiningJob`.

Для mining важны `Body`, `IsHtmlBody`, `Sender`, `SendDate`, `EnrichStatus` и
`EnrchEmailData`. `MailHash` остается механизмом дедупликации синхронизации и
не заменяет hash extracted data в `EnrchEmailData` / `EnrchTextEntity`.

## Практические правила

- Для почтовой диагностики начинайте с `MailboxSyncSettings` и владельца (`SysAdminUnit`).
- Проверяйте, что входящее письмо не продублировалось по `MailHash`.
- Для календаря проверяйте `ShowInScheduler`, dates, timezone и mailbox calendar mapping.
- Не смешивайте `EmailSendStatus` и sync status удалённой системы.
- При смене mail server проверяйте listener/service logic, которая обслуживает настройки.

## Связанные документы

- [Activity Email Overview](activity-overview.md)
- [Activity email sending](activity-email-sending.md)
- [Activity client UI](activity-client-ui.md)
- [Mailbox Exchange Sync Overview](mailbox-exchange-sync-overview.md)
- [Email Mining Enrichment Overview](email-mining-enrichment-overview.md)
- [Scheduler Quartz](scheduler-quartz.md)
