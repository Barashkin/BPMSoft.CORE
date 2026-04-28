# Activity Participants Files

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: ActivityParticipant, EmailParticipantHelper, ActivityFile, EmailFileDetailV2 -->

> Участники активности и вложения: `ActivityParticipant`, email roles, `ActivityFile`.

## ActivityParticipant

`ActivityParticipant` связывает активность с контактом и ролью.

| Колонка | Назначение |
| ------- | ---------- |
| `Activity` | ссылка на `Activity` |
| `Participant` | контакт участника |
| `Role` | роль: From/To/CC/BCC/participant |
| `ReadMark` | прочитано |
| `InviteParticipant` | приглашать участника |
| `InviteResponse` | ответ участника |

В IntegrationV2 слой меняет default role и создаёт EventsProcess для participant lifecycle.

## EmailParticipantHelper

`EmailParticipantHelper` парсит поля письма:

- `Sender`;
- `Recepient`;
- `CopyRecepient`;
- `BlindCopyRecepient`.

Он удаляет дубликаты, ищет контакты по email и создаёт `ActivityParticipant` с ролями From/To/CC/BCC.

```csharp
InitializeEmailParticipantHelper().InitializeParameters(Entity);
InitializeEmailParticipantHelper().SetEmailParticipants();
```

## SenderContact

Если найден participant с ролью `From`, helper может заполнить `SenderContactId` у email activity.

Это важно для входящих писем, автосвязей и фильтрации.

## Non-email participants

Для обычных задач lifecycle синхронизирует участников по:

- `Owner`;
- `Contact`;
- manually inserted participant values.

Не-email activity не использует email address fields как источник участников.

## ActivityFile

`ActivityFile` — файловая схема для вложений активности, наследник `File`.

Типовые сценарии:

- email attachments;
- process-generated attachments;
- inline images для HTML email;
- файлы, добавленные через `FileDetailV2`.

## EmailFileDetailV2

`EmailFileDetailV2` расширяет generic file detail и отключает добавление link-файла.

```javascript
getAddLinkMenuItem: BPMSoft.emptyFn
```

Для email вложения должны быть реальными файлами, а не ссылками.

## Практические правила

- Для email participants заполняйте адресные поля, а не создавайте участников вручную.
- Для дубликатов адресов учитывайте порядок: To имеет приоритет над CC/BCC.
- Для вложений email используйте `ActivityFile`.
- Для inline attachments проверяйте `IsContent` и content id.
- После отправки письма участник текущего пользователя может быть помечен как прочитанный.

## Связанные документы

- [Activity Email Overview](activity-overview.md)
- [Activity lifecycle](activity-lifecycle.md)
- [File Storage Overview](file-overview.md)
- [File client detail](file-client-detail.md)
