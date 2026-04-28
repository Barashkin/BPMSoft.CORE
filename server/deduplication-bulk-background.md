# Deduplication Bulk And Background

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: bulk deduplication, scheduler, external WebApi, Elastic -->

> Массовая дедупликация: внешний WebApi/Elastic контур, manager, scheduler и проверка статуса.

## BulkDeduplicationService

`BulkDeduplicationService` — WCF фасад для массовой дедупликации.

| Метод | Назначение |
| ----- | ---------- |
| `GetDeduplicationInfo` | текущее состояние bulk-поиска |
| `FindDuplicateEntities` | старт task |
| `GetDuplicateEntities` | получить duplicate rows |
| `GetGroupsOfDuplicates` | получить группы дублей |
| `GetDuplicateEntitiesByGroup` | получить записи конкретной группы |
| `AddToUniqueList` | пометить записи уникальными |
| `GetDuplicatesCountData` | получить счётчики |

## BulkDeduplicationManager

`BulkDeduplicationManager` наследуется от `BaseDeduplicationManager` и использует:

- `IStartDeduplicationRequestFactory`;
- `IBulkDeduplicationTaskClient`;
- `IAppSchedulerWraper`;
- external REST endpoints;
- `DeduplicationWebApiUrl`;
- `IndexName`.

Если `DeduplicationWebApiUrl` пустой, manager пишет ошибку в logger.

## External fetch flow

Manager получает результаты из внешнего сервиса:

- duplicates;
- groups;
- count data;
- duplicates by group.

Если HTTP status не `OK` или body невалидный, возвращается пустой объект и пишется log entry.

## ESQ for UI rows

Bulk manager получает ids из external service, затем дочитывает реальные записи через ESQ. В этом контуре `UseAdminRights = true`, поэтому UI и caller должны отдельно учитывать доступность данных пользователю.

## Status polling job

После запуска task manager планирует minutely job `CheckDeduplicationTaskStatusJobExecutor` с параметрами:

- `entityName`;
- `indexName`.

Перед планированием удаляются старые jobs группы статуса.

## Bulk process integration

`BulkDuplicatesSearchProcess` запускает `IBulkDeduplicationTaskStarter.StartDeduplicationTask(SchemaName)`. Это процессная оболочка для bulk-сценария.

## Практические правила

- Для массового поиска проверяйте `DeduplicationWebApiUrl` и index name.
- Не показывайте external results без дочитывания записей из текущей БД.
- Для UI поддерживайте пагинацию: offset/count/topDuplicatesPerGroup.
- Перед новым status polling удаляйте старую job group.
- Для прав пользователя учитывайте, что bulk ESQ использует admin rights.

## Связанные документы

- [Deduplication overview](deduplication-overview.md)
- [Deduplication security rights](deduplication-security-rights.md)
- [Quartz AppScheduler API](quartz-appscheduler-api.md)
- [Process Overview](process-overview.md)
