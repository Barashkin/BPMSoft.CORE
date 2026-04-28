# Deduplication Rules

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: DuplicatesRule, duplicate rules, RuleBody, matching -->

> Правила поиска дублей: metadata, rule body, активность, поиск при сохранении и UI настройки.

## DuplicatesRule

`DuplicatesRule` — базовая сущность правила дедупликации.

Ключевые поля:

| Поле | Назначение |
| ---- | ---------- |
| `Name` | название правила |
| `IsActive` | правило включено |
| `Object` | объект, для которого ищутся дубли |
| `SearchObject` | объект поиска |
| `RuleBody` | JSON/тело правила с filters |
| `ProcedureName` | stored procedure для legacy/search сценариев |
| `UseAtSave` | использовать при сохранении записи |

`UseDenyRecordRights = false`, поэтому record deny rights на metadata правила не применяются.

## Rule body

`RuleBody` хранит filters. `FindSimilarRecordsRequestBuilder` читает filters через `IDuplicatesRuleManager`, собирает `SourceColumnUId` и формирует request model.

```csharp
var filters = GetDuplicatesRuleFilters(schemaName, sourceSchemaName);
var sourceColumnUids = GetColumnUIds(filters);
var sourceEntity = GetSourceEntity(sourceId, sourceSchemaName, sourceColumnUids);
```

## Object selection

`DuplicatesRulePageV2` ограничивает доступные объекты. В базовой странице явно используются `Contact` и `Account`, а список доступных секций строится через `SysModule.GlobalSearchAvailable`.

## Features

Клиентская страница правил учитывает feature flags:

- `ESDeduplication`;
- `BulkESDeduplication`.

Эти flags меняют доступность ES/bulk сценариев.

## Folders and tags

Правила поддерживают стандартную организацию:

- `DuplicatesRuleFolder`;
- `DuplicatesRuleInFolder`;
- `DuplicatesRuleTag`;
- `DuplicatesRuleInTag`.

## Практические правила

- Для поиска при сохранении включайте `UseAtSave` только у проверенных правил.
- Не редактируйте `RuleBody` вручную без понимания структуры filters.
- Для нового объекта проверьте доступность схемы в global search.
- Для bulk-поиска правило должно быть совместимо с external search/index контуром.
- После изменения `UseAtSave` UI может требовать logout/reload, чтобы состояние применилось корректно.

## Связанные документы

- [Deduplication overview](deduplication-overview.md)
- [Deduplication services search](deduplication-services-search.md)
- [Deduplication client UI](deduplication-client-ui.md)
- [ESQ filters](esq-filters.md)
