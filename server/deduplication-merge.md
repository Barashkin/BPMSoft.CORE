# Deduplication Merge

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: deduplication merge, golden record, DeduplicationMergeHandler -->

> Слияние дублей: золотая запись, разрешение конфликтов, перенос ссылок, история и post-actions.

## Merge endpoint

`DeduplicationService.MergeEntityDuplicatesAsync` принимает:

- `schemaName`;
- `groupId`;
- `deduplicateRecordIds`;
- JSON `mergeConfig`.

`mergeConfig` десериализуется в `Dictionary<string, string>` и передаётся в `DeduplicationProcessing`.

## Golden record

`DeduplicationMergeHandler` сливает набор сущностей в golden entity. Выбранные пользователем значения колонок приходят из merge UI.

UI собирает конфигурацию так:

```javascript
var mergeConfig = {};
BPMSoft.each(mergeColumns, function(columnName) {
    mergeConfig[columnName] = this.get(columnName);
}, this);
```

## Conflict resolution

Handler пропускает:

- system columns;
- пустые/default значения;
- колонки из explicit ignored list;
- `ProcessListeners`.

Если есть конфликт по колонке, значение берётся из записи, указанной в `resolvedConflicts`.

## References merge

Handler переносит ссылки с duplicate records на golden record:

- строит references по foreign keys;
- применяет `DeduplicateMergeRules`;
- поддерживает custom `IMergeReferencesFactory`;
- обновляет `ModifiedOn`, если колонка есть;
- удаляет записи дублей после переноса.

## DeduplicateMergeRules

`DeduplicateMergeRules` задаёт правила обработки details. Если `SQLText` начинается с `tsp_`, правило считается stored procedure. `AdditionalMergeConfig` может ограничивать `EligibleForSchema`.

## History and notifications

После merge:

- пишется `DuplicatesHistory`;
- удаляются/обновляются search results;
- отправляется `DuplicatesOperationExecuted` через `MsgChannelUtilities`;
- выполняются `IAfterDeduplicationAction`;
- может создаваться reminder по merge.

## Validation

`ValidateDuplicates` проверяет возможность merge и возвращает конфликты. В процессах смежная проверка представлена user task `IsMergePossible`, где есть признаки `InvalidRights` и `InvalidEntitiesCount`.

## Практические правила

- Всегда валидируйте merge до изменения данных.
- Не переносите system columns и process listener fields.
- Для details используйте merge rules, а не ручные update/delete в обход handler.
- После merge очищайте search result group или помечайте её excluded.
- Для отраслевых действий после merge добавляйте `IAfterDeduplicationAction`.

## Связанные документы

- [Deduplication overview](deduplication-overview.md)
- [Deduplication client UI](deduplication-client-ui.md)
- [Deduplication security rights](deduplication-security-rights.md)
- [EventListeners Overview](event-listeners-overview.md)
