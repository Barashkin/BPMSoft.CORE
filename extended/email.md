# Работа с электронной почтой

<!-- Версия: 1.0 | Обновлено: 2026-03-19 | Платформа: BPMSoft 1.9 -->
<!-- Теги: email, IEmailSender, Activity, EmailParticipantHelper -->

> Дополнение к [activity-email.md](../server/activity-email.md). Отправка и ключевые классы. Примеры из платформы.

## Отправка email (сервер)

Платформа использует интерфейс `IEmailSender` и реализацию `EmailSender` (DI: `DefaultBinding(typeof(IEmailSender))`).

```csharp
// EmailSender.Base.cs — получает IEmailClientFactory и UserConnection через конструктор
var emailSender = ClassFactory.Get<IEmailSender>();
// Методы отправки определяются в IEmailSender (отправка Activity, произвольного сообщения и т.д.)
```

Создание активности типа «Email» и её отправка обычно идут через:
- сущность **Activity** с TypeId = EmailTypeUId;
- заполнение полей Title, Body, Sender, Recepient, CopyRecepient и т.д.;
- участники создаются через **EmailParticipantHelper** при сохранении (см. [activity-email.md](../server/activity-email.md));
- фактическая отправка — через почтовый клиент (интеграция, MailboxSyncSettings и т.д.).

## Создание активности-письма программно

```csharp
var schema = UserConnection.EntitySchemaManager.GetInstanceByName("Activity");
var activity = schema.CreateEntity(UserConnection);
activity.SetDefColumnValues();
activity.SetColumnValue("TypeId", ActivityConsts.EmailTypeUId);
activity.SetColumnValue("Title", "Тема");
activity.SetColumnValue("Body", "<p>Текст письма</p>");
activity.SetColumnValue("Sender", "sender@example.com");
activity.SetColumnValue("Recepient", "recipient@example.com");
activity.SetColumnValue("StartDate", DateTime.UtcNow);
activity.SetColumnValue("DueDate", DateTime.UtcNow);
activity.SetColumnValue("ActivityCategoryId", IntegrationConsts.EmailCategoryId);
activity.SetColumnValue("StatusId", ActivityConsts.NewStatusUId);
activity.SetColumnValue("EmailSendStatusId", ActivityConsts.NotSendEmailStatusId);
activity.SetColumnValue("OwnerId", ownerContactId);
activity.Save();
// Дальнейшая отправка — через интеграцию/очередь отправки (зависит от конфигурации).
```

## Утилиты (ActivityUtils, EmailParticipantHelper)

- **ActivityUtils** — хеш письма, привязка к Account/Contact, парсинг адресов (см. [activity-email.md](../server/activity-email.md)).
- **EmailParticipantHelper** — инициализация участников из полей Sender/Recepient/CopyRecepient/BlindCopyRecepient, создание ActivityParticipant с ролями From/To/CC/BCC.

## Примеры из платформы

| Сценарий | Файл |
|----------|------|
| Создание и статусы активностей | `EmailTemplateUtility.Base.cs` (StatusId = NewStatusUId) |
| Отмена email-задачи процесса | `EmailUserTaskSchema.ProcessDesigner.cs`, `ManualEmailUserTaskSender.ProcessDesigner.cs` (RemoveActivityProcessListener с CanceledStatusUId) |

---

**Связанные документы:** [Активности и email](../server/activity-email.md) | [Расширенное руководство — оглавление](INDEX.md)
