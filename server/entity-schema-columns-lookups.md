# Entity Schema Columns And Lookups

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: EntitySchema, columns, lookup, ColumnValueName, DefValue, RequirementType -->

> Как в schema metadata описываются колонки, lookup-связи, default values и generated properties.

## InitializeColumns

Колонки добавляются в `InitializeColumns`.

```csharp
protected override void InitializeColumns() {
    base.InitializeColumns();
    if (Columns.FindByUId(new Guid("...")) == null) {
        Columns.Add(CreateTypeColumn());
    }
}
```

Важно: это не `ESQ.AddColumn`. Здесь создаётся metadata колонки схемы.

## Create column method

Типовой метод создания колонки:

```csharp
protected virtual EntitySchemaColumn CreatePriorityColumn() {
    return new EntitySchemaColumn(this, DataValueTypeManager.GetInstanceByName("Integer")) {
        UId = new Guid("..."),
        Name = @"Priority",
        RequirementType = EntitySchemaColumnRequirementType.ApplicationLevel,
        CreatedInSchemaUId = new Guid("..."),
        ModifiedInSchemaUId = new Guid("..."),
        CreatedInPackageId = new Guid("...")
    };
}
```

## Частые свойства колонки

| Свойство | Назначение |
| --- | --- |
| `Name` | техническое имя колонки |
| `DataValueType` | тип данных |
| `ReferenceSchemaUId` | целевая схема lookup |
| `RequirementType` | обязательность на уровне приложения |
| `IsIndexed` | индексировать колонку |
| `IsCascade` | каскадное поведение для связи |
| `IsWeakReference` | слабая ссылка |
| `IsValueCloneable` | копировать значение при clone |
| `UsageType` | видимость и назначение колонки |
| `IsLocalizable` | локализуемое текстовое поле |

## Lookup columns

Lookup задаётся через `DataValueTypeManager.GetInstanceByName("Lookup")` и `ReferenceSchemaUId`.

```csharp
protected virtual EntitySchemaColumn CreateTypeColumn() {
    return new EntitySchemaColumn(this, DataValueTypeManager.GetInstanceByName("Lookup")) {
        Name = @"Type",
        ReferenceSchemaUId = new Guid("..."),
        RequirementType = EntitySchemaColumnRequirementType.ApplicationLevel,
        IsIndexed = true
    };
}
```

В generated entity class lookup обычно представлен парой свойств:

- `{ColumnName}Id`;
- `{ColumnName}Name`;
- navigation property через `LookupColumnEntities.GetEntity(...)`.

## ColumnValueName и DisplayColumnValueName

Для переопределённых lookup-колонок часто задаются имена value/display.

```csharp
protected override EntitySchemaColumn CreateParentColumn() {
    EntitySchemaColumn column = base.CreateParentColumn();
    column.ReferenceSchemaUId = new Guid("...");
    column.ColumnValueName = @"ParentId";
    column.DisplayColumnValueName = @"ParentName";
    return column;
}
```

Это важно для чтения значений из entity: lookup id обычно хранится в `ParentId`, display value — в `ParentName`.

## Default values

Системные колонки `BaseEntitySchema` используют `EntitySchemaColumnDef`.

```csharp
DefValue = new EntitySchemaColumnDef() {
    Source = EntitySchemaColumnDefSource.SystemValue,
    ValueSource = SystemValueManager.GetInstanceByName(@"AutoGuid")
}
```

Типовые системные defaults:

| Колонка | Default |
| --- | --- |
| `Id` | `AutoGuid` |
| `CreatedOn` | `CurrentDateTime` |
| `ModifiedOn` | `CurrentDateTime` |
| `CreatedBy` | `CurrentUserContact` |
| `ModifiedBy` | `CurrentUserContact` |

Поэтому при создании entity важно вызывать `SetDefColumnValues()`.

## Sensitive fields

Для секретов используется `SecureText`.

```csharp
new EntitySchemaColumn(this, DataValueTypeManager.GetInstanceByName("SecureText")) {
    Name = @"ApiKey"
}
```

Не документируйте реальные значения секретов и не выводите их в клиентский код.

## Связанные документы

- [Entity Schema Overview](entity-schema-overview.md)
- [Entity Schema metadata](entity-schema-metadata.md)
- [ESQ columns and paths](esq-columns-and-paths.md)
- [Entity Schema troubleshooting](entity-schema-troubleshooting.md)
