# Process Runtime And Schema

<!-- Версия: 1.1 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: Process, ProcessSchema, FlowElements, ProcessSchemaParameter, ProcessModel, ProcessDesigner -->

> Как читать generated process code: `ProcessSchema`, параметры, flow elements, runtime `Process` и wrapper методов.

## ProcessSchema

`ProcessSchema` описывает metadata процесса.

UI-редактирование этой metadata в Process Designer описано отдельно:
[process-designer-runtime-boundary.md](process-designer-runtime-boundary.md).

```csharp
public class SendDeliverySchema : ProcessSchema
{
    protected override void InitializeProperties() {
        base.InitializeProperties();
        Name = "SendDelivery";
        UId = new Guid("...");
        SerializeToDB = true;
        SerializeToMemory = true;
        Tag = @"Business Process";
    }
}
```

В schema-классе находятся:

- свойства процесса;
- параметры;
- описания user tasks;
- sequence flows;
- gateways;
- mapping параметров подпроцессов.

## Parameters

Параметры создаются через `ProcessSchemaParameter`.

```csharp
protected virtual ProcessSchemaParameter CreateDeliveryIdParameter() {
    return new ProcessSchemaParameter(this) {
        Name = @"DeliveryId",
        Direction = ProcessSchemaParameterDirection.Variable,
        DataValueType = DataValueTypeManager.GetInstanceByName("Guid"),
        IsValueSerializable = true
    };
}
```

И регистрируются в `InitializeParameters`.

```csharp
protected override void InitializeParameters() {
    base.InitializeParameters();
    Parameters.Add(CreateDeliveryIdParameter());
}
```

## Runtime Process

Runtime class наследуется от `Process` и хранит состояние выполнения. В script methods параметры читаются через `Get<T>()` и записываются через `Set<T>()`.

```csharp
Guid deliveryId = Get<Guid>("DeliveryId");
Set<Guid>("ResultId", resultId);
```

## Flow elements

Каждый элемент процесса имеет metadata и runtime-поведение. В generated code часто встречаются вложенные классы вида:

```csharp
public class ChangeDataUserTask1FlowElement : ChangeDataUserTask
{
    public ChangeDataUserTask1FlowElement(UserConnection userConnection, Process process)
        : base(userConnection) {
        Owner = process;
        Type = "ProcessSchemaUserTask";
        Name = "ChangeDataUserTask1";
        SchemaElementUId = new Guid("...");
    }
}
```

## ProcessModel wrapper

ScriptTask-методы подключаются через `ProcessModel`.

```csharp
public class BpmProcessCompletionMethodsWrapper : ProcessModel
{
    public BpmProcessCompletionMethodsWrapper(Process process)
        : base(process) {
        AddScriptTaskMethod("ScriptTask1Execute", ScriptTask1Execute);
    }
}
```

Wrapper связывает имя script method из metadata с C# делегатом.

## Business process vs EventsProcess

| Критерий | Business Process | EventsProcess |
| --- | --- | --- |
| Назначение | бизнес-сценарий | lifecycle entity-событий |
| Базовый класс | `Process` | `EmbeddedProcess` |
| Хранение | обычно `SerializeToDB = true` | часто `SerializeToDB = false` |
| Запуск | вручную, из C#, JS, Quartz | через entity events |
| Диагностика | `SysProcessLog`, `SysProcessElementLog` | stack trace/entity event flow |

См. [EventListener EventsProcess](event-listeners-eventsprocess.md).

## Связанные документы

- [Process Overview](process-overview.md)
- [Process user tasks](process-user-tasks.md)
- [Process script tasks](process-script-tasks.md)
- [Process listeners and logs](process-listeners-and-logs.md)
- [Process Designer runtime boundary](process-designer-runtime-boundary.md)
