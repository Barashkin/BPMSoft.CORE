# Entity Schema Folders Tags Files

<!-- Версия: 1.1 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: EntitySchema, BaseFolderSchema, BaseItemInFolderSchema, BaseEntityInTagSchema, FileSchema -->

> Специализированные схемы для папок, тегов, связей «элемент в папке» и файлов.

## Folder schema

Папки наследуются от `BaseFolderSchema`.

```csharp
public class MetricFolderSchema : BaseFolderSchema
{
    protected override EntitySchemaColumn CreateParentColumn() {
        EntitySchemaColumn column = base.CreateParentColumn();
        column.ReferenceSchemaUId = new Guid("...");
        column.ColumnValueName = @"ParentId";
        column.DisplayColumnValueName = @"ParentName";
        return column;
    }
}
```

`Parent` обычно указывает на ту же folder schema, что создаёт иерархию папок.

## Item in folder schema

Связь записи с папкой наследуется от `BaseItemInFolderSchema`.

```csharp
public class InsightApplicationInFolderSchema : BaseItemInFolderSchema
{
    protected override EntitySchemaColumn CreateFolderColumn() {
        EntitySchemaColumn column = base.CreateFolderColumn();
        column.ReferenceSchemaUId = new Guid("...");
        column.ColumnValueName = @"FolderId";
        column.DisplayColumnValueName = @"FolderName";
        return column;
    }
}
```

Дополнительная lookup-колонка указывает на master entity.

```csharp
protected virtual EntitySchemaColumn CreateInsightApplicationColumn() {
    return new EntitySchemaColumn(this, DataValueTypeManager.GetInstanceByName("Lookup")) {
        Name = @"InsightApplication",
        ReferenceSchemaUId = new Guid("..."),
        RequirementType = EntitySchemaColumnRequirementType.ApplicationLevel,
        IsValueCloneable = false,
        IsCascade = true
    };
}
```

## Tag link schema

Связь entity-tag наследуется от `BaseEntityInTagSchema`.

```csharp
protected override EntitySchemaColumn CreateTagColumn() {
    EntitySchemaColumn column = base.CreateTagColumn();
    column.ReferenceSchemaUId = new Guid("...");
    column.ColumnValueName = @"TagId";
    column.DisplayColumnValueName = @"TagName";
    return column;
}
```

Вторая колонка обычно называется `Entity` и указывает на основную схему.

## File schema

Файловая связь наследуется от `FileSchema`.

```csharp
public class MetricFileSchema : FileSchema
{
    protected virtual EntitySchemaColumn CreateMetricColumn() {
        return new EntitySchemaColumn(this, DataValueTypeManager.GetInstanceByName("Lookup")) {
            Name = @"Metric",
            ReferenceSchemaUId = new Guid("..."),
            RequirementType = EntitySchemaColumnRequirementType.ApplicationLevel,
            IsValueCloneable = false,
            IsCascade = true
        };
    }
}
```

`IsCascade = true` означает, что файловая связь зависит от master record.

Подробно модель файлов, upload API и client detail описаны в [File Storage Overview](file-overview.md).

## Generated entity navigation

Generated entity class создаёт navigation property.

```csharp
private Metric _metric;

public Metric Metric {
    get {
        return _metric ??
            (_metric = LookupColumnEntities.GetEntity("Metric") as Metric);
    }
}
```

Если вы читаете entity через ESQ, нужные lookup/display колонки должны быть добавлены в запрос.

## Связанные документы

- [Entity Schema Overview](entity-schema-overview.md)
- [Entity Schema columns and lookups](entity-schema-columns-lookups.md)
- [Файлы и хранилища](file-storage.md)
- [File Storage Overview](file-overview.md)
- [ESQ columns and paths](esq-columns-and-paths.md)
