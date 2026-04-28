# Activity Process User Tasks

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: ProcessUserTask, EmailTemplateUserTask, SendEmailUserTask, ActivityUserTask -->

> Как процессы создают активности и отправляют email.

## Основные user tasks

| UserTask | Назначение |
| -------- | ---------- |
| `ActivityUserTask` | создать/показать задачу или действие пользователя |
| `CallUserTask` | звонок как activity |
| `EmailTemplateUserTask` | письмо по шаблону с макросами |
| `SendEmailUserTask` | отправка письма без шаблона |
| `ManualEmailUserTaskSender` | сценарий с пользовательским участием |
| `AutoEmailUserTaskSender` | автоматическая отправка |

## EmailTemplateUserTask

`EmailTemplateUserTask` строит сообщение через provider/factory и выполняет sender.

```csharp
protected override bool InternalExecute(ProcessExecutingContext context) {
    IEmailUserTaskMessageProvider messageProvider = GetMessageProvider();
    return EmailSender.Execute(messageProvider, context);
}
```

Task умеет:

- подставлять макросы;
- собирать адреса из параметров;
- сохранять `ActivityId`;
- добавлять вложения в `ActivityFile`;
- работать с `EntityFileLocator`.

## Attachments in process tasks

При включённых feature flags вложения читаются через `IFile`/file storage, иначе через entity `Data`.

```csharp
if (GlobalAppSettings.FeatureUseFileStorageInProcessUserTasks) {
    return GetEmailAttachment(locator);
}
```

При сохранении вложения записываются в `ActivityFile`.

## SendEmailUserTask

`SendEmailUserTask` принимает sender, recipients, subject, body, importance и `IsIgnoreErrors`.

```csharp
var message = new EmailMessage {
    From = from,
    To = recepients,
    Subject = Subject,
    Body = Body,
    Priority = emailPriority,
    Cc = ccRecipients,
    Bcc = bccRecipients
};
```

Если sender пустой, используется default sender.

## Activity execution data

Email user task пишет execution data для UI:

- `entitySchemaName = Activity`;
- `pageTypeId = ActivityConsts.EmailTypeUId`;
- `activityRecordId`;
- `allowedResults`;
- `recommendation`.

Это связывает process step с activity card.

## Практические правила

- Для бизнес-писем с шаблоном используйте `EmailTemplateUserTask`.
- Для простого уведомления без шаблона подходит `SendEmailUserTask`.
- Не игнорируйте ошибки (`IsIgnoreErrors`) в критичных процессах.
- Если нужны вложения, проверяйте feature `UseProcessEmailAttachments`.
- Для интерактивных задач сохраняйте `ActivityId`, чтобы процесс мог продолжить выполнение.

## Связанные документы

- [Activity Email Overview](activity-overview.md)
- [Activity email sending](activity-email-sending.md)
- [Process Overview](process-overview.md)
- [Process user tasks](process-user-tasks.md)
