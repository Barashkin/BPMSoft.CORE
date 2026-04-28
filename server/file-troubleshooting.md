# File Troubleshooting

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: file troubleshooting, upload, download, FileDetailV2, MaxFileSize -->

> Чеклист диагностики проблем загрузки, скачивания, отображения и удаления файлов.

## Файл не загружается

Проверки:

- master record сохранён и `MasterRecordId` не пустой;
- `entitySchemaName` указывает на `{Entity}File`;
- `parentColumnName` совпадает с lookup-колонкой на master;
- `parentColumnValue` содержит id master record;
- upload endpoint использует актуальный `UploadFile`;
- server response содержит `Success = true`.

## Превышен размер файла

Проверки:

- sys setting `MaxFileSize`;
- custom `maxFileSizeSysSettingsName`, если задан;
- для import/report сценариев отдельные настройки вроде `FileImportMaxFileSize`;
- клиентский `FileUploadErrorHandlers` показал grouped error;
- сервер тоже валидирует размер.

## Файл загрузился, но не виден в детали

Проверки:

- запись создана в правильной файловой схеме;
- lookup на master заполнен;
- `DetailColumnName` совпадает с колонкой lookup;
- detail reload выполнился после upload callback;
- пользователь имеет read rights на file record;
- фильтр detail не использует пустой `MasterRecordId`.

## Скачивание возвращает ошибку

Проверки:

- id файла существует;
- schema UId соответствует файловой схеме;
- content есть в storage;
- `SysFileStorage` не указывает на недоступное хранилище;
- у пользователя есть read rights;
- ссылка строится через `FileDownloader.getFileLink`.

## Удаление master record оставляет файлы

Проверки:

- включена feature `UseBaseEntityFileDeleteListener`;
- для master entity есть `{Entity}File` или однозначная файловая схема;
- lookup на master найден listener'ом;
- `OnDeleted` действительно вызвался;
- в логах нет ошибки restore/delete;
- external storage доступен для `IFile.Delete()`.

## Удаление файла удаляет metadata, но не content

Проверки:

- включён `FeatureUseFileApi`, если content во внешнем storage;
- используется `IFile.Delete()`;
- `RemoveMetadataOnDelete` настроен в соответствии с lifecycle;
- нет custom listener, который прерывает delete до удаления content.

## Версия не увеличивается

Проверки:

- изменялась именно `Data` для file type;
- для link type менялся `Name`;
- `OnFileSaving` выполняется;
- тип файла (`TypeId`) заполнен корректно;
- запись не сохраняется через обход entity events.

## Имя файла меняется на default

Причина: после удаления кавычек и HTML sanitize имя стало пустым.

Проверки:

- исходное имя не состоит только из unsafe HTML;
- frontend не передаёт пустой `fileName`;
- custom upload не очищает имя.

## Viewer не отображается

Проверки:

- `FileViewerService.CheckHasOperationLicenseFileViewer` возвращает `true`;
- файл имеет поддерживаемый тип preview;
- `ShowPreview` включён;
- detail получил результат service call.

## Практический минимум диагностики

1. Найдите file schema и file id.
2. Проверьте metadata record.
3. Проверьте master lookup.
4. Проверьте storage/content.
5. Проверьте права и размер.
6. Повторите upload/download через штатный endpoint.

## Связанные документы

- [File Storage Overview](file-overview.md)
- [File upload download](file-upload-download.md)
- [File client detail](file-client-detail.md)
- [File security limits](file-security-limits.md)
