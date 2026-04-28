# AppScheduler API

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: Quartz, AppScheduler, IAppSchedulerWraper, scheduler, API -->

> Узкий справочник по основному API Quartz в BPMSoft: `AppScheduler`, `IAppSchedulerWraper`, именованные scheduler'ы и операции создания/запуска/удаления задач.

## Обзор

В BPMSoft Quartz почти никогда не используется напрямую как низкоуровневый `IScheduler` API.
Обычно код идёт через:

- статический фасад `AppScheduler`;
- DI-обёртку `IAppSchedulerWraper`.

Практическое правило:

- `AppScheduler` удобен для простых и статических сценариев;
- `IAppSchedulerWraper` удобен для DI, unit-friendly кода и работы с named scheduler.

## Основные роли

| Компонент | Роль |
| ----- | ----- |
| `AppScheduler` | статический фасад над Quartz |
| `IAppSchedulerWraper` | DI-обёртка над scheduler API |
| `IScheduler` | реальный Quartz scheduler instance |

## Базовые операции `AppScheduler`

### Создание задач

| Операция | Назначение |
| ----- | ----- |
| `CreateProcessJob(...)` | создать `ProcessJob` |
| `CreateClassJob<T>(...)` | создать `ClassJob` |

`Create*Job` только собирает `IJobDetail`, но не планирует его автоматически.

### Запуск и планирование

| Операция | Назначение |
| ----- | ----- |
| `Instance.ScheduleJob(job, trigger)` | запланировать job с trigger |
| `ScheduleMinutelyProcessJob(...)` | периодический `ProcessJob` |
| `ScheduleMinutelyJob<T>(...)` | периодический `ClassJob` |
| `ScheduleImmediateProcessJob(...)` | немедленный одноразовый запуск процесса |
| `ScheduleImmediateJob<T>(...)` | немедленный одноразовый запуск `ClassJob` |
| `TriggerJob(...)` | немедленно запустить уже существующую/создаваемую задачу |

### Проверка и удаление

| Операция | Назначение |
| ----- | ----- |
| `DoesJobExist(...)` | проверить, существует ли задача |
| `RemoveJob(...)` | удалить одну задачу |
| `RemoveGroupJobs(...)` | удалить все задачи группы |
| `GetSchedulerOrDefault(...)` | получить named scheduler или default instance |

## `IAppSchedulerWraper`

По реальному коду обёртка активно используется в:

- `ProcessMaintenanceEventListener.Base.cs`
- `MailSyncJob.MailSync.cs`
- `FileImportAppEventListener.FileImport.cs`
- `EmailMiningAppListener.EmailMining.cs`

### Когда брать wrapper вместо `AppScheduler`

- job создаётся в DI-коде;
- нужно переиспользовать `wrapper.Instance`;
- надо работать с `DoesJobExist/RemoveJob` без статического вызова;
- логика регистрации/перерегистрации должна тестироваться и инкапсулироваться.

## Типовые сигнатуры

### `CreateProcessJob(...)`

Используется, когда Quartz должен запускать бизнес-процесс.

Обычно передаются:

- `jobName`
- `jobGroup`
- `processName`
- `workspaceName`
- `userName`
- `parameters`
- `isSystemUser`

### `CreateClassJob<T>(...)`

Используется, когда Quartz должен вызвать класс, реализующий `IJobExecutor`.

Обычно передаются:

- `jobName`
- `jobGroup`
- `userConnection`
- `parameters`
- `isSystemUser`

## Именованные scheduler'ы

В коде встречаются не только default scheduler'ы.

Примеры:

- `SchedulerJobService` принимает `schedulerName`;
- `LDAPSysSettingsService.LDAP.cs` использует `LdapQuartzScheduler`;
- `TouchQueueJobDispatcher.TouchPoints.cs` работает с `TouchPointsQuartzScheduler`.

### Практический паттерн

```csharp
var scheduler = AppScheduler.GetSchedulerOrDefault(schedulerName);
AppScheduler.RemoveJob(jobName, jobGroup, scheduler);
bool exists = AppScheduler.DoesJobExist(jobName, jobGroup, scheduler);
```

Это нужно, когда subsystem живёт в отдельном scheduler instance и не должен смешиваться с default Quartz queue.

## `AppScheduler` vs `IAppSchedulerWraper`

| Вопрос | `AppScheduler` | `IAppSchedulerWraper` |
| ----- | ----- | ----- |
| Просто создать/запустить job | да | да |
| Статический utility-код | удобно | избыточно |
| DI / инъекция зависимостей | неудобно | основной вариант |
| Self-healing register logic | можно | чаще удобнее |
| Named scheduler / custom instance | можно | удобно |

## Реальные паттерны использования

### 1. Простой статический фасад

Характерен для:

- `BSSchedulerService.BPMSoftSender.cs`
- `BulkDeduplicationScheduler.Deduplication.cs`
- `AnniversaryRemindingsEventListener.Base.cs`

Паттерн:

1. удалить старую задачу;
1. создать job;
1. создать trigger;
1. вызвать `AppScheduler.Instance.ScheduleJob(...)`.

### 2. DI-регистрация `ClassJob`

Характерна для:

- `ProcessMaintenanceJob`
- `MailSyncJob`

Паттерн:

1. `ClassFactory.Get<IAppSchedulerWraper>()`;
1. `wrapper.DoesJobExist(...)`;
1. `wrapper.RemoveJob(...)`;
1. `wrapper.CreateClassJob<T>(...)`;
1. `wrapper.Instance.ScheduleJob(...)`.

### 3. Немедленный fire-and-forget запуск

Характерен для:

- `ChatOperatorNotifier.OmnichannelMessaging.cs`
- `MLAppListener.ML.cs`
- `MassLeadService.ProductCore.cs`

Паттерн:

- `AppScheduler.ScheduleImmediateJob<T>(...)`
- либо `wrapper.ScheduleImmediateJob<T>(...)`

## Что не входит в этот документ

Здесь нет подробностей по:

- cron и simple trigger - см. [quartz-triggers-cron.md](quartz-triggers-cron.md);
- `ProcessJob` и `QuartzJobTriggerManager` - см. [quartz-process-jobs.md](quartz-process-jobs.md);
- `ClassJob` и `IJobExecutor` - см. [quartz-class-jobs.md](quartz-class-jobs.md);
- регистрации при старте и self-healing - см. [quartz-registration-patterns.md](quartz-registration-patterns.md).

## Ключевые файлы

| Область | Файл |
| ----- | ----- |
| Wrapper-based registration | `Autogenerated/Src/ProcessMaintenanceEventListener.Base.cs` |
| Wrapper-based class job | `Autogenerated/Src/MailSyncJob.MailSync.cs` |
| Named scheduler via service | `Autogenerated/Src/SchedulerJobService.NUI.cs` |
| Static process scheduling | `Autogenerated/Src/BSSchedulerService.BPMSoftSender.cs` |
| Static class scheduling | `Autogenerated/Src/BSRoutingJob.BPMSoftSender.cs` |

## Связанные документы

- [Обзор Quartz](scheduler-quartz.md)
- [Triggers, cron и misfire](quartz-triggers-cron.md)
- [ProcessJob и QuartzJobTriggerManager](quartz-process-jobs.md)
- [ClassJob и IJobExecutor](quartz-class-jobs.md)
- [Паттерны регистрации Quartz задач](quartz-registration-patterns.md)
