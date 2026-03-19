# Планировщик задач (Quartz / AppScheduler)

<!-- Версия: 1.0 | Обновлено: 2026-03-19 | Платформа: BPMSoft 1.9 -->
<!-- Теги: Quartz, планировщик, AppScheduler, IJobExecutor, cron, фоновые задачи -->

## Обзор

BPMSoft использует **Quartz.NET** для планирования фоновых задач. Платформа предоставляет обёртку `AppScheduler` (из `BPMSoft.Core.Scheduler`), которая упрощает создание задач, триггеров и управление планировщиком.

**Namespace:** `BPMSoft.Core.Scheduler`
**Quartz namespace:** `Quartz`, `Quartz.Impl.Triggers`

**Ключевые классы:**

| Класс | Namespace | Назначение |
|-------|-----------|------------|
| `AppScheduler` | `BPMSoft.Core.Scheduler` | Основной фасад для работы с Quartz |
| `IAppSchedulerWraper` | `BPMSoft.Core.Scheduler` | DI-обёртка над AppScheduler |
| `QuartzJobTriggerManager` | `BPMSoft.Configuration` | Менеджер для запуска процессов через Quartz |
| `SchedulerUtils` | `BPMSoft.Configuration` | Утилиты (удаление старых задач, планирование) |
| `SchedulerJobService` | `BPMSoft.Configuration` | WCF-сервис для управления задачами с клиента |
| `PeriodicitySettingsUtilities` | `BPMSoft.Configuration` | Планирование по настройкам периодичности |
| `JobConfig` | `BPMSoft.Configuration` | Конфигурация задачи |

---

## Типы задач

### 1. Задача-процесс (ProcessJob)

Запускает бизнес-процесс BPMSoft по расписанию:

```csharp
IJobDetail job = AppScheduler.CreateProcessJob(
    jobName,           // имя задачи
    jobGroup,          // группа
    processName,       // имя бизнес-процесса
    workspaceName,     // рабочее пространство
    userName,          // пользователь
    parameters,        // параметры (Dictionary<string, object>)
    isSystemUser       // от имени системного пользователя
);
```

### 2. Задача-класс (ClassJob)

Запускает C#-класс, реализующий `IJobExecutor`:

```csharp
IJobDetail job = appSchedulerWrapper.CreateClassJob<MyJob>(
    jobName,           // имя задачи
    jobGroup,          // группа
    userConnection,    // подключение
    parameters,        // параметры
    isSystemUser       // от имени системного пользователя
);
```

Класс задачи должен реализовать интерфейс:

```csharp
[DefaultBinding(typeof(IJobExecutor), Name = nameof(MyJob))]
public class MyJob : IJobExecutor
{
    public void Execute(UserConnection userConnection, IDictionary<string, object> parameters) {
        // Бизнес-логика
    }
}
```

---

## API AppScheduler

### Создание задач

```csharp
using BPMSoft.Core.Scheduler;

// Создать ProcessJob (не запускает — только создаёт IJobDetail)
IJobDetail job = AppScheduler.CreateProcessJob(jobName, jobGroup, processName,
    workspaceName, userName);

// Создать ClassJob через DI-обёртку
var wrapper = ClassFactory.Get<IAppSchedulerWraper>();
IJobDetail job = wrapper.CreateClassJob<MyJobExecutor>(jobName, jobGroup,
    userConnection, parameters, isSystemUser: true);
```

### Планирование

```csharp
// Запуск по расписанию (cron)
ITrigger trigger = new CronTriggerImpl(triggerName, triggerGroup, "0 0 3 * * ?");
AppScheduler.Instance.ScheduleJob(job, trigger);

// Запуск с интервалом (Simple trigger)
ITrigger trigger = TriggerBuilder.Create()
    .WithSimpleSchedule(s => s.WithIntervalInMinutes(5).RepeatForever())
    .StartNow()
    .Build();
AppScheduler.Instance.ScheduleJob(job, trigger);

// Одноразовый запуск через N минут
ITrigger trigger = TriggerBuilder.Create()
    .WithIdentity("MyTrigger")
    .StartAt(DateTimeOffset.Now.AddMinutes(10))
    .Build();
AppScheduler.Instance.ScheduleJob(job, trigger);
```

### Готовые методы планирования

