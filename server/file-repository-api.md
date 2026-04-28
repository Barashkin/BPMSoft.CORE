# File Repository API

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: FileRepository, IFile, EntityFileLocator, FileUploadInfo -->

> Серверные API для работы с контентом файлов: `FileRepository`, `IFile`, `EntityFileLocator`.

## FileRepository

`FileRepository` — фасад для загрузки, чтения и удаления файлов.

```csharp
var fileRepository = ClassFactory.Get<FileRepository>(
    new ConstructorArgument("userConnection", userConnection));
```

Типовые операции:

| Операция | API |
| -------- | --- |
| upload | `UploadFile(IFileUploadInfo)` |
| download | `LoadFile(entitySchemaUId, fileId, writer)` |
| delete | `DeleteFile`, `DeleteFiles` |

## FileEntityUploadInfo

Для программной загрузки используется `FileEntityUploadInfo`.

```csharp
var fileEntityInfo = new FileEntityUploadInfo("ActivityFile", fileId, name) {
    Content = new MemoryStream(data),
    TotalFileLength = data.Length
};
fileRepository.UploadFile(fileEntityInfo, false);
```

Так загружаются email attachments в `ActivityFile`.

## IFile и EntityFileLocator

Новый API работает через locator и абстракцию файла.

```csharp
var fileLocator = new EntityFileLocator("ContactFile", fileId);
IFile file = userConnection.GetFile(fileLocator);
using (Stream stream = file.Read()) {
    // read content
}
```

`EntityFileLocator` связывает content object с entity schema name и record id.

## IFileFactory

Через factory можно получить или создать файл.

```csharp
IFileFactory fileFactory = userConnection.GetFileFactory();
IFile file = fileFactory.Get(fileLocator);
IFile newFile = fileFactory.Create(fileLocator);
```

Используйте factory, если нужен storage-agnostic код.

## FileOptions

При внутренних операциях можно передавать `FileOptions`.

```csharp
var options = new FileOptions {
    UseRights = false,
    RemoveMetadataOnDelete = false
};
options.Context.Add($"Entity_{fileLocator.EntitySchemaName}_{fileLocator.RecordId}", entity);
IFile file = fileFactory.Get(fileLocator, options);
```

Такой подход нужен для внутреннего удаления, когда metadata уже обрабатывается entity lifecycle.

## Когда что использовать

| Сценарий | API |
| -------- | --- |
| WCF upload endpoint | `FileRepository.UploadFile` |
| Programmatic email attachment upload | `FileEntityUploadInfo` + `FileRepository` |
| Storage-agnostic read/copy/delete | `IFile` + `EntityFileLocator` |
| Legacy download to stream | `FileRepository.LoadFile` |
| Entity lifecycle delete | `IFile.Delete()` with context/options |

## Практические правила

- Для нового storage-agnostic кода предпочитайте `IFile`.
- Для существующих upload endpoints сохраняйте `FileRepository`, если он уже формирует metadata.
- Не смешивайте запись metadata через `Entity` и content через `IFile` без понимания lifecycle.
- Всегда закрывайте streams через `using`.
- Для внутренних операций явно документируйте, почему отключены rights или metadata deletion.

## Связанные документы

- [File Storage Overview](file-overview.md)
- [File upload download](file-upload-download.md)
- [File versioning deletion](file-versioning-deletion.md)
- [Security overview](security-overview.md)
