# EventListener Entity Hooks

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: EventListener, BaseEntityEventListener, OnSaving, OnSaved, EntityBeforeEventArgs, EntityAfterEventArgs -->

> Entity EventListener'ы реагируют на события конкретной схемы и позволяют выполнять логику до или после изменения записи.

## Регистрация

```csharp
[EntityEventListener(SchemaName = "Contact")]
public class ContactEventListener : BaseEntityEventListener
{
}
```

Один класс может слушать несколько схем:

```csharp
[EntityEventListener(SchemaName = "ChatQueueOperator")]
[EntityEventListener(SchemaName = "Channel")]
public class ChangeChatSettingsEventListener : BaseEntityEventListener
{
}
```

## Before и after события

| Событие | Args | Когда применять |
| --- | --- | --- |
| `OnSaving` | `EntityBeforeEventArgs` | общая before-валидация перед insert/update |
| `OnInserting` | `EntityBeforeEventArgs` | заполнить значения и проверить insert |
| `OnUpdating` | `EntityBeforeEventArgs` | проверить изменение существующей записи |
| `OnDeleting` | `EntityBeforeEventArgs` | запретить или подготовить удаление |
| `OnSaved` | `EntityAfterEventArgs` | общая after-логика после insert/update |
| `OnInserted` | `EntityAfterEventArgs` | создать связанные записи после insert |
| `OnUpdated` | `EntityAfterEventArgs` | синхронизировать after-update |
| `OnDeleted` | `EntityAfterEventArgs` | очистить cache или внешние индексы |

## Получение Entity и UserConnection

```csharp
public override void OnSaving(object sender, EntityBeforeEventArgs e) {
    var entity = (Entity)sender;
    var userConnection = entity.UserConnection;
    var name = entity.GetTypedColumnValue<string>("Name");
    base.OnSaving(sender, e);
}
```

В новых listener'ах лучше явно приводить `sender` к `Entity` и быстро выходить, если событие не требует обработки.

## Проверка изменённых колонок

До и после события можно анализировать изменённые значения.

```csharp
var changedColumn = entity.GetChangedColumnValues()
    .FirstOrDefault(column => column.Name == "ObservedSchemaId");

if (changedColumn == null) {
    return;
}

var oldValue = (Guid)changedColumn.OldValue;
var newValue = (Guid)changedColumn.Value;
```

В `EntityAfterEventArgs` также доступен `ModifiedColumnValues`.

```csharp
var hasIndexedChanges = e.ModifiedColumnValues
    .Where(arg => arg.Column.Name != "Id")
    .Any(columnValue => IsChangedIndexedColumn(entity, columnValue));
```

## Before hook: валидация и заполнение

Пример из `MetricEventListener.Apdex.cs`: в `OnInserting` проверяются обязательные значения, уникальность и при необходимости заполняется имя.

```csharp
public override void OnInserting(object sender, EntityBeforeEventArgs e) {
    base.OnInserting(sender, e);
    var entity = (Entity)sender;

    Guid typeId = entity.GetTypedColumnValue<Guid>("TypeId");
    if (typeId == Guid.Empty) {
        throw new Exception("Type is empty");
    }

    entity.SetColumnValue("Name", "Generated name");
}
```

## After hook: синхронизация и cache

After-события подходят для действий, которые должны выполняться только после успешного изменения записи:

- очистить cache;
- создать связанную запись;
- обновить поисковый индекс;
- поставить async operation;
- синхронизировать агрегированное состояние.

Пример cache invalidation:

```csharp
public override void OnUpdated(object sender, EntityAfterEventArgs e) {
    base.OnUpdated(sender, e);
    var entity = (Entity)sender;
    if (entity.GetChangedColumnValues().Any(value => value.Name == "IsActive")) {
        ClearOperatorsCache(entity.UserConnection);
    }
}
```

## Порядок вызова base

В кодовой базе встречаются оба варианта: `base` в начале и в конце метода. Выбирайте осознанно:

- `base` в начале, если логика расширяет стандартное поведение;
- `base` в конце, если перед стандартным поведением нужно заполнить или проверить данные;
- не пропускайте `base`, если не понимаете последствия для платформенного pipeline.

## Связанные документы

- [EventListeners Overview](event-listeners-overview.md)
- [EventListener validation and safety](event-listeners-validation-and-safety.md)
- [EventListener pattern catalog](event-listeners-pattern-catalog.md)
- [ESQ filters](esq-filters.md)
