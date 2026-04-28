# Email Template Process Sending

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: EmailTemplateUserTask, EmailSendService, ActivityEmailSender -->

> Отправка email по шаблону из бизнес-процессов и через сервис отправки.

## EmailTemplateUserTask

`EmailTemplateUserTask.ProcessDesigner.cs` реализует runtime поведение user task.

Ключевые компоненты:

| Компонент | Назначение |
| --------- | ---------- |
| `IEmailUserTaskSender` | отправка или создание активности |
| `IEmailUserTaskMessageProvider` | тело, тема, получатели |
| `IEmailUserTaskMacrosProvider` | подстановка макросов |
| `MacrosExtendedProperties` | дополнительные свойства макросов |
| `IUserTaskActivityInfo` | связь с Activity |

`InternalExecute` получает message provider и вызывает `EmailSender.Execute`.

## Attachments

Вложения читаются через `EntityFileLocator`.

Если включён `FeatureUseFileStorageInProcessUserTasks`, используется
`IFileFactory` и file storage API. Иначе вложение читается из legacy columns
`Name` и `Data`.

Добавление вложений в Activity работает только при feature
`UseProcessEmailAttachments`.

## Process execution data

User task пишет execution data:

- `entitySchemaName = Activity`;
- `recommendation`;
- `informationOnStep`;
- `pageTypeId`;
- `activityRecordId`;
- `executionContext`;
- `allowedResults`.

Это нужно для UI процесса и переходов после активности.

## Message provider

`EmailProcessTemplateUserTaskMessageProvider` покрывает процессные шаблоны и
учитывает `SendEmailType.Auto`. Для sender/recipient может применяться ESQ и
права текущего пользователя.

## EmailSendService

`EmailSendService.Send(ActivityId)`:

1. Создаёт `EmailClientFactory`.
2. Вызывает `ActivityEmailSender.Send`.
3. Если отправка успешна, выставляет status `Sended`.
4. Если пойман `EmailException`, берёт `EmailSendStatus` из исключения.
5. Возвращает запись `EmailSendStatus` по code.

Response содержит:

- `DisplayValue`;
- `Value`;
- `Code`;
- `HasFollowingProcessElement`.

## Практические правила

- Для процесса используйте `EmailTemplateUserTask`, а не ручной `Activity`.
- Вложения передавайте через `EntityFileLocator`.
- Проверяйте features `UseProcessEmailAttachments` и file storage mode.
- После send анализируйте `EmailSendStatus.Code`.
- Для auto-send отдельно проверяйте mailbox/sender settings.

## Связанные документы

- [Content email templates overview](content-email-templates-overview.md)
- [Email template multilang macros](email-template-multilang-macros.md)
- [Activity email sending](activity-email-sending.md)
- [Process user tasks](process-user-tasks.md)
