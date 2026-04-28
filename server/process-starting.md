# Process Starting

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: ProcessEngine, IProcessExecutor, ProcessModuleUtilities, executeProcess -->

> Как запускать бизнес-процессы из C#, JavaScript, сервисов и фоновых обработчиков.

## Серверный запуск по UId

Для запуска из C# используется `IProcessExecutor`.

```csharp
var processEngine = userConnection.ProcessEngine;
var processExecutor = processEngine.ProcessExecutor;
processExecutor.Execute(processSchemaUId, parameterValues);
```

Перед запуском можно проверить, что процесс существует и включён.

```csharp
ProcessSchemaManager processSchemaManager = userConnection.ProcessSchemaManager;
ISchemaManagerItem<ProcessSchema> managerItem = processSchemaManager.FindItemByUId(processSchemaUId);
return managerItem != null && managerItem.Instance.Enabled;
```

Такой паттерн встречается в массовых действиях, где процесс запускается для выбранных записей.

## Серверный запуск с output parameter

`IProcessExecutor.Execute<T>` позволяет получить выходной параметр.

```csharp
var inputParameters = new Dictionary<string, string> {
    ["WebFormDataId"] = webFormDataId.ToString()
};
return processExecutor.Execute<Guid>(processUId, "ContactId", inputParameters);
```

Используйте этот вариант, если вызывающий код должен дождаться результата процесса.

## Серверный запуск по имени

Некоторые job/helper-классы запускают процесс по имени.

```csharp
IProcessEngine processEngine = userConnection.IProcessEngine;
IProcessExecutor processExecutor = processEngine.ProcessExecutor;
processExecutor.Execute("InsightSynchronizationProcess");
```

Запуск по имени проще читать, но чувствителен к переименованию процесса.

## Клиентский запуск

На клиенте используется `BPMSoft.ProcessModuleUtilities.executeProcess` или новые утилиты ProcessEngine.

Старый метод `runProcess` помечен как obsolete и перенаправляет на `executeProcess`.

```javascript
BPMSoft.ProcessModuleUtilities.executeProcess({
    sysProcessName: "MyProcess",
    parameters: {
        ContactId: contactId
    }
});
```

`ProcessModuleUtilities.NUI.js` вызывает WCF-сервисы `ProcessEngineService` и `ProcessSchemaManagerService`, обрабатывает ошибки и показывает popup об успешном запуске.

## Параметры

На сервере параметры часто передаются как `Dictionary<string, string>`. Для Quartz ProcessJob используется `Dictionary<string, object>`.

Правила:

- имена должны совпадать с `ProcessSchemaParameter.Name`;
- Guid передавайте строкой или объектом в зависимости от API;
- для output parameter используйте точное имя результата;
- не передавайте UI-only значения без серверной валидации.

## Где запускать процесс

| Сценарий | Рекомендуемая точка запуска |
| --- | --- |
| действие на странице | client module + `executeProcess` |
| массовое действие | server helper/service + `IProcessExecutor` |
| webhook/import | service/background handler + `IProcessExecutor` |
| расписание | Quartz `ProcessJob` |
| реакция на entity event | EventListener или EventsProcess |

## Связанные документы

- [Process Overview](process-overview.md)
- [Quartz ProcessJob](process-quartz-jobs.md)
- [Services client calls](services-client-calls.md)
- [EventListener async and jobs](event-listeners-async-and-jobs.md)