```csharp
// Периодическая задача-процесс (каждые N минут)
AppScheduler.ScheduleMinutelyProcessJob(jobName, jobGroup, processName,
    workspaceName, userName, periodInMinutes);

// Периодическая задача-класс (каждые N минут)
AppScheduler.ScheduleMinutelyJob<MyJobExecutor>(jobGroup,
    workspaceName, userName, periodInMinutes, parameters, isSystemUser: true);

// Немедленный одноразовый запуск процесса
AppScheduler.ScheduleImmediateProcessJob(jobName, jobGroup, processName,
    workspaceName, userName);

// Запуск существующей задачи (если уже зарегистрирована)
AppScheduler.TriggerJob(jobName, jobGroup, processName,
    workspaceName, userName, parameters);
```

### Проверка и удаление

```csharp
// Проверить существование задачи
bool exists = AppScheduler.DoesJobExist(jobName, jobGroup);

// Удалить задачу
AppScheduler.RemoveJob(jobName, jobGroup);

// Работа с именованным планировщиком
IScheduler scheduler = AppScheduler.GetSchedulerOrDefault(schedulerName);
AppScheduler.RemoveJob(jobName, jobGroup, scheduler);
bool exists = AppScheduler.DoesJobExist(jobName, jobGroup, scheduler);
```

---

## Cron-выражения

| Выражение | Описание |
|-----------|----------|
| `0 0 3 * * ?` | Ежедневно в 3:00 |
| `0 0/10 * * * ? *` | Каждые 10 минут |
| `0 30 1 ? * *` | Ежедневно в 1:30 |
| `0 {M} {H} ? * *` | Ежедневно в H:M |

Формат: `секунды минуты часы день_месяца месяц день_недели [год]`

---

## QuartzJobTriggerManager — запуск процессов

Синглтон для немедленного или отложенного запуска процессов:

```csharp
// Конфигурация задачи
var jobConfig = new JobConfig(
    processName: "MyProcess",
    workspaceName: userConnection.Workspace.Name,
    userName: userConnection.CurrentUser.Name,
    parameters: new Dictionary<string, object> {
        { "ParamName", paramValue }
    }
);

// Немедленный запуск (TriggerJob)
QuartzJobTriggerManager.Instance.RunTriggerJob(jobConfig);

// Запуск через ScheduleJob (с контролем misfire)
QuartzJobTriggerManager.Instance.RunScheduleJob(jobConfig,
    MisfireInstruction.SimpleTrigger.FireNow);
```

### JobConfig

```csharp
public class JobConfig
{
    public string ProcessName { get; set; }        // имя процесса
    public string JobGroup { get; set; }           // группа (авто: ProcessName + "Group")
    public string JobName { get; set; }            // имя (авто: Guid.NewGuid())
    public string WorkspaceName { get; set; }      // рабочее пространство
    public string UserName { get; set; }           // пользователь
    public bool IsSystemUser { get; set; }         // системный пользователь
    public IDictionary<string, object> Parameters { get; set; }
    public JobOptions JobOptions { get; set; }
}
```

---

## SchedulerUtils — утилиты

```csharp
// Удалить старые задачи по имени группы
SchedulerUtils.DeleteOldJobs("OldJobName");
SchedulerUtils.DeleteOldJobs(new List<string> { "Job1", "Job2" });

// Запланировать следующий запуск (удаляет старый, создаёт новый)
SchedulerUtils.ScheduleNextRun(userConnection, "MyJob", myJobExecutor, periodInMinutes: 60);
```

---

## SchedulerJobService — WCF-сервис

**URL:** `/0/rest/SchedulerJobService/{Method}`

Позволяет управлять задачами с клиента:

| Метод | Описание |
|-------|----------|
| `CreateSyncJob` | Создать периодическую задачу-процесс |
| `CreateImmediateSyncJob` | Одноразовый немедленный запуск процесса |
| `CreateSyncJobByPeriodicity` | Создать по настройкам периодичности (PeriodicitySettings) |
| `CreateSyncJobWithResponse` | CreateSyncJob с ответом (ConfigurationServiceResponse) |
| `CheckIfJobExist` | Проверить существование задачи |

```javascript
// Пример вызова с клиента
BPMSoft.AjaxProvider.request({
    url: BPMSoft.workspaceBaseUrl + "/rest/SchedulerJobService/CreateSyncJob",
    jsonData: {
        JobName: "MySyncJob",
        SyncJobGroupName: "MySyncGroup",
        SyncProcessName: "MyProcess",
        periodInMinutes: 30,
        recreate: true
    }
});
```

