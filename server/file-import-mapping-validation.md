# File Import Mapping And Validation

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: FileImport, mapping, validation, lookups, tags -->

> Маппинг колонок, обработка lookup-значений, required fields, tags и ошибки преобразования.

## Column mapping

Колонка файла представлена как `ImportColumn`. Она содержит source и набор destinations. Destination описывает, куда сохранить значение:

- schema/column;
- `ColumnName`;
- `ColumnValueName`;
- признак key column;
- typed/lookup destination.

На клиенте это поддерживают:

- `ColumnMappingViewModel.FileImport.js`;
- `ColumnDestinationViewModel.FileImport.js`;
- `LookupColumnDestinationViewModel.FileImport.js`;
- `ColumnTypedDestinationViewModel.FileImport.js`.

## Column processors

Серверный контур использует иерархию processors:

| Компонент | Назначение |
| --------- | ---------- |
| `BaseColumnProcessor` | базовая обработка значения |
| `ColumnsProcessor` | orchestration обработки колонок |
| `BaseColumnsAggregator` | агрегация destinations |
| `ColumnsAggregatorFactory` | выбор aggregator |
| `ColumnProcessErrorEventArgs` | событие ошибки колонки |

## Lookup values

`ChunkLookupValuesHandler` обрабатывает lookup-значения пачками. Он восстанавливает `LookupValuesToProcess` из memento и вызывает `LookupValuesProcessor` с `validateRequiredColumns: true`.

При ошибке processor возвращает cell index и сообщение по missing value. Это позволяет показать проблему на уровне строки/ячейки Excel.

## Save-time validation

`FileImportEntitiesChunkProcessor` перед сохранением:

- инициализирует primary entity;
- ищет существующую запись по key columns;
- заполняет child entities;
- проверяет lookup append rights и license rights;
- trim-ит text values;
- пропускает unchanged values;
- вызывает события success/error.

Пример проверки lookup append:

```csharp
if (!UserConnection.DBSecurityEngine.GetIsEntitySchemaAppendingAllowed(
    columnEntitySchema.ReferenceSchema.Name)) {
    throw new LicException(...);
}
```

## Tags validation

Tags mapping проходит через:

- `GetTagsMappingParameters`;
- `SetTagsMappingParameters`;
- `ValidateTagsMappingParameters`.

Если превышен лимит tags, service возвращает `ErrorCode = "new_tags_limit_exceed"`.

## Events extension points

Для расширений предусмотрены args:

- `BeforeImportEntitiesSaveEventArgs`;
- `AfterImportEntitiesSaveEventArgs`;
- `ImportEntitySavedEventArgs`;
- `ImportEntitySaveErrorEventArgs`;
- `TagsImportedEventArgs`.

## Практические правила

- Required lookup values проверяйте до сохранения сущностей.
- Key columns должны быть стабильными: по ним ищется primary entity.
- Для lookup append учитывайте одновременно права и лицензии.
- Ошибки конвертации сохраняйте с привязкой к строке/ячейке.
- Tags валидируйте до запуска heavy processing.

## Связанные документы

- [File Import overview](file-import-overview.md)
- [File import processing chunks](file-import-processing-chunks.md)
- [Security schema and record rights](security-schema-record-rights.md)
- [ESQ filters](esq-filters.md)
