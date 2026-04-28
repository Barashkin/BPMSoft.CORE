# EventListener EventsProcess

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: EventListener, EventsProcess, EmbeddedProcess, ScriptTask, Entity events -->

> `EventsProcess` — generated embedded process, который платформа использует для обработки событий сущностей наряду с `BaseEntityEventListener`.

## Что такое EventsProcess

`EventsProcess` генерируется для схем и хранит цепочку process elements, связанных с событиями entity lifecycle.

Обычно код распределён по двум файлам:

| Файл | Что содержит |
| --- | --- |
| `{Entity}Schema.Base.cs` | declaration, flow elements, `ThrowEvent`, `OnExecuted` |
| `{Entity}.Base.cs` | partial methods с бизнес-логикой |

## Иерархия

```text
BPMSoft.Core.Process.EmbeddedProcess
  └── BaseEntity_BaseEventsProcess<TEntity>
        ├── Account_BaseEventsProcess<TEntity>
        ├── Contact_BaseEventsProcess<TEntity>
        └── Activity_BaseEventsProcess<TEntity>
```

Для некоторых сущностей есть non-generic wrapper и alias вида `ContactEventsProcess`.

## ThrowEvent

`ThrowEvent` сопоставляет сообщение entity lifecycle с process start message.

```csharp
public override void ThrowEvent(ProcessExecutingContext context, string message) {
    switch (message) {
        case "Contact_Base_BPMSoftSaved":
            if (ActivatedEventElements.Contains("ContactSaved")) {
                context.QueueTasks.Enqueue("ContactSaved");
            }
            break;
    }
    base.ThrowEvent(context, message);
}
```

## OnExecuted

`OnExecuted` определяет, какие script tasks запускаются после конкретного элемента.

```csharp
protected override void OnExecuted(object sender, ProcessActivityAfterEventArgs e) {
    switch (e.Context.SenderName) {
        case "ContactSaved":
            e.Context.QueueTasks.Enqueue("SynchronizeContactAddressScriptTask");
            e.Context.QueueTasks.Enqueue("UpdateCareerScriptTask");
            break;
    }
}
```

## ScriptTask

ScriptTask обычно вызывает virtual method из partial-класса.

```csharp
public virtual bool SynchronizeContactAddressScriptTaskExecute(ProcessExecutingContext context) {
    SynchronizeContactAddress();
    return true;
}
```

Это позволяет расширять или замещать поведение через partial/override-подход, но усложняет поиск полного execution flow.

## Чем отличается от BaseEntityEventListener

| Критерий | EventsProcess | BaseEntityEventListener |
| --- | --- | --- |
| Происхождение | generated process-код схемы | обычный C# listener |
| Видимость цепочки | через flow elements и script tasks | через override методов |
| Расширение | partial/virtual methods | наследование и отдельный class |
| Типичные задачи | базовые платформенные цепочки, DCM, процессы | точечная бизнес-логика |
| Диагностика | смотреть Schema + Base partial файлы | смотреть listener class |

## Когда читать EventsProcess

Смотрите `EventsProcess`, если:

- поведение возникает при сохранении сущности, но listener не найден;
- нужно понять DCM/process completion;
- сущность синхронизирует связанные данные из generated code;
- событие запускает `ScriptTask`;
- в stack trace есть `BaseEventsProcess`.

## Связанные документы

- [EventListeners Overview](event-listeners-overview.md)
- [EventListener entity hooks](event-listeners-entity-hooks.md)
- [Бизнес-процессы](processes.md)
- [Entity Schemas](entity-schemas.md)
