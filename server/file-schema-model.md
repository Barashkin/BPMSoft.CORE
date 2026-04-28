# File Schema Model

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: FileSchema, File, ContactFile, SysFileStorage, FileInFolder -->

> Модель файловых сущностей: базовая `File`, наследники `{Entity}File`, storage metadata и папки.

## Базовая схема File

`File` наследуется от `BaseEntity` и содержит общие metadata-колонки файла.

| Колонка | Тип | Назначение |
| ------- | --- | ---------- |
| `Name` | `MediumText` | имя файла или URL для link-типа |
| `Notes` | `MaxSizeText` | описание |
| `Data` | `Binary` | бинарный контент для DB storage |
| `Type` | lookup `FileType` | файл, ссылка, ссылка на сущность |
| `Version` | `Integer` | текущая версия metadata |
| `Size` | `Integer` | размер в байтах |
| `LockedBy` | lookup `Contact` | пользователь блокировки |
| `LockedOn` | `DateTime` | дата блокировки |
| `SysFileStorage` | lookup `SysFileContentStorage` | storage контента |

`SysFileStorage` является weak reference и скрыт от обычного usage (`UsageType = None`).

## Наследники `{Entity}File`

Для вложений к сущности создаётся отдельная схема-наследник `File`.

```csharp
public class ContactFileSchema : BPMSoft.Configuration.FileSchema
{
    protected override void InitializeColumns() {
        base.InitializeColumns();
        Columns.Add(CreateContactColumn());
    }
}
```

Lookup на master record обычно:

- называется как master entity (`Contact`, `Activity`, `Product`);
- индексируется (`IsIndexed = true`);
- имеет cascade-семантику (`IsCascade = true`), если файл должен жить вместе с master record.

## Track changes

В типичных `{Entity}File` схемах track changes включается для важных колонок:

- `Name`;
- `Data`;
- `Version`.

Это полезно для аудита изменения вложений.

## Process files

Для процессов используется отдельная файловая схема, например `SysProcessFile`. Она тоже наследует `FileSchema`, но связь с master может быть weak reference, так как процессная metadata живёт иначе, чем обычные business entities.

## File folders

Файлы могут группироваться через:

- `FileFolderSchema`;
- `FileInFolderSchema`, наследник `BaseItemInFolderSchema`.

Это отдельный механизм от обычной привязки `{Entity}File` к master record.

## Практические правила

- Для новой сущности создавайте `{EntityName}File`, если нужны вложения на карточке.
- Lookup на master должен быть индексирован.
- Не храните большие произвольные blob-данные в бизнес-сущности, если это пользовательский файл.
- Используйте `SysFileStorage` как metadata, а не как бизнес-флаг.
- Для UI file detail имя файловой схемы должно совпадать с `entitySchemaName` детали.

## Связанные документы

- [File Storage Overview](file-overview.md)
- [File Repository API](file-repository-api.md)
- [File client detail](file-client-detail.md)
- [Entity schema folders, tags and files](entity-schema-folders-tags-files.md)