---

## Паттерн: регистрация задачи при старте приложения

Типовой способ — `IAppEventListener` + `OnAppStart`:

### Пример 1: Cron-задача (ежедневная)

```csharp
using BPMSoft.Core.Scheduler;
using BPMSoft.Web.Common;
using Quartz;
using Quartz.Impl.Triggers;

public class MyRemindingsEventListener : IAppEventListener
{
    private const string ProcessName = "GenerateAnniversaryRemindings";
    private const string DefaultCron = "0 0 3 * * ?";

    public void OnAppStart(AppEventContext context) {
        var appConnection = (AppConnection)context.Application["AppConnection"];
        var userConnection = appConnection.SystemUserConnection;

        string jobName = ProcessName + "Job";
        string jobGroup = ProcessName + "JobGroup";

        // Читаем cron из системной настройки
        string cron = SysSettings.GetValue<string>(userConnection,
            "GenerateRemindingsByCronTrigger", DefaultCron);

        if (!AppScheduler.DoesJobExist(jobName, jobGroup)) {
            IJobDetail job = AppScheduler.CreateProcessJob(jobName, jobGroup, ProcessName,
                userConnection.Workspace.Name, userConnection.CurrentUser.Name,
                null, true);
            ITrigger trigger = new CronTriggerImpl(ProcessName + "Trigger", jobGroup, cron);
            AppScheduler.Instance.ScheduleJob(job, trigger);
        }
    }

    public void OnAppEnd(AppEventContext context) { }
    public void OnSessionStart(AppEventContext context) { }
    public void OnSessionEnd(AppEventContext context) { }
}
```

**Источник:** `AnniversaryRemindingsEventListener.Base.cs`

### Пример 2: Интервальная ClassJob (каждые N минут)

```csharp
using BPMSoft.Core.Factories;
using BPMSoft.Core.Scheduler;
using BPMSoft.Web.Common;
using Quartz;

public class ProcessMaintenanceEventListener : IAppEventListener
{
    public void OnAppStart(AppEventContext context) {
        var appConnection = (AppConnection)context.Application["AppConnection"];
        var userConnection = appConnection.SystemUserConnection;
        var wrapper = ClassFactory.Get<IAppSchedulerWraper>();
        ProcessMaintenanceJob.Register(userConnection, wrapper);
    }
    // ...
}

[DefaultBinding(typeof(IJobExecutor), Name = nameof(ProcessMaintenanceJob))]
public class ProcessMaintenanceJob : IJobExecutor
{
    public static string ProcessMaintenanceJobFrequency => "ProcessMaintenanceJobFrequencyMinutes";
    public static int DefaultFrequency => 5;

    public static void Register(UserConnection userConnection, IAppSchedulerWraper wrapper) {
        string jobName = typeof(ProcessMaintenanceJob).FullName;
        string jobGroup = "ProcessMaintenanceGroup";

        // Удаляем старую задачу если есть
        if (wrapper.DoesJobExist(jobName, jobGroup)) {
            wrapper.RemoveJob(jobName, jobGroup);
        }

        int frequency = SysSettings.GetValue(userConnection,
            ProcessMaintenanceJobFrequency, DefaultFrequency);
        if (frequency <= 0) return;

        // Создаём ClassJob
        IJobDetail job = wrapper.CreateClassJob<ProcessMaintenanceJob>(
            jobName, jobGroup, userConnection,
            new Dictionary<string, object> { { "initialFrequency", frequency } },
            true);

        // Триггер с интервалом
        ITrigger trigger = TriggerBuilder.Create()
            .WithSimpleSchedule(s => s.WithIntervalInMinutes(frequency).RepeatForever())
            .StartNow()
            .Build();

        wrapper.Instance.ScheduleJob(job, trigger);
    }

    public void Execute(UserConnection userConnection, IDictionary<string, object> parameters) {
        // Бизнес-логика задачи
    }
}
```

**Источник:** `ProcessMaintenanceEventListener.Base.cs`

### Пример 3: ScheduleMinutelyJob (простой способ)

