# Global Search Troubleshooting

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: GlobalSearch, troubleshooting, Elasticsearch, indexing -->

> Диагностика Global Search строится вокруг трех контуров: клиентская страница,
> search service/provider и индексация.

## Поиск не возвращает результаты

Проверить:

1. `SysSettings.GlobalSearchUrl`.
2. Доступность ES/GS endpoint с сервера приложения.
3. Feature `GlobalSearch`.
4. Есть ли сущность в составе индексируемых.
5. Включен ли `SysModule.GlobalSearchAvailable` для секции.
6. Не отфильтрована ли сущность по правам чтения.
7. Логгер `GlobalSearch`.

Если ES возвращает записи, но UI пустой, проверьте record rights: результат
может быть отброшен в `GlobalSearchHelper` после проверки прав.

## Ошибка или timeout при поиске

Проверить:

- `SysSettings.DataServiceQueryTimeout`;
- сетевую доступность `GlobalSearchUrl`;
- credentials в connection string;
- сообщения logger `GlobalSearch`;
- метрики `GlobalSearchErrorCode.Timeout`, `Aborted`, `ElasticError`.

`GlobalSearchService` возвращает `Success = false`, если `RestSharp` не
получил завершенный ответ или внешний ответ не содержит search result.

## Используется не тот provider

На старте `GlobalSearchEventListener` проверяет новый GS endpoint. Если тест
не возвращает `NoContent`, DI регистрирует `ESSearchProvider`.

Проверить:

- корректен ли `GlobalSearchUrl`;
- отвечает ли endpoint `/_getcollection` для test-запроса;
- не истекает ли timeout;
- есть ли debug-сообщение `Use old global search service`;
- есть ли info-сообщение `Use new global search service`.

## Новые секции не попадают в индекс

Проверить:

1. `SysModule.GlobalSearchAvailable`.
2. `SysModuleEntity` у секции.
3. Работу `GlobalSearchSysModuleListener`.
4. Очистку кэша `AvailableIndexingEntities`.
5. Срабатывание `ConfigurationBuildWatcher` после build.
6. Вызов `IndexingConfigService.SendIndexationConfigs`.
7. `GlobalSearchConfigServiceUrl`.

Если менялась `GlobalSearchIndexedDataConfig`, watcher должен получить
`SysSettingsChanged` и переслать конфигурацию индексации.

## Изменения записей не индексируются

Проверить:

- feature `GlobalSearch_V2`;
- entity listeners Global Search;
- вызов `BaseIndexer.IndexEntity`;
- работу `IndexingRequestDataBuilder`;
- отправку через `IndexingEntitySender`;
- доступность indexing service.

Если `GlobalSearch_V2` выключен, `BaseIndexer` молча завершит обработку.

## Не видны результаты на портале

Проверить:

1. Пользователь действительно имеет `ConnectionType = SSP`.
2. Секция опубликована на портале.
3. Entity доступна через SSP licensing/security.
4. Schema есть в portal ACL.
5. Колонки есть в `PortalColumnAccessList`.
6. Кэш `AllowedPortalColumns` не устарел.
7. `GlobalAppSettings.UsePortalSchemaAllowedColumns`.

`GlobalSearchSSPHelper` дополнительно фильтрует aggregation groups и groups
результата, поэтому проблема может проявляться как отсутствие типа сущности в
фильтре поиска.

## Значения колонок или highlights некорректны

Проверить:

- `ESSearchColumnNameProvider`;
- alias lookup колонок;
- `GlobalSearchColumnUtils`;
- `UseLocalizableGlobalSearchResult`;
- наличие колонок в индексе;
- allowed columns для SSP.

Если включены локализованные результаты, часть значений дочитывается через
`EntitySchemaQuery`, а не берется напрямую из ES.

## Страница результатов зависает или повторяет запросы

Проверить:

- `GlobalSearchResultPage.SearchRequestId`;
- обработку `HistoryStateChanged`;
- отмену предыдущего запроса;
- paging через `From` и `NextFrom`;
- размер `RecordCount`;
- состояние `GlobalSearchStorage`.

На клиенте состояние поиска хранится в local store. При странной навигации
или повторном открытии страницы проверьте сохраненные `SearchParams`.
