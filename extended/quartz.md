# Работа с Quartz

<!-- Версия: 1.0 | Обновлено: 2026-03-19 | Платформа: BPMSoft 1.9 -->
<!-- Теги: Quartz, AppScheduler, ProcessJob, ClassJob, активация, деактивация, RescheduleJob -->

> Дополнение к [scheduler-quartz.md](../server/scheduler-quartz.md). Типы заданий, изменение даты/времени и активация/деактивация. Примеры из платформы.

## Создание заданий различного типа

### 1. ProcessJob (запуск бизнес-процесса по расписанию)

```csharp
// AnniversaryRemindingsEventListener.Base.cs
IJobDetail job = AppScheduler.CreateProcessJob(jobName, jobGroup, processName,
    UserConnection.Workspace.Name, UserConnection.CurrentUser.Name, null, true);
ITrigger trigger = new CronTriggerImpl(triggerName, jobGroup, cron);
AppScheduler.Instance.ScheduleJob(job, trigger);
```

### 2. ClassJob (выполнение C#-класса, реализующего IJobExecutor)

```csharp
// NotificationEventListener.NUI.cs
IJobDetail job = AppScheduler.CreateClassJob<NotificationCleanerJob>(jobGroupName,
    UserConnection.Workspace.Name, UserConnection.CurrentUser.Name, null, true);
ITrigger trigger = new CronTriggerImpl(jobTriggerName, jobGroupName, cronExp);
AppScheduler.Instance.ScheduleJob(job, trigger);
```

### 3. Периодический ProcessJob (каждые N минут)

```csharp
// ImapSyncJobScheduler.Base.cs
AppScheduler.ScheduleMinutelyJob(syncJobName, SyncJobGroupName, SyncProcessName,
    userConnection.Workspace.Name, userConnection.CurrentUser.Name, periodInMinutes, parameters);
```

### 4. Периодический ClassJob (каждые N минут)

```csharp
// SecurityTokenJobManager.Base.cs
AppScheduler.ScheduleMinutelyJob<SecurityTokenCleaner>(JobGroupName, UserConnection.Workspace.Name,
    UserConnection.CurrentUser.Name, ExecutionPeriod, null, true);
```

### 5. Одноразовый запуск в заданное время

```csharp
// BSSchedulerService.BPMSoftSender.cs — AddProcessToScheduleSingleRun
IJobDetail job = AppScheduler.CreateProcessJob(jobName, jobGroupName, processName,
    SystemUserConnection.Workspace.Name, SystemUserConnection.CurrentUser.Name, parameters);
ITrigger trigger = new SimpleTriggerImpl(triggerName, executionDateTime);
AppScheduler.Instance.ScheduleJob(job, trigger);
```

### 6. Cron с окном StartAt/EndAt и коррекцией следующего запуска

```csharp
// BSSchedulerService.BPMSoftSender.cs — AddProcessToScheduleCronExp
AppScheduler.RemoveJob(jobName, jobGroupName);
IJobDetail job = AppScheduler.CreateProcessJob(...);
ITrigger trigger = TriggerBuilder.Create()
    .WithIdentity(triggerName, groupName)
    .StartAt(startDate)
    .EndAt(endDate)
    .ForJob(job)
    .WithCronSchedule(cronExpression)
    .Build();
CronExpression cronExp = new CronExpression(cronExpression);
var nextExecutionTimeOffset = cronExp.GetNextValidTimeAfter(startDate).Value;
var currentTime = new DateTimeOffset(DateTime.UtcNow);
AppScheduler.Instance.ScheduleJob(job, trigger);
// Коррекция: если следующее срабатывание уже в прошлом — пересчитать и обновить триггер
if (nextExecutionTimeOffset <= currentTime) {
    nextExecutionTimeOffset = cronExp.GetNextValidTimeAfter(currentTime).Value;
    ((IOperableTrigger)trigger).SetNextFireTimeUtc(nextExecutionTimeOffset);
    AppScheduler.Instance.RescheduleJob(new TriggerKey(triggerName, groupName), trigger);
}
```

## Коррекция даты и времени обработки события

- **RescheduleJob** — заменить триггер у существующей задачи (новое время/расписание):

```csharp
AppScheduler.Instance.RescheduleJob(new TriggerKey(triggerName, groupName), trigger);
```

- **Удалить и заново запланировать** (часто используется при смене расписания):

```csharp
AppScheduler.RemoveJob(jobName, jobGroupName);
IJobDetail job = AppScheduler.CreateProcessJob(...);
ITrigger newTrigger = TriggerBuilder.Create()...
AppScheduler.Instance.ScheduleJob(job, newTrigger);
```

- Для Cron-триггера можно менять следующее срабатывание через `IOperableTrigger.SetNextFireTimeUtc` и затем `RescheduleJob` (пример выше).

## Активация / деактивация задания

**Деактивация** — удаление задания из планировщика (остановка запусков):

```csharp
AppScheduler.RemoveJob(jobName, jobGroupName);
// С именованным планировщиком:
AppScheduler.RemoveJob(jobName, jobGroupName, scheduler);
```

**Активация** — создание и планирование задания (примеры выше). Проверка существования перед созданием:

```csharp
if (!AppScheduler.DoesJobExist(jobName, jobGroup)) {
    IJobDetail job = AppScheduler.CreateProcessJob(...);
    AppScheduler.Instance.ScheduleJob(job, trigger);
}
```

**Пример полного цикла «деактивировать → обновить статусы → удалить задание»:**

```csharp
// BSSchedulerService.BPMSoftSender.cs — RemoveProcessFromSchedule
AppScheduler.RemoveJob(jobName, jobGroupName);
// + обновление статусов рассылки в БД (FinishedDeliveryStatus, NotDeliveredBSDeliveryRecipientStatus)
```

## Примеры из платформы

| Сценарий | Файл |
|----------|------|
| Cron ProcessJob (ежедневно) | `AnniversaryRemindingsEventListener.Base.cs` |
| Cron ClassJob | `NotificationEventListener.NUI.cs` (NotificationCleanerJob, RemindingJob) |
| ScheduleMinutelyJob ProcessJob | `ImapSyncJobScheduler.Base.cs` |
| ScheduleMinutelyJob ClassJob | `SecurityTokenJobManager.Base.cs`, `TouchQueueJobDispatcher.TouchPoints.cs` |
| Одноразовый запуск в заданное время | `BSSchedulerService.BPMSoftSender.cs` — AddProcessToScheduleSingleRun |
| Cron с StartAt/EndAt и коррекцией следующего запуска | `BSSchedulerService.BPMSoftSender.cs` — AddProcessToScheduleCronExp |
| Деактивация и удаление задания | `BSSchedulerService.BPMSoftSender.cs` — RemoveProcessFromSchedule; `ContactAgeActualizationJobRestartProcess.Base.cs` — RemoveJob |
| Перепланирование при смене параметров | `PeriodicitySettingsUtilities.Base.cs` — RemoveJob + CreateProcessJob + CreateTrigger |

---

**Связанные документы:** [Планировщик Quartz](../server/scheduler-quartz.md) | [Расширенное руководство — оглавление](INDEX.md)
