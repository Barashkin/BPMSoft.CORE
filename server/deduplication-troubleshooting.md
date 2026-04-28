# Deduplication Troubleshooting

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: deduplication troubleshooting, duplicates, merge, bulk -->

> Диагностика дедупликации: поиск дублей, правила, bulk-задачи, merge и UI.

## Дубли не находятся при сохранении

Проверьте:

- активное правило `DuplicatesRule`;
- `UseAtSave`;
- `RuleBody` и `SourceColumnUId`;
- доступность source columns;
- `FindDuplicatesOnSave`;
- ignore list для текущей записи.

## Страница результатов пустая

Проверьте:

- таблицу `{SchemaName}DuplicateSearchResult`;
- `GroupId`;
- фильтр по текущему `SysAdminUnitId`;
- `offset` в `GetDeduplicationResults`;
- права на чтение записей;
- `rowConfig` и requested columns.

## Виджет дублей не открывает страницу

Проверьте:

- `data.duplicates`;
- read access хотя бы к одной записи;
- ESQ в `DuplicatesWidgetViewModel`;
- router hash `CardModuleV2/WidgetDuplicatesPage/{schemaName}`;
- состояние `isOpeningPage`.

## Merge возвращает конфликты

Проверьте:

- `mergeConfig`;
- выбранные значения конфликтных колонок;
- список ignored/system columns;
- `ValidateDuplicates`;
- права на изменение и удаление записей;
- количество записей в группе.

## После merge остались ссылки на дубли

Проверьте:

- `DeduplicateMergeRules`;
- custom `IMergeReferencesFactory`;
- stored procedures с префиксом `tsp_`;
- `AdditionalMergeConfig.EligibleForSchema`;
- ошибки logger `Deduplication`.

## Bulk-поиск не стартует

Проверьте:

- `DeduplicationWebApiUrl`;
- доступность external WebApi;
- `IndexName`;
- feature `BulkESDeduplication`;
- `BulkDeduplicationService.FindDuplicateEntities`;
- logs manager.

## Bulk status не обновляется

Проверьте:

- job `CheckDeduplicationTaskStatusJobExecutor`;
- параметры `entityName` и `indexName`;
- group jobs в scheduler;
- ответы external task API;
- logger `Deduplication`.

## Правило не даёт выбрать объект

Проверьте:

- `SysModule.GlobalSearchAvailable`;
- фильтр `Contact`/`Account` в `DuplicatesRulePageV2`;
- feature flags `ESDeduplication`, `BulkESDeduplication`;
- режим add/edit: в edit object disabled.

## Ignore/unique list не работает

Проверьте:

- `AddToIgnoreList`;
- `AddToUniqueList`;
- что текущая запись добавлена в список исключений;
- обновление search result group;
- повторный запуск поиска после изменения списка.

## Связанные документы

- [Deduplication overview](deduplication-overview.md)
- [Deduplication services search](deduplication-services-search.md)
- [Deduplication merge](deduplication-merge.md)
- [Deduplication bulk background](deduplication-bulk-background.md)