```csharp
public class SecurityTokenJobManager : AppEventListenerBase
{
    private const int ExecutionPeriod = 1440; // 24 часа в минутах
    private const string JobGroupName = "SecurityTokenGroup";

    public override void OnAppStart(AppEventContext context) {
        base.OnAppStart(context);
        var userConnection = GetUserConnection(context);

        if (userConnection.GetIsFeatureEnabled("SecureEstimation")) {
            string className = typeof(SecurityTokenCleaner).AssemblyQualifiedName;
            if (!AppScheduler.DoesJobExist(className, JobGroupName)) {
                AppScheduler.ScheduleMinutelyJob<SecurityTokenCleaner>(
                    JobGroupName,
                    userConnection.Workspace.Name,
                    userConnection.CurrentUser.Name,
                    ExecutionPeriod,  // каждые 1440 минут = 24 часа
                    null,
                    true);
            }
        } else {
            string className = typeof(SecurityTokenCleaner).AssemblyQualifiedName;
            AppScheduler.RemoveJob(className, JobGroupName);
        }
    }
}
```

**Источник:** `SecurityTokenJobManager.Base.cs`

### Пример 4: Cron из системной настройки (актуализация возраста)

```csharp
public void ScheduleNewAgeActualizationJob(UserConnection userConnection) {
    var actualizationTime = SysSettings.GetValue<DateTime>(
        userConnection, "AutomaticAgeActualizationTime", DateTime.MinValue);

    var jobDetail = AppScheduler.CreateProcessJob(
        "ContactAgeActualizationJob",
        "AgeActualizationJobGroup",
        "ContactAgeActualizationRunnerProcess",
        userConnection.Workspace.Name,
        userConnection.CurrentUser.Name);

    // Cron: ежедневно в указанное время
    var cronTrigger = new CronTriggerImpl(
        "ContactAgeActualizationJob",
        "AgeActualizationJobGroup",
        string.Format("0 {0} {1} ? * *",
            actualizationTime.Minute, actualizationTime.Hour));

    AppScheduler.Instance.ScheduleJob(jobDetail, cronTrigger);
}

public void RemoveAgeActualizationJob() {
    AppScheduler.RemoveJob("ContactAgeActualizationJob", "AgeActualizationJobGroup");
}
```

**Источник:** `ContactAgeActualizationJobRestartProcess.Base.cs`

### Пример 5: IMAP-синхронизация (периодическая per-user)

```csharp
public class ImapSyncJobScheduler : IImapSyncJobScheduler
{
    private const string SyncProcessName = "SyncImapMail";
    private const string SyncJobGroupName = "IMAP";

    // Имя задачи уникально для каждого пользователя и ящика
    private string GetSyncJobName(UserConnection uc, IDictionary<string, object> parameters) {
        var parts = new List<string> { "SyncImap" };
        if (parameters?.TryGetValue("SenderEmailAddress", out var email) == true) {
            parts.Add(email.ToString());
        }
        parts.Add(uc.CurrentUser.Id.ToString());
        return string.Join("_", parts);
    }

    public void CreateSyncJob(UserConnection uc, int periodInMinutes,
            IDictionary<string, object> parameters = null) {
        RemoveSyncJob(uc, parameters);
        string syncJobName = GetSyncJobName(uc, parameters);
        AppScheduler.ScheduleMinutelyJob(syncJobName, SyncJobGroupName, SyncProcessName,
            uc.Workspace.Name, uc.CurrentUser.Name, periodInMinutes, parameters);
    }

    public bool DoesSyncJobExist(UserConnection uc, IDictionary<string, object> parameters = null) {
        return AppScheduler.DoesJobExist(GetSyncJobName(uc, parameters), SyncJobGroupName);
    }

    public void RemoveSyncJob(UserConnection uc, IDictionary<string, object> parameters = null) {
        AppScheduler.RemoveJob(GetSyncJobName(uc, parameters), SyncJobGroupName);
    }
}
```

**Источник:** `ImapSyncJobScheduler.Base.cs`

---

## Таблица зарегистрированных задач базового решения

