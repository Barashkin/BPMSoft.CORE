# Deduplication Security And Rights

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: deduplication security, rights, UseAdminRights, merge rights -->

> Права и границы безопасности в дедупликации: чтение результатов, поиск, merge и bulk.

## Rights-aware results

`DeduplicationProcessing` использует `RightsHelper` при формировании результатов. Это важно: UI не должен получать записи дублей, которые пользователь не может видеть.

## Client read check

`DuplicatesWidgetViewModel` перед открытием страницы дублей выполняет ESQ по ids дублей. Если пользователь не может прочитать ни одну запись, страница не открывается.

## UseAdminRights boundary

В разных контурах права применяются по-разному:

| Контур | Поведение |
| ------ | --------- |
| `FindSimilarRecordsRequestBuilder` | ESQ создаётся с `UseAdminRights = false`, но выполняется через system connection fallback |
| `DeduplicationProcessing` | учитывает current user и `SysAdminUnitId` в result tables |
| `BulkDeduplicationManager` | ESQ для дочитывания rows использует `UseAdminRights = true` |
| Widget UI | дополнительно проверяет read access на клиенте |

При добавлении нового сценария явно выберите модель прав и задокументируйте её.

## Merge rights

Merge изменяет данные и переносит ссылки, поэтому нужен отдельный контроль возможности. В процессном контуре есть `IsMergePossible` с признаками:

- `InvalidRights`;
- `InvalidEntitiesCount`.

Серверный merge должен валидировать набор записей и конфликты до выполнения updates/deletes.

## Unique/ignore list

`AddToIgnoreList` и `AddToUniqueList` влияют на будущие результаты поиска. Доступ к этим действиям должен соответствовать правам пользователя на объект и бизнес-правилам раздела.

## Search results per user

Classic results фильтруются по текущему `SysAdminUnitId`, поэтому один пользователь не должен видеть search result группы другого пользователя.

## Практические правила

- Не показывайте duplicate widget без read check.
- Для bulk с `UseAdminRights = true` добавляйте отдельные проверки видимости перед отображением.
- Перед merge проверяйте права на изменение/удаление всех записей группы.
- Не переносите references под system context без бизнес-основания.
- Для ignore/unique actions проверяйте доступ к исходной сущности.

## Связанные документы

- [Deduplication overview](deduplication-overview.md)
- [Security overview](security-overview.md)
- [Security schema and record rights](security-schema-record-rights.md)
- [Deduplication troubleshooting](deduplication-troubleshooting.md)
