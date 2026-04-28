# Process Quartz Jobs

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: ProcessJob, Quartz, AppScheduler, CreateProcessJob, ScheduleImmediateProcessJob -->

> Quartz запускает процессы отложенно, периодически или по cron-расписанию через `ProcessJob`.

## AppScheduler.CreateProcessJob

Для scheduled process используется `AppScheduler.CreateProcessJob`.

```csharp
var parameters = new Dictionary<string, object>();
parameters["DeliveryId"] = new Guid(deliveryId);

IJobDetail job = AppScheduler.CreateProcessJob(
    jobName,
    jobGroupName,
    processName,
    workspaceName,
    userName,
    parameters);
```

Job хранит имя процесса, workspace, пользователя и параметры процесса.

## Cron trigger

Для периодического запуска создаётся `CronTrigger`.

```csharp
ITrigger trigger = TriggerBuilder.Create()
    .WithIdentity(triggerName, groupName)
    .StartAt(startDate)
    .EndAt(endDate)
    .ForJob(job)
    .WithCronSchedule(cronExpression)
    .Build();

AppScheduler.Instance.ScheduleJob(job, trigger);
```

Если ближайшее время выполнения уже прошло, trigger можно reschedule на следующий valid fire time.

## One-shot trigger

Для единичного запуска используется `SimpleTriggerImpl`.

```csharp
ITrigger trigger = new SimpleTriggerImpl(triggerName, executionDateTime);
AppScheduler.Instance.ScheduleJob(job, trigger);
```

Такой сценарий подходит для отложенной отправки, синхронизации или бизнес-действия по времени.

## ScheduleImmediateProcessJob и ScheduleMinutelyProcessJob

В платформенных сценариях встречаются helper-методы:

- `ScheduleImmediateProcessJob`;
- `ScheduleMinutelyProcessJob`;
- `CreateProcessJob`;
- `RemoveJob`.

Их стоит применять, если нужно стандартное имя job/trigger и повторяемая регистрация при старте приложения или настройке.

## Process inside ClassJob

Иногда Quartz запускает `IJobExecutor`, а уже внутри job вызывается процесс.

```csharp
public void Execute(UserConnection userConnection, IDictionary<string, object> parameters) {
    IProcessEngine processEngine = userConnection.IProcessEngine;
    IProcessExecutor processExecutor = processEngine.ProcessExecutor;
    processExecutor.Execute("InsightSynchronizationProcess");
}
```

Этот вариант удобен, если перед запуском процесса нужна дополнительная проверка системных настроек, периодичности или внешнего состояния.

## Практические правила

- Имена job/group/trigger должны быть детерминированными.
- Перед пересозданием расписания удаляйте старую job.
- Явно передавайте workspace и пользователя.
- Для cron учитывайте timezone и уже прошедший next fire time.
- Логируйте ошибки создания расписания и запуска процесса.

## Связанные документы

- [Process starting](process-starting.md)
- [Quartz AppScheduler API](quartz-appscheduler-api.md)
- [Quartz triggers and cron](quartz-triggers-cron.md)
- [Quartz Process Jobs](quartz-process-jobs.md)
