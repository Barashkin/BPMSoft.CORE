# Quartz / AppScheduler Troubleshooting

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: Quartz, AppScheduler, troubleshooting, scheduler, jobs -->

> Практический troubleshooting-документ для случаев, когда Quartz-задача не создаётся, не исполняется, запускается не там или “теряется” после старта системы.

## Быстрый чек-лист

Если Quartz-сценарий не работает, проверьте по порядку:

1. создаётся ли job вообще;
1. в том ли scheduler instance она ищется;
1. есть ли у job trigger;
1. не снята ли задача кодом `RemoveJob(...)`;
1. не изменились ли `SysSettings`, влияющие на частоту/включение;
1. не упирается ли сценарий в timezone/misfire;
1. не относится ли он к `PeriodicitySettingsUtilities` с её ограничениями.

## Симптом: задача не создаётся

### Что проверить

- вызывается ли `Register(...)` / `CreateSyncJob(...)` / `CreateTrigger(...)`;
- не срабатывает ли ранний `return`;
- не отрицателен ли `periodInMinutes`;
- не равен ли `recreate` значению `false`;
- найден ли `PeriodicitySettings` record.

### Типовые причины

| Причина | Где встречается |
| ----- | ----- |
| `periodInMinutes < 0` | `SchedulerJobService` |
| `recreate == false` | `SchedulerJobService` |
| `maintenanceFrequency <= 0` | `ProcessMaintenanceJob`, `MailSyncJob` |
| sys setting отключает механизм | `MailSyncJob`, `EmailMiningJob`, ML job |
| запись периодичности не найдена | `PeriodicitySettingsUtilities` |

## Симптом: задача была, но исчезла

### Что проверить

- нет ли перед созданием обязательного `RemoveJob(...)`;
- не вызывается ли remove из другого сценария;
- не удаляет ли self-healing код старую задачу перед перерегистрацией;
- не переехала ли задача в другой scheduler instance.

Типичные источники удаления:

- `SchedulerJobService.CreateSyncJob(...)`
- `ProcessMaintenanceJob.Register(...)`
- `MailSyncJob.Register(...)`
- `PeriodicitySettingsUtilities.CreateTrigger(...)`
- `SchedulerUtils.DeleteOldJobs(...)`

## Симптом: задача есть, но не исполняется

### Что проверить

1. trigger существует и привязан к job;
1. trigger не находится в `Blocked`, `Paused` или `Error`;
1. next fire time не ушёл в прошлое;
1. scheduler выбран правильный.

### Где есть готовая recovery-логика

- `BaseQueueJobDispatcher.TryRescheduleJob()`

Она:

- снимает broken trigger'ы;
- возобновляет paused trigger'ы;
- удаляет job без trigger'ов;
- заново планирует monitoring job.

Если ваш сценарий похож на queue/monitoring pattern, это главный рабочий reference.

## Симптом: задача запускается не в том scheduler

### Что проверить

- передаётся ли `schedulerName`;
- не используется ли default scheduler вместо named scheduler;
- не осталось ли legacy trigger'ов в default scheduler.

Критичные примеры:

- `LdapQuartzScheduler`
- `TouchPointsQuartzScheduler`

Подсказка:

- если код создаёт job через named scheduler, искать её в default instance бессмысленно.

## Симптом: immediate запуск не работает как ожидалось

### Что проверить

- не вызывается ли `CreateSyncJobWithResponse` с `periodInMinutes == 0`;
- не ожидает ли клиент periodic job, хотя сервер делает immediate fire;
- правильно ли читается `CreateSyncJobWithResponseResult`.

Это типичная ловушка UI-кода вокруг `SchedulerJobService`.

## Симптом: частота изменилась, но job работает по-старому

### Что проверить

- есть ли внутри `Execute(...)` сравнение `initialFrequency` и актуального `SysSetting`;
- действительно ли используется self-healing register pattern;
- не хранится ли старая job в scheduler без пере-регистрации.

Reference:

- `ProcessMaintenanceJob`
- `MailSyncJob`

## Симптом: задача запускается “не в то время”

### Что проверить

- UTC или user timezone используется в trigger;
- есть ли `StartAt/EndAt`;
- не был ли `schedulerStart` сдвинут на следующий день;
- нет ли зависимости от `CurrentUser.TimeZone`;
- не исходит ли расписание из `PeriodicitySettings`.

Ключевые места:

- `PeriodicitySettingsUtilities.Base.cs`
- `BSSchedulerService.BPMSoftSender.cs`

## Симптом: cron создан, но не срабатывает

### Что проверить

- корректна ли cron-строка Quartz-формата;
- не ушёл ли `next fire time` в прошлое;
- не нужен ли `RescheduleJob(...)` после коррекции;
- не конфликтует ли trigger с `StartAt/EndAt`.

Для sender-паттерна есть готовый пример пересчёта next run в:

- `BSSchedulerService.BPMSoftSender.cs`

## Симптом: job по `PeriodicitySettings` ведёт себя странно

### Что проверить

- не задействована ли недописанная ветка weekly/monthly multi-run;
- не форсируется ли `IsDaily = true`;
- не используется ли общий `DailyCalendar` неожиданным образом;
- корректен ли `CustomPeriodType`.

Если сценарий критичен, лучше проверить необходимость явного `CronTriggerImpl` вместо `PeriodicitySettingsUtilities`.

## Симптом: job постоянно пересоздаётся

### Что проверить

- не меняется ли динамически sys setting на каждом run;
- корректно ли записан `initialFrequency` в job parameters;
- не вызывает ли код `Register(...)` при каждом `Execute(...)` без необходимости.

## Симптом: после ошибки задача больше не восстанавливается

### Что проверить

- не относится ли она к обычному `ClassJob`, у которого нет recovery слоя;
- нужен ли отдельный failover-monitor job;
- не стоит ли вынести логику в `BaseQueueJobDispatcher`-подобную базу.

## Полезные точки кода

| Вопрос | Файл |
| ----- | ----- |
| Общий Quartz overview | `docs/server/scheduler-quartz.md` |
| API фасад и wrapper | `docs/server/quartz-appscheduler-api.md` |
| Trigger/misfire/timezone | `docs/server/quartz-triggers-cron.md` |
| Service facade | `docs/server/quartz-schedulerjobservice.md` |
| Periodicity conversion | `docs/server/quartz-periodicity-settings.md` |
| Recovery pattern | `Autogenerated/Src/BaseQueueJobDispatcher.TasksQueue.cs` |
| Self-healing class job | `Autogenerated/Src/ProcessMaintenanceEventListener.Base.cs` |
| UI service call | `Autogenerated/Src/GoogleIntegrationSettingsModule.NUI.js` |

## Связанные документы

- [Обзор Quartz](scheduler-quartz.md)
- [AppScheduler API](quartz-appscheduler-api.md)
- [Triggers, cron и misfire](quartz-triggers-cron.md)
- [ClassJob и IJobExecutor](quartz-class-jobs.md)
- [Паттерны регистрации Quartz задач](quartz-registration-patterns.md)
- [SchedulerJobService](quartz-schedulerjobservice.md)
- [PeriodicitySettingsUtilities](quartz-periodicity-settings.md)
