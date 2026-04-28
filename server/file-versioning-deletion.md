# File Versioning Deletion

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: File version, File_BaseEventsProcess, BaseEntityFileDeleteListener, cascade delete -->

> Версионирование, санитизация и удаление файлов через lifecycle.

## Version

`File_BaseEventsProcess.OnFileSaving` управляет колонкой `Version`.

Правила:

- для file type версия увеличивается при изменении `Data`;
- для link/entity link версия увеличивается при изменении `Name`;
- при отсутствии старого значения стартовая версия считается `1`;
- при изменении `Data` пересчитывается `Size`.

```csharp
if (fileType == BPMSoft.WebApp.FileConsts.FileTypeUId) {
    if (dataColumnValue != null) {
        increaseVersion = true;
    }
} else {
    var nameOldValue = Entity.GetTypedOldColumnValue<string>("Name");
    var nameNewValue = Entity.GetTypedColumnValue<string>("Name");
    if (nameNewValue != nameOldValue) {
        increaseVersion = true;
    }
}
```

Базовая модель хранит текущую версию в той же записи. История binary versions не создаётся автоматически.

## Sanitization

При сохранении `Name` и `Notes` проходят обработку:

- удаляются двойные кавычки;
- применяется `HtmlSanitizerHelper.Sanitize`;
- пустое значение после sanitize заменяется на `default`.

Это защищает UI от unsafe HTML в имени или описании файла.

## Delete through File API

При включённом `FeatureUseFileApi` удаление metadata может уведомлять file API.

```csharp
var fileLocator = new EntityFileLocator(Entity.Schema.Name, Entity.PrimaryColumnValue);
IFileFactory fileFactory = UserConnection.GetFileFactory();
var options = new FileOptions {
    UseRights = false,
    RemoveMetadataOnDelete = false
};
IFile file = fileFactory.Get(fileLocator, options);
file.Delete();
```

`RemoveMetadataOnDelete = false` важен, когда metadata уже удаляется entity lifecycle.

## Cascade delete listener

`BaseEntityFileDeleteListener` подписан на `BaseEntity` и удаляет связанные файлы при удалении master record.

Порядок:

1. `OnDeleting`: находит `{Entity}File`, сохраняет file ids в `ApplicationData`, обнуляет reference на master.
2. `OnDeleted`: удаляет контент через `IFile.Delete()`.
3. `OnDeleteFailed`: восстанавливает reference на master.

Listener работает только при включённой feature `UseBaseEntityFileDeleteListener`.

## Как listener находит файловую схему

Listener ищет наследников `File`, у которых есть lookup на удаляемую master schema. Если таких схем несколько, применяется конвенция `{EntityName}File`.

## Практические правила

- Не удаляйте только metadata, если content хранится вне DB.
- При custom delete logic учитывайте `OnDeleteFailed`.
- Для нескольких файловых схем на одну master schema проверьте naming convention.
- Не отключайте rights в `FileOptions` без внутреннего lifecycle-сценария.
- Версия файла не является полноценной историей версий.

## Связанные документы

- [File Storage Overview](file-overview.md)
- [File Repository API](file-repository-api.md)
- [EventListener entity hooks](event-listeners-entity-hooks.md)
- [File troubleshooting](file-troubleshooting.md)
