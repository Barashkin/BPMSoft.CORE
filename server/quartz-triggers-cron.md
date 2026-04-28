# Triggers, Cron и Misfire

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: Quartz, trigger, cron, misfire, timezone, schedule -->

> Deep dive по trigger-модели Quartz в BPMSoft: `CronTriggerImpl`, `SimpleTriggerImpl`, `TriggerBuilder`, `startDate/endDate`, `misfire` и timezone-поведение.

## Обзор

В решении встречаются три основных способа создавать trigger:

- `CronTriggerImpl` для cron-расписаний;
- `SimpleTriggerImpl` для одноразовых и interval-сценариев;
- `TriggerBuilder` для более гибкой сборки trigger c `StartAt/EndAt/WithCronSchedule`.

## Основные trigger-паттерны

### `CronTriggerImpl`

Подходит для:

- ежедневных задач;
- weekly/monthly сценариев;
- фиксированных cron-расписаний.

Типовой пример:

```csharp
ITrigger trigger = new CronTriggerImpl(triggerName, triggerGroup, "0 0 3 * * ?");
AppScheduler.Instance.ScheduleJob(job, trigger);
```

### `SimpleTriggerImpl`

Подходит для:

- одноразового запуска в указанное время;
- repeated interval без cron;
- временных/recovery запусков.

Типовой пример:

```csharp
ITrigger trigger = new SimpleTriggerImpl(triggerName, executionDateTime);
AppScheduler.Instance.ScheduleJob(job, trigger);
```

### `TriggerBuilder`

Используется, когда нужно комбинировать:

- `StartAt`
- `EndAt`
- `WithCronSchedule(...)`
- `WithSimpleSchedule(...)`
- `ForJob(...)`

Именно так оформлены более сложные sender-паттерны и некоторые class job registrations.

## Cron в BPMSoft

### Формат

Quartz ожидает:

```text
секунды минуты часы день_месяца месяц день_недели [год]
```

Примеры из документации и кода:

| Выражение | Смысл |
| ----- | ----- |
| `0 0 3 * * ?` | ежедневно в 03:00 |
| `0 30 1 ? * *` | ежедневно в 01:30 |
| `0 0/10 * * * ? *` | каждые 10 минут |

### Где реально используется cron

- `AnniversaryRemindingsEventListener.Base.cs`
- `BSSchedulerService.BPMSoftSender.cs`
- `BulkDeduplicationScheduler.Deduplication.cs`
- `PeriodicitySettingsUtilities.Base.cs`

## `StartAt` / `EndAt`

`TriggerBuilder` позволяет задавать окно жизни триггера:

```csharp
ITrigger trigger = TriggerBuilder.Create()
    .WithIdentity(triggerName, groupName)
    .StartAt(startDate)
    .EndAt(endDate)
    .ForJob(job)
    .WithCronSchedule(cronExpression)
    .Build();
```

Это особенно важно для:

- расписаний Sender;
- job'ов, у которых есть активное окно выполнения;
- периодических интеграций с ограниченным временем жизни.

## Коррекция следующего запуска

В `BSSchedulerService.BPMSoftSender.cs` есть важный production-паттерн:

1. создаётся cron trigger;
1. вычисляется `CronExpression.GetNextValidTimeAfter(startDate)`;
1. если следующее срабатывание уже в прошлом, trigger пересчитывается;
1. затем вызывается `RescheduleJob(...)`.

Это защита от сценария, когда `StartAt` уже прошёл к моменту регистрации.

## Misfire

### Что это

Misfire - это поведение Quartz, если scheduler пропустил ожидаемое срабатывание.

В решении встречаются как raw Quartz-константы, так и BPMSoft-обёртки:

- `MisfireInstruction.SimpleTrigger.FireNow`
- `AppSchedulerMisfireInstruction.RescheduleNowWithRemainingRepeatCount`
- `AppSchedulerMisfireInstruction.SmartPolicy`

### Где misfire используется реально

