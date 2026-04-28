# Activity Troubleshooting

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: Activity troubleshooting, Email troubleshooting, mailbox, participants -->

> Чеклист диагностики задач, писем, участников, вложений и синхронизации.

## Activity не отображается в календаре

Проверки:

- `ShowInScheduler = true`;
- корректны `StartDate`, `DueDate`, `TimeZone`;
- `Type` и `ActivityCategory` соответствуют встрече/задаче;
- пользователь имеет права на запись;
- scheduler view не фильтрует запись.

## Duration неверный

Проверки:

- `DueDate` не раньше `StartDate`;
- lifecycle `OnActivitySaving` выполнялся;
- запись не обновлялась прямым SQL без пересчёта;
- timezone не влияет на отображение в UI.

## Email не отправляется

Проверки:

- есть хотя бы один получатель To/CC/BCC;
- `Sender` или default sender доступен;
- mailbox credentials валидны;
- `EmailSendStatus` не застрял в `InProgress`;
- `ErrorOnSend` содержит последнюю ошибку;
- `IsIgnoreErrors` в process task не скрывает исключение.

## Email отправлен, но Activity не завершена

Проверки:

- `ActivityEmailSender.CompleteSending` выполнился;
- `EmailSendStatus = Sended`;
- activity `Status` переведён в finished status;
- нет ошибки после фактической отправки, например на записи прав или вложений.

## Участники письма не создались

Проверки:

- `Type = Email`;
- заполнены `Sender`, `Recepient`, `CopyRecepient`, `BlindCopyRecepient`;
- `EmailParticipantHelper.InitializeParameters` отработал;
- email адреса парсятся корректно;
- контакты найдены через communication data;
- нет дублей, вытесненных приоритетом To/CC/BCC.

## SenderContact пустой

Проверки:

- sender address есть в `Sender`;
- найден contact с таким email;
- participant с ролью `From` создан;
- lifecycle не был обойдён прямым update.

## Вложения не отправились

Проверки:

- файлы лежат в `ActivityFile`;
- content доступен через file storage;
- inline attachments имеют корректный content id;
- `UseProcessEmailAttachments` включён для process attachments;
- в `EmailSender` нет удаления "trash content" из-за несоответствия inline ids.

## Входящее письмо требует обработки

Проверки:

- `IsNeedProcess = true`;
- пусты `Contact` и `Account`;
- `MailHash` не указывает на дубликат;
- `SenderContact` не найден;
- auto relation logic не смогла связать письмо.

## Mailbox sync не работает

Проверки:

- `MailboxSyncSettings` принадлежит нужному `SysAdminUnit`;
- выбран `MailSyncPeriod`;
- ящик активен и credentials валидны;
- Exchange listener не удалил или не пересоздал настройки;
- `MarkEmailsAsSynchronized` не меняет ожидаемое поведение;
- synchronization error helper содержит ошибку.

## Практический минимум

1. Найдите `Activity.Id`.
2. Проверьте `Type`, `Status`, `MessageType`, `EmailSendStatus`.
3. Проверьте participants.
4. Проверьте `ActivityFile`.
5. Проверьте mailbox/sender.
6. Проверьте lifecycle: запись сохранялась через entity API или прямой update.

## Связанные документы

- [Activity Email Overview](activity-overview.md)
- [Activity lifecycle](activity-lifecycle.md)
- [Activity email sending](activity-email-sending.md)
- [Activity mailbox sync](activity-mailbox-sync.md)
