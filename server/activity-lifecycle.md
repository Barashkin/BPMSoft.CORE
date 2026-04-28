# Activity Lifecycle

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: Activity, EventsProcess, OnActivitySaving, reminders, MailHash -->

> Runtime-поведение `Activity`: сохранение, duration, reminders, email preview, participants.

## Saving

`Activity.Base.cs` выполняет несколько операций в `OnActivitySaving`.

```csharp
public virtual bool OnActivitySaving(ProcessExecutingContext context) {
    SaveOldValuesOnSaving();
    SetRemindDatesOnSaving();
    CalculateDurationOnSaving();
    SavingEmailOnSaving();
    SetTypeByCategoryOnSaving();
    CheckNeedAutoEmailRelation();
    InitCanGenerateAnniversaryReminding();
    return true;
}
```

## Duration

Duration рассчитывается из `DueDate - StartDate`.

```csharp
TimeSpan duration = Entity.DueDate - Entity.StartDate;
Entity.DurationInMinutes = (int)duration.TotalMinutes;
Entity.DurationInMnutesAndHours =
    string.Concat((int)duration.TotalHours, Hour, duration.Minutes, Minute);
```

## Reminders

Activity хранит отдельные flags и даты:

- `RemindToAuthor`;
- `RemindToAuthorDate`;
- `RemindToOwner`;
- `RemindToOwnerDate`.

При изменении дат активности lifecycle пересчитывает напоминания, чтобы они оставались согласованными с `StartDate`/`DueDate`.

## Email saving

Для email lifecycle:

- инициализирует `EmailParticipantHelper`;
- формирует `Preview` из HTML body;
- генерирует `MailHash` для дедупликации;
- выставляет rights mode через `EmailRightsManager`;
- определяет `IsNeedProcess`, если нет связанного contact/account.

## Saved

После сохранения логика расходится по типу.

```csharp
if (typeId == ActivityConsts.EmailTypeUId) {
    InitializeEmailParticipantHelper().InitializeParameters(Entity);
    AutoEmailRelationProceed();
    InitializeEmailParticipantHelper().SetEmailParticipants();
} else {
    UpdateParticipantsByOwnerContact();
    SynchronizeActivityOnSaved();
    CreateActivityParticipantsFromInsertedValues();
}
```

Email создаёт участников из адресных полей. Обычные задачи синхронизируют участников по `Owner` и `Contact`.

## Validation

Для задач важно, чтобы был назначен performer: `Owner` или `OwnerRole`, особенно при включённой feature `UseProcessPerformerAssignment`.

## Практические правила

- Не рассчитывайте `DurationInMinutes` вручную вне lifecycle, если меняете даты через entity save.
- Для email не создавайте `ActivityParticipant` напрямую, если можно заполнить адресные поля и дать lifecycle обработать участников.
- Если сохраняете `Activity` в bypass-режиме, учитывайте, что preview/hash/reminders могут не пересчитаться.
- Для входящих email проверяйте `IsNeedProcess`, `Contact`, `Account`, `SenderContact`.
- Для проблем с правами после сохранения смотрите `EmailRightsManager` и participants.

## Связанные документы

- [Activity Email Overview](activity-overview.md)
- [Activity participants files](activity-participants-files.md)
- [Activity troubleshooting](activity-troubleshooting.md)
- [EventListener EventsProcess](event-listeners-eventsprocess.md)
