# File Client Detail

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: FileDetailV2, ConfigurationFileApi, FileDownloader, drag-and-drop -->

> Клиентская часть файлов: `FileDetailV2`, upload config, download links и права master record.

## FileDetailV2

`FileDetailV2` — основной detail module для файлов. Он подключает:

- `ConfigurationFileApi` для upload;
- `FileDownloader` для download link;
- `FileUploadErrorHandlers` для ошибок и лимитов;
- preview/viewer-модули для изображений и просмотра.

## Подключение к странице

Типовой detail config:

```javascript
details: {
    Files: {
        schemaName: "FileDetailV2",
        entitySchemaName: "ContactFile",
        filter: {
            masterColumn: "Id",
            detailColumn: "Contact"
        }
    }
}
```

`entitySchemaName` должен указывать на `{Entity}File`, а `detailColumn` — на lookup к master record.

## Upload config

`FileDetailV2` формирует config для `ConfigurationFileApi`.

```javascript
{
    entitySchemaName: this.entitySchema.name,
    columnName: "Data",
    parentColumnName: this.get("DetailColumnName"),
    parentColumnValue: this.get("MasterRecordId"),
    files: files,
    isChunkedUpload: true
}
```

Если `MasterRecordId` ещё не задан, detail сначала инициирует сохранение master card.

## Видимость действий

Добавление файла зависит от:

- доступности tools;
- `CanEditMasterRecord`;
- `IsEnabled`;
- режима отображения detail.

```javascript
getAddRecordButtonVisible: function() {
    return this.getToolsVisible() && this.get("CanEditMasterRecord") && this.get("IsEnabled");
}
```

## Links and entity links

`FileDetailV2` работает не только с бинарными файлами, но и с:

- link file type;
- entity link file type;
- preview/viewer state.

Для link-сценариев используется card module `LinkPageV2`.

## Download

Ссылка на скачивание строится через `FileDownloader`.

```javascript
BPMSoft.FileDownloader.getFileLink(this.entitySchema.uId, id);
```

## Custom details

Доменные детали могут наследовать или расширять `FileDetailV2`. Например, email использует `EmailFileDetailV2`, где часть generic menu items отключается.

## Практические правила

- Всегда задавайте корректные `entitySchemaName`, `masterColumn`, `detailColumn`.
- Для master-detail upload сначала сохраняйте master record.
- Не показывайте upload action без `CanEditMasterRecord`.
- Для ограничений размера используйте общий обработчик `FileUploadErrorHandlers`.
- Для кастомизации email/message attachments расширяйте `FileDetailV2`, а не копируйте его целиком.

## Связанные документы

- [File Storage Overview](file-overview.md)
- [File upload download](file-upload-download.md)
- [Client section/detail patterns](../client/client-section-detail-patterns.md)
- [Client troubleshooting](../client/client-troubleshooting.md)