| Файл | Использование |
| ----- | ----- |
| `QuartzJobTriggerManager.Base.cs` | `RunScheduleJob(..., misfireInstruction)` |
| `TouchFailoverHandler.TouchPoints.cs` | `RescheduleNowWithRemainingRepeatCount` |
| `TouchQueueJobDispatcher.TouchPoints.cs` | `SmartPolicy` |
| `PeriodicitySettingsUtilities.Base.cs` | `FireNow` для создаваемого trigger |

### Практический смысл

- `FireNow` полезен, когда пропущенный запуск надо исполнить как можно скорее;
- `SmartPolicy` даёт Quartz выбрать разумный дефолт;
- `RescheduleNowWithRemainingRepeatCount` полезен для failover/recovery сценариев.

## Timezone

В текущем наборе документов и кода видны два паттерна:

### UTC-подход

Используется в API `IAppSchedulerWraper.CreateAndScheduleJob(...)`, где явно передаётся:

- `timeZoneId: TimeZoneInfo.Utc.Id`

Это хороший вариант для server-owned задач без пользовательской локали.

### User timezone-подход

В `PeriodicitySettingsUtilities.Base.cs` `DailyCalendar` получает:

- `dailyCalendar.TimeZone = _userConnection.CurrentUser.TimeZone`

Это означает, что часть trigger-логики строится уже в локали текущего пользователя, а не жёстко в UTC.

## Ограничения `PeriodicitySettingsUtilities`

С точки зрения trigger-модели это важно:

- `IsDaily = true` временно форсируется в коде;
- weekly/monthly ветки `isManyTimesPerDay` оставлены неполными;
- часть multi-trigger логики выглядит как beta/temporary implementation;
- misfire выставляется как `SimpleTrigger.FireNow` даже для абстрактного trigger.

Подробности см. в [quartz-periodicity-settings.md](quartz-periodicity-settings.md).

## Когда использовать какой trigger

| Задача | Что брать |
| ----- | ----- |
| Ежедневный или cron-run | `CronTriggerImpl` |
| Одноразовый запуск в конкретный момент | `SimpleTriggerImpl` |
| Интервальный `RepeatForever()` | `TriggerBuilder.WithSimpleSchedule(...)` |
| Cron + окно Start/End | `TriggerBuilder.WithCronSchedule(...)` |
| Recovery с misfire-контролем | `SimpleTriggerImpl` / `TriggerBuilder` + misfire policy |

## Типовые ошибки

### 1. Cron зарегистрирован, но next fire time уже в прошлом

Решение:

- пересчитать следующее valid time;
- использовать `RescheduleJob(...)`.

### 2. Задача срабатывает “не в той зоне”

Проверить:

- используется ли UTC;
- не влияет ли `CurrentUser.TimeZone`;
- нет ли смешения `DateTime.UtcNow` и пользовательского local time.

### 3. Пропущенные интервалы не отрабатываются ожидаемо

Проверить:

- misfire policy;
- использован ли `SmartPolicy` или `FireNow`;
- scheduler downtime/failover сценарий.

## Ключевые файлы

| Область | Файл |
| ----- | ----- |
| Cron + trigger builder | `Autogenerated/Src/BSSchedulerService.BPMSoftSender.cs` |
| Misfire wrapper usage | `Autogenerated/Src/TouchFailoverHandler.TouchPoints.cs` |
| SmartPolicy usage | `Autogenerated/Src/TouchQueueJobDispatcher.TouchPoints.cs` |
| Periodicity to triggers | `Autogenerated/Src/PeriodicitySettingsUtilities.Base.cs` |
| Process trigger manager | `Autogenerated/Src/QuartzJobTriggerManager.Base.cs` |

## Связанные документы

- [Обзор Quartz](scheduler-quartz.md)
- [AppScheduler API](quartz-appscheduler-api.md)
- [ProcessJob и QuartzJobTriggerManager](quartz-process-jobs.md)
- [PeriodicitySettingsUtilities](quartz-periodicity-settings.md)
- [Quartz troubleshooting](quartz-troubleshooting.md)
