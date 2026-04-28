# EventListener Async And Jobs

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: EventListener, async, Quartz, IJobExecutor, AppScheduler, IEntityEventAsyncExecutor -->

> Как listener'ы запускают отложенную работу: async executor, Quartz jobs и self-healing регистрацию на старте приложения.

## Зачем выносить работу из listener

Listener выполняется в цепочке изменения записи или старта приложения. Если логика долгая, её лучше вынести:

- в `IEntityEventAsyncExecutor`;
- в `IJobExecutor`;
- в process job;
- в отдельный service, вызванный из job.

Это снижает риск блокировок, таймаутов и повторного входа в entity pipeline.

## Async executor после сохранения

`BaseEntityOwnerEventListener.Base.cs` показывает after-save паттерн: после смены владельца запускаются async operations.

```csharp
public override void OnSaved(object sender, EntityAfterEventArgs e) {
    base.OnSaved(sender, e);
    Entity entity = (Entity)sender;
    var operationArgs = new EntityOwnerEventAsyncOperationArgs(entity, e);

    if (entity.UserConnection.GetIsFeatureEnabled("ChangeEntityActivitiesAndProcessOwner")
            && IsOwnerChanged(operationArgs)) {
        var asyncExecutor = ClassFactory.Get<IEntityEventAsyncExecutor>(
            new ConstructorArgument("userConnection", entity.UserConnection));
        asyncExecutor.ExecuteAsync<EntityActivityOwnerAsyncExecutor>(operationArgs);
    }
}
```

Важные детали:

- запуск идёт после успешного сохранения;
- проверяется feature flag;
- передаются старые и новые значения через operation args;
- тяжёлая работа не выполняется синхронно в listener.

## App listener как регистратор Quartz jobs

`OnAppStart` часто используется для регистрации фоновых задач.

```csharp
public void OnAppStart(AppEventContext context) {
    UserConnection userConnection = GetUserConnection(context);
    var appSchedulerWrapper = ClassFactory.Get<IAppSchedulerWraper>();
    ProcessMaintenanceJob.Register(userConnection, appSchedulerWrapper);
}
```

Сам job реализует `IJobExecutor` и выполняется уже планировщиком.

## Idempotent registration

Для jobs нужен контроль повторной регистрации.

```csharp
if (!AppScheduler.DoesJobExist(className, jobGroupName)) {
    AppScheduler.ScheduleMinutelyJob<TJob>(
        jobGroupName,
        UserConnection.Workspace.Name,
        UserConnection.CurrentUser.Name,
        periodInMinutes,
        null,
        true);
}
```

Альтернатива: remove-and-recreate, если нужно применить изменившиеся настройки.

```csharp
if (appSchedulerWrapper.DoesJobExist(jobName, jobGroup)) {
    appSchedulerWrapper.RemoveJob(jobName, jobGroup);
}
appSchedulerWrapper.Instance.ScheduleJob(job, trigger);
```

## ProcessJob из App EventListener

`AnniversaryRemindingsEventListener.Base.cs` регистрирует process job по cron из SysSettings.

```csharp
IJobDetail job = AppScheduler.CreateProcessJob(
    processJob,
    processJobGroup,
    "GenerateAnniversaryRemindings",
    UserConnection.Workspace.Name,
    UserConnection.CurrentUser.Name,
    null,
    true);
ITrigger trigger = new CronTriggerImpl(processTrigger, processJobGroup, cronTrigger);
AppScheduler.Instance.ScheduleJob(job, trigger);
```

Такой подход подходит, когда бизнес-логика уже реализована процессом.

## Self-healing settings

Некоторые jobs сравнивают текущие параметры с initial parameters и перерегистрируются.

```csharp
int maintenanceFrequency = GetMaintenanceFrequencySysSetting(userConnection);
if (maintenanceFrequency != initialFrequency) {
    Register(userConnection, _appSchedulerWrapper, maintenanceFrequency);
}
```

Это полезно для SysSettings, которые меняют периодичность jobs без ручной переконфигурации.

## Что не стоит делать

- Не запускайте тяжёлую job-логику напрямую в `OnAppStart`.
- Не создавайте job без проверки существования или стратегии удаления.
- Не храните mutable state job'а в static-полях listener'а.
- Не ставьте job от имени случайного текущего пользователя, если нужен системный контекст.
- Не используйте listener как универсальный scheduler service.

## Связанные документы

- [EventListeners Overview](event-listeners-overview.md)
- [EventListener app lifecycle](event-listeners-app-lifecycle.md)
- [EventListener validation and safety](event-listeners-validation-and-safety.md)
- [Quartz AppScheduler API](quartz-appscheduler-api.md)
- [Quartz registration patterns](quartz-registration-patterns.md)
- [Quartz class jobs](quartz-class-jobs.md)
