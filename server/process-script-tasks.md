# Process Script Tasks

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: ScriptTask, ProcessScriptTask, ProcessExecutingContext, ProcessModel -->

> ScriptTask позволяет встроить C#-логику в процесс, но должен оставаться тонким orchestration-слоем.

## Runtime signature

ScriptTask-метод обычно имеет сигнатуру:

```csharp
private bool ScriptTask1Execute(ProcessExecutingContext context) {
    return true;
}
```

Метод возвращает `true`, если элемент успешно завершён и процесс может идти дальше.

## Регистрация метода

Generated wrapper регистрирует метод через `AddScriptTaskMethod`.

```csharp
public class BpmProcessCompletionMethodsWrapper : ProcessModel
{
    public BpmProcessCompletionMethodsWrapper(Process process)
        : base(process) {
        AddScriptTaskMethod("ScriptTask1Execute", ScriptTask1Execute);
    }
}
```

Имя должно совпадать с именем script method в metadata процесса.

## Доступ к параметрам

Параметры читаются и записываются через `Get<T>()` и `Set<T>()`.

```csharp
var userConnection = Get<UserConnection>("UserConnection");
var chatName = Get<string>("ChatName");
Set<Guid>("ResultId", resultId);
```

`UserConnection` часто доступен как process parameter и нужен для ESQ, сервисов, логирования и ProcessEngine.

## Пример: остановка связанных процессов

В `BpmProcessCompletion.BPMSoftOCC.cs` ScriptTask ищет running-процессы по entity binding и вызывает отмену.

```csharp
var processEngine = uc.ProcessEngine;
var processExecutor = processEngine.ProcessExecutor;
processExecutor.CancelExecutionAsync(processId);
```

Этот пример показывает типичный orchestration-сценарий: ScriptTask не реализует весь движок, а связывает ESQ, условия и ProcessEngine.

## Что держать внутри ScriptTask

Допустимо:

- получить параметры процесса;
- вызвать helper/service;
- выполнить короткую проверку;
- поставить результат в process parameter;
- залогировать диагностическую информацию.

Лучше вынести:

- длинные алгоритмы;
- интеграции с внешними API;
- сложную работу с транзакциями;
- повторно используемую domain-логику;
- batch-обработку больших объёмов данных.

## Ошибки и логирование

Не скрывайте ошибки без контекста. Если catch нужен, логируйте:

- имя процесса или task;
- ключевые параметры;
- идентификаторы записей;
- exception целиком.

Для пользовательской ошибки лучше возвращать управляемый сигнал, чем silently завершать task.

## Связанные документы

- [Process runtime and schema](process-runtime-schema.md)
- [Process starting](process-starting.md)
- [Process troubleshooting](process-troubleshooting.md)
- [EventListener validation and safety](event-listeners-validation-and-safety.md)
