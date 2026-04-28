# Activity Schema Constants

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: ActivitySchema, ActivityConsts, ConfigurationConstants, ActivityStatus -->

> Схема `Activity`, ключевые поля и константы для server/client кода.

## Activity as universal entity

`Activity` описывает несколько доменных сценариев:

- task;
- call;
- appointment;
- email;
- process-generated activity.

Тип определяется `Type`, категория — `ActivityCategory`, бизнес-состояние — `Status`.

## Core columns

| Группа | Колонки |
| ------ | ------- |
| Базовые | `Title`, `StartDate`, `DueDate`, `Status`, `Priority` |
| Ответственные | `Owner`, `OwnerRole`, `Author`, `Organizer` |
| Календарь | `ShowInScheduler`, `TimeZone`, `DurationInMinutes` |
| Связи | `Account`, `Contact`, `ActivityConnection`, `ProcessElementId` |
| Email | `Sender`, `Recepient`, `CopyRecepient`, `Body`, `IsHtmlBody` |
| Email state | `MessageType`, `EmailSendStatus`, `SendDate`, `ErrorOnSend` |
| Email processing | `Preview`, `MailHash`, `IsNeedProcess`, `SenderContact` |

## ActivityConsts

`ActivityConsts.Base.cs` содержит server-side GUID для типов, статусов, категорий и ролей участников.

| Константа | Смысл |
| --------- | ----- |
| `EmailTypeUId` | activity type email |
| `TaskTypeUId` | task/meeting type |
| `CallTypeUId` | call type |
| `NewStatusUId`, `InProgressUId`, `CompletedStatusUId` | activity statuses |
| `NotSendEmailStatusId`, `InProgressEmailStatusId`, `SendedEmailStatusId` | email send statuses |
| `ActivityParticipantRoleFrom`, `To`, `Cc`, `Bcc` | roles in `ActivityParticipant` |
| `IncomingEmailTypeId`, `OutgoingEmailTypeId` | message direction |

## Client constants

На клиенте используйте `ConfigurationConstants.NUI.js`, где есть `Activity.Type`, `Activity.Status`, `ActivityCategory`, `EmailSendStatus`, `MessageType`, `ParticipantRole`.

Это снижает риск hardcode GUID в AMD-модулях.

## Type, category, result

Activity uses several lookups:

- `ActivityType` — task/email/call/visit;
- `ActivityCategory` — category and mapping to type;
- `ActivityStatus` — business status;
- `ActivityResult` — result;
- `ActivityCategoryResultEntry` — allowed results by category.

Если UI или process не показывает нужный результат, проверяйте не только `ActivityResult`, но и category/result mapping.

## Практические правила

- В C# используйте `ActivityConsts`, а не строковые GUID.
- В JS используйте `ConfigurationConstants.Activity`.
- Для email проверяйте и `Type`, и `MessageType`, и `EmailSendStatus`.
- Для календаря не путайте `Status` и `ShowInScheduler`.
- Для process-generated activity сохраняйте `ProcessElementId`, если нужна обратная трассировка.

## Связанные документы

- [Activity Email Overview](activity-overview.md)
- [Activity lifecycle](activity-lifecycle.md)
- [Activity client UI](activity-client-ui.md)
- [Перечисления и константы](../reference/enums-constants.md)