| Задача | Тип | Расписание | Системная настройка | Файл |
|--------|-----|-----------|---------------------|------|
| GenerateAnniversaryRemindings | ProcessJob (Cron) | Ежедневно 3:00 | `GenerateRemindingsByCronTrigger` | `AnniversaryRemindingsEventListener.Base.cs` |
| ProcessMaintenanceJob | ClassJob (Interval) | Каждые 5 мин | `ProcessMaintenanceJobFrequencyMinutes` | `ProcessMaintenanceEventListener.Base.cs` |
| ProcessTempDataCleanupJob | ClassJob (Interval) | Каждые 60 мин | `ProcessTempDataCleanupJobFrequencyMinutes` | `ProcessTempDataCleanupEventListener.Base.cs` |
| SecurityTokenCleaner | ClassJob (Minutely) | Каждые 24 часа | Feature `SecureEstimation` | `SecurityTokenJobManager.Base.cs` |
| ContactAgeActualizationJob | ProcessJob (Cron) | По настройке | `AutomaticAgeActualizationTime` | `ContactAgeActualizationJobRestartProcess.Base.cs` |
| SyncImap_{user} | ProcessJob (Minutely) | По настройке | — | `ImapSyncJobScheduler.Base.cs` |
| MailSyncJob | ClassJob (Interval) | Каждые 60 мин | `MailReSynchronizationFrequency` | `MailSyncEventListener.MailSync.cs` |
| TouchQueueJobDispatcher | ClassJob (Minutely) | Каждую 1 мин | — | `TouchQueueJobDispatcher.TouchPoints.cs` |
| InsightSynchronizationServiceJob | ClassJob (Cron) | Каждые 10 мин | — | `InsightSynchronizationServiceEventListener.InsightReport.cs` |
| EmailMiningJob | ClassJob (Immediate) | Однократно | — | `EmailMiningAppListener.EmailMining.cs` |
| DuplicatesSearchJob | ProcessJob (Immediate) | Однократно | — | `StartGlobalDuplicatesSearchSchema.Base.cs` |

---

## Паттерн: перепланирование при изменении частоты

Задача может сама себя перепланировать при изменении системной настройки:

```csharp
public class ProcessMaintenanceJob : IJobExecutor
{
    public void Execute(UserConnection userConnection, IDictionary<string, object> parameters) {
        int initialFrequency = (int)parameters["initialFrequency"];
        int currentFrequency = SysSettings.GetValue(userConnection,
            "ProcessMaintenanceJobFrequencyMinutes", 5);

        // Если частота изменилась — перерегистрация
        if (currentFrequency != initialFrequency) {
            Register(userConnection, _appSchedulerWrapper, currentFrequency);
        }

        // Основная работа
        _processLogMaintainer.ExecuteStep();
    }
}
```

---

## PeriodicitySettingsUtilities — гибкое расписание

Для создания сложных расписаний (ежедневно/еженедельно/ежемесячно, однократно/многократно в день):

```csharp
var periodicityUtils = new PeriodicitySettingsUtilities(userConnection, periodicitySettingsId);
periodicityUtils.CreateTrigger(jobName, jobGroup, processName, workspaceName, userName);
```

Поддерживает:
- **Ежедневно** (IsDaily) — однократно в заданное время или многократно в интервале From–Till
- **Еженедельно** (IsWeekly) — в указанный день недели
- **Ежемесячно** (IsMonthly) — в указанный день месяца или последний день

---

## Именованные планировщики

Для изоляции задач можно использовать отдельные экземпляры Quartz-планировщика:

```csharp
// Получить именованный планировщик (или default)
IScheduler scheduler = AppScheduler.GetSchedulerOrDefault("TouchPointsQuartzScheduler");

// Все операции с указанием планировщика
AppScheduler.RemoveJob(jobName, jobGroup, scheduler);
AppScheduler.DoesJobExist(jobName, jobGroup, scheduler);
AppScheduler.ScheduleMinutelyProcessJob(jobName, jobGroup, processName,
    workspaceName, userName, periodInMinutes, scheduler: scheduler);
```

---

## Типовые сценарии

### 1. Ежедневная задача по cron

