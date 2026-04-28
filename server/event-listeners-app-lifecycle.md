# EventListener App Lifecycle

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: EventListener, IAppEventListener, AppEventListenerBase, OnAppStart, OnAppEnd -->

> App EventListener'ы обрабатывают старт и остановку приложения, а также события пользовательских сессий.

## Контракт

Минимальный вариант:

```csharp
public class MyAppEventListener : IAppEventListener
{
    public void OnAppStart(AppEventContext context) {
        // initialization
    }

    public void OnAppEnd(AppEventContext context) {
    }

    public void OnSessionStart(AppEventContext context) {
    }

    public void OnSessionEnd(AppEventContext context) {
    }
}
```

Если нужен базовый lifecycle-код платформы, используйте `AppEventListenerBase` и вызывайте `base`.

```csharp
public class MyAppEventListener : AppEventListenerBase
{
    public override void OnAppStart(AppEventContext context) {
        base.OnAppStart(context);
        // initialization
    }
}
```

## Получение SystemUserConnection

На старте приложения обычно нет пользовательского UI-контекста, поэтому берут `SystemUserConnection`.

```csharp
protected UserConnection GetUserConnection(AppEventContext context) {
    var appConnection = (AppConnection)context.Application["AppConnection"];
    return appConnection.SystemUserConnection;
}
```

Такой подход используется в `ProcessMaintenanceEventListener.Base.cs`, `OmnichannelMessagingAppEventListener.OmnichannelMessaging.cs` и других app-listener'ах.

## Типовые задачи OnAppStart

| Задача | Пример |
| --- | --- |
| зарегистрировать Quartz job | `ProcessMaintenanceEventListener.Base.cs` |
| настроить named bindings | `OmnichannelMessagingAppEventListener.OmnichannelMessaging.cs` |
| инициализировать notifier | `OmnichannelMessagingAppEventListener.OmnichannelMessaging.cs` |
| выполнить warmup | `WarmupUtilities.Base.cs` |
| запустить maintenance-инфраструктуру | `ProcessMaintenanceEventListener.Base.cs` |

## Регистрация ClassFactory bindings

App listener подходит для привязки интерфейсов к реализациям.

```csharp
ClassFactory.Bind<IMessengerRegistrationWorker, FacebookRegistrationWorker>(
    ChannelType.Facebook.ToString());
ClassFactory.Bind<IProfileDataProvider, TelegramProfileDataProvider>(
    ChannelType.Telegram.ToString());
```

Такая логика должна быть идемпотентной: повторный старт приложения или перекомпиляция пакета не должны ломать bindings.

## OnAppEnd

`OnAppEnd` используют для очистки application cache или graceful shutdown.

```csharp
public override void OnAppEnd(AppEventContext context) {
    var userConnection = GetUserConnection(context);
    var cacheList = userConnection.ApplicationCache[RunTelegramChannelsJob.CacheChannelsName] as List<string>;
    if (cacheList != null) {
        userConnection.ApplicationCache.Remove(RunTelegramChannelsJob.CacheChannelsName);
    }
    base.OnAppEnd(context);
}
```

Не размещайте в `OnAppEnd` критичную бизнес-логику, которая обязана выполниться всегда: выгрузка приложения может быть аварийной.

## Практические правила

- Делайте `OnAppStart` быстрым: долгую работу выносите в Quartz job.
- Проверяйте feature flags и sys settings до запуска optional-логики.
- Не храните пользовательский `UserConnection` в static-полях.
- Для Quartz registration используйте idempotent-паттерн `DoesJobExist` или remove-and-recreate.
- В `OnAppEnd` очищайте только то, что реально принадлежит app lifecycle.

## Связанные документы

- [EventListeners Overview](event-listeners-overview.md)
- [EventListener async and jobs](event-listeners-async-and-jobs.md)
- [Quartz AppScheduler API](quartz-appscheduler-api.md)
- [Quartz registration patterns](quartz-registration-patterns.md)
