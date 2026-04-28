# Deduplication Services And Search

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: DeduplicationService, search duplicates, WCF, results -->

> WCF/API-контур дедупликации: поиск дублей, ignore list, результаты и merge endpoint.

## DeduplicationService

`DeduplicationService` — основной WCF service для классической дедупликации.

| Метод | Назначение |
| ----- | ---------- |
| `FindDuplicatesOnSave` | найти похожие записи при сохранении |
| `SetDuplicatesOnSave` | добавить записи в ignore list |
| `GetDeduplicationResults` | получить группы дублей с пагинацией |
| `FindEntityDuplicatesAsync` | запустить поиск дублей по схеме |
| `MergeEntityDuplicatesAsync` | запустить merge группы |
| `AddToIgnoreList` | исключить записи из дублей |
| `GetSearchInfo` | получить информацию о последнем поиске |
| `ScheduleSearch` | настроить расписание поиска |
| `RemoveScheduledSearch` | удалить расписание |

## Processing result

`DeduplicationProcessing.GetDeduplicationResults` возвращает `DuplicatesGroupResponse`.

Структура ответа:

| Поле | Назначение |
| ---- | ---------- |
| `groups` | коллекция групп дублей |
| `rowConfig` | конфигурация колонок для клиента |
| `nextOffset` | следующая позиция для lazy loading |
| `totalCountRecords` | общее количество записей |

## Initial result tables

Классический контур работает с таблицами вида `{SchemaName}DuplicateSearchResult`. В них хранится `GroupId` и id записи (`{SchemaName}Id`).

`DeduplicationProcessing` читает группы пачками:

- `GroupsPerRequest = 7`;
- `RowsPerRequest = 1000`;
- фильтр по текущему `SysAdminUnitId`.

## Request builder

`FindSimilarRecordsRequestBuilder` строит request по правилам:

- загружает active matching filters;
- читает source entity по `SourceColumnUId`;
- формирует `DuplicatesColumnData`;
- передаёт `SchemaName`, `Columns`, `Model`.

## SearchDuplicatesService

`SearchDuplicatesService.NUI.cs` — смежный крупный сервис поиска дублей. Он содержит `SearchStatus` с кодом, процентом и временем, поэтому полезен при диагностике прогресса глобального поиска.

## Практические правила

- Для on-save сценариев используйте `FindDuplicatesOnSave`.
- Для lazy UI результатов используйте `GetDeduplicationResults` и `nextOffset`.
- Ignore list должен включать текущую запись и выбранные не-дубли.
- Не обходите `DeduplicationProcessing`: там собираются rowConfig, права и response shape.
- Для поиска по правилам проверяйте, что `SourceColumnUId` действительно существует в schema.

## Связанные документы

- [Deduplication overview](deduplication-overview.md)
- [Deduplication rules](deduplication-rules.md)
- [Deduplication merge](deduplication-merge.md)
- [Services Overview](services-overview.md)
