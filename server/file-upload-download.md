# File Upload Download

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: FileApiService, UploadFile, ConfigurationFileApi, chunk upload, attachments -->

> Потоки загрузки и скачивания файлов на сервере и клиенте.

## FileApiService

`FileApiService` — основной REST/WCF endpoint для upload.

```csharp
[OperationContract]
[WebInvoke(Method = "POST", RequestFormat = WebMessageFormat.Json,
    BodyStyle = WebMessageBodyStyle.Bare, ResponseFormat = WebMessageFormat.Json)]
public ConfigurationServiceResponse UploadFile(Stream fileContent) {
    IFileUploadInfo fileUploadInfo = _fileUploadInfoFactory(fileContent);
    var response = new ConfigurationServiceResponse();
    try {
        response.Success = FileRepository.UploadFile(fileUploadInfo);
    } catch (Exception ex) {
        response.Exception = ex;
        response.Success = false;
    }
    return response;
}
```

Сервис наследует `BaseService` и `IReadOnlySessionState`, доступен по default route и SSP route.

## Request metadata

Клиент передаёт metadata вместе с файлом:

| Параметр | Назначение |
| -------- | ---------- |
| `entitySchemaName` | файловая схема, например `ContactFile` |
| `columnName` | binary column, обычно `Data` |
| `parentColumnName` | lookup на master record |
| `parentColumnValue` | id master record |
| `fileId` | id записи файла |
| `fileName` | имя файла |
| `mimeType` | MIME type |
| `totalFileLength` | полный размер |
| `additionalParams` | дополнительные параметры |

## Chunk upload

`ConfigurationFileApi` поддерживает загрузку частями.

```javascript
chunkSize: isChunkedUpload ? config.chunkSize || this.defaultChunkSize : 0,
chunkUploadRetry: isChunkedUpload ? config.chunkUploadRetry || this.defaultChunkUploadRetry : 0
```

По умолчанию chunk size равен `0.5 * FileAPI.MB`, retry count — `3`.

## Upload from code

Для программной загрузки, например email attachment, используется `FileEntityUploadInfo`.

```csharp
var fileEntityInfo = new FileEntityUploadInfo("ActivityFile", fileId, name) {
    Content = new MemoryStream(data),
    TotalFileLength = data.Length
};
fileRepository.UploadFile(fileEntityInfo, false);
```

## Download

Legacy download может читать файл через `FileRepository.LoadFile`.

```csharp
using (var memoryStream = new MemoryStream())
using (var writer = new BinaryWriter(memoryStream)) {
    var fileInfo = _fileRepository.LoadFile(entitySchemaUId, fileId, writer);
    attachment.Name = fileInfo.FileName;
    attachment.SetData(memoryStream.ToArray());
}
```

В клиентских модулях ссылка на файл строится через `FileDownloader`.

```javascript
BPMSoft.FileDownloader.getFileLink(this.entitySchema.uId, selectedFile.$Id);
```

## Практические правила

- Для UI upload используйте `ConfigurationFileApi`, а не ручной `AjaxProvider`.
- Для больших файлов включайте chunk upload.
- Перед upload убедитесь, что master record уже сохранён.
- Для email/report attachments используйте отдельную файловую схему домена.
- Response должен различать transport failure и business/file validation failure.

## Связанные документы

- [File Storage Overview](file-overview.md)
- [File client detail](file-client-detail.md)
- [File security limits](file-security-limits.md)
- [Services response errors](services-response-errors.md)
