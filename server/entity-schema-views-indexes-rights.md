# Entity Schema Views Indexes Rights

<!-- Версия: 1.1 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: EntitySchema, IsDBView, indexes, IsCascade, UseDenyRecordRights, rights -->

> DB views, индексы, cascade-связи и flags прав на уровне schema metadata.

## DB views

View-схемы помечаются `IsDBView = true`.

```csharp
protected override void InitializeProperties() {
    base.InitializeProperties();
    Name = "VwWebhookV2";
    IsDBView = true;
}
```

View обычно используют для read-models, списков доступа, объединённых представлений и системных витрин. Не ожидайте от view той же write-семантики, что от таблицы.

## Переопределение колонок view

View может ослаблять обязательность унаследованной колонки.

```csharp
protected override EntitySchemaColumn CreateUIdColumn() {
    EntitySchemaColumn column = base.CreateUIdColumn();
    column.RequirementType = EntitySchemaColumnRequirementType.None;
    return column;
}
```

Это типично для представлений, где данные приходят из SQL view, а не создаются через обычный entity insert.

## Индексы

Индексы создаются через `EntitySchemaIndex`.

```csharp
private EntitySchemaIndex CreateIndex_Uniq_SlugIndex() {
    EntitySchemaIndex index = new EntitySchemaIndex() {
        IsAutoName = false,
        IsClustered = false,
        IsUnique = true
    };
    index.Name = "Index_Uniq_Slug";
    index.Columns.Add(new EntitySchemaIndexColumn() {
        ColumnUId = new Guid("..."),
        OrderDirection = OrderDirectionStrict.Ascending
    });
    return index;
}
```

И подключаются в `InitializeIndexes`.

```csharp
protected override void InitializeIndexes() {
    base.InitializeIndexes();
    Indexes.Add(CreateIndex_Uniq_SlugIndex());
}
```

## Unique index vs listener validation

Уникальный индекс защищает БД. Listener validation даёт понятное сообщение пользователю. Часто нужны оба слоя:

- index гарантирует invariant;
- listener возвращает локализованную ошибку до ошибки БД.

Пример пары: `InsightSlugSchema.InsightReport.cs` и `InsightSlugEventListener.InsightReport.cs`.

## Cascade и weak references

Lookup-связи могут иметь flags:

| Flag | Смысл |
| --- | --- |
| `IsCascade` | связь зависит от master record |
| `IsWeakReference` | слабая ссылка, не должна вести себя как строгий FK |
| `IsValueCloneable` | значение копируется или не копируется при clone |

Для файлов, тегов и связей «элемент в папке» часто встречается `IsCascade = true`.

## Rights metadata

На уровне schema metadata встречаются:

```csharp
UseDenyRecordRights = false;
UseRecordDeactivation = false;
```

Эти flags не заменяют проверку прав в сервисах, listener'ах и бизнес-логике. Они только описывают участие схемы в платформенных механизмах прав и деактивации.

Подробный разбор runtime-проверок см. в [Security schema and record rights](security-schema-record-rights.md).

## Практические правила

- Для frequently filtered lookup-колонок проверяйте `IsIndexed`.
- Для уникальности используйте index, а не только listener.
- Для view-схем не проектируйте сценарии записи без проверки платформенной поддержки.
- Для cascade-связей учитывайте side effects удаления master record.
- Для прав на запись смотрите и schema flags, и реальные checks в сервисах/listener'ах.

## Связанные документы

- [Entity Schema Overview](entity-schema-overview.md)
- [Entity Schema metadata](entity-schema-metadata.md)
- [Entity Schema columns and lookups](entity-schema-columns-lookups.md)
- [EventListener validation and safety](event-listeners-validation-and-safety.md)
- [Services UserConnection And Security](services-userconnection-security.md)
- [Security overview](security-overview.md)