```csharp
public class DailyReportListener : IAppEventListener
{
    public void OnAppStart(AppEventContext context) {
        var appConnection = (AppConnection)context.Application["AppConnection"];
        var uc = appConnection.SystemUserConnection;
        string jobName = "DailyReportJob";
        string jobGroup = "DailyReportGroup";

        if (!AppScheduler.DoesJobExist(jobName, jobGroup)) {
            IJobDetail job = AppScheduler.CreateProcessJob(jobName, jobGroup,
                "GenerateDailyReport", uc.Workspace.Name, uc.CurrentUser.Name, null, true);
            ITrigger trigger = new CronTriggerImpl(jobName + "Trigger", jobGroup,
                "0 0 6 * * ?"); // каждый день в 6:00
            AppScheduler.Instance.ScheduleJob(job, trigger);
        }
    }
    public void OnAppEnd(AppEventContext context) { }
    public void OnSessionStart(AppEventContext context) { }
    public void OnSessionEnd(AppEventContext context) { }
}
```

### 2. Периодическая ClassJob каждые N минут

```csharp
[DefaultBinding(typeof(IJobExecutor), Name = nameof(DataSyncJob))]
public class DataSyncJob : IJobExecutor
{
    public void Execute(UserConnection userConnection, IDictionary<string, object> parameters) {
        // Синхронизация данных
    }

    public static void Register(UserConnection uc) {
        string jobName = typeof(DataSyncJob).FullName;
        string jobGroup = "DataSyncGroup";
        if (!AppScheduler.DoesJobExist(jobName, jobGroup)) {
            AppScheduler.ScheduleMinutelyJob<DataSyncJob>(
                jobGroup, uc.Workspace.Name, uc.CurrentUser.Name,
                periodInMinutes: 15, parameters: null, isSystemUser: true);
        }
    }
}
```

### 3. Одноразовый запуск процесса

```csharp
AppScheduler.ScheduleImmediateProcessJob(
    "OneTimeExport_" + Guid.NewGuid(),
    "ExportGroup",
    "ExportDataProcess",
    userConnection.Workspace.Name,
    userConnection.CurrentUser.Name);
```

### 4. Per-user задача синхронизации

```csharp
string syncJobName = $"MailSync_{userConnection.CurrentUser.Id}";
string syncGroup = "MailSyncGroup";

if (AppScheduler.DoesJobExist(syncJobName, syncGroup)) {
    AppScheduler.RemoveJob(syncJobName, syncGroup);
}

var parameters = new Dictionary<string, object> {
    { "SenderEmailAddress", "user@company.com" },
    { "MailboxId", mailboxId.ToString() }
};
AppScheduler.ScheduleMinutelyJob(syncJobName, syncGroup, "SyncImapMail",
    userConnection.Workspace.Name, userConnection.CurrentUser.Name,
    periodInMinutes: 5, parameters: parameters);
```

---

## Антипаттерны

| ❌ Неправильно | ✅ Правильно |
|---------------|-------------|
| Регистрация задачи без проверки `DoesJobExist` — приводит к дублированию задач при каждом рестарте | Всегда проверять `AppScheduler.DoesJobExist(jobName, jobGroup)` перед созданием |
| Задача без обработки исключений — необработанное исключение может остановить весь планировщик | Оборачивать `Execute` в `try/catch`, логировать ошибки |
| Слишком частый интервал (< 1 мин) без реальной необходимости — нагрузка на CPU и БД | Использовать минимально достаточный интервал; для реакции в реальном времени использовать EventListener'ы |

---

## Troubleshooting

| Ошибка / Симптом | Причина | Решение |
|-----------------|---------|---------|
| Задача не запускается | Задача не зарегистрирована или была удалена | Проверить `AppScheduler.DoesJobExist(...)`, просмотреть логи Quartz в `Common.Logging` |
| Задача запускается, но ничего не делает | `UserConnection` создан без нужных прав (не `isSystemUser`) | Передать `isSystemUser: true` при создании задачи |
| Cron-выражение не работает | Некорректный формат (нужно 6-7 полей) | Проверить формат: `секунды минуты часы день_месяца месяц день_недели [год]`; валидировать на crontab.guru |
| Задача выполняется дважды | Дубль регистрации при рестарте приложения | Добавить `DoesJobExist` + `RemoveJob` перед повторной регистрацией |

**Советы по отладке:**
- Включить логирование Quartz: `Common.Logging` уровень `DEBUG` для `Quartz.*`
- Проверить триггеры: `AppScheduler.Instance.GetTriggersOfJob(jobKey)`
- Для тестирования использовать `AppScheduler.TriggerJob(...)` для немедленного запуска

---

## Связанные темы

- [EventListener'ы](event-listeners.md)
- [Процессы](processes.md)
- [Архитектура](../architecture/platform-overview.md)
