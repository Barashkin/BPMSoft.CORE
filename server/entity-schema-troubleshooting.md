# Entity Schema Troubleshooting

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: EntitySchema, troubleshooting, columns, lookup, indexes, ExtendParent -->

> Практический чеклист диагностики проблем со схемами сущностей, колонками, lookup-связями и metadata layers.

## Схема не найдена

Проверьте:

- техническое имя схемы, а не caption;
- пакет установлен и скомпилирован;
- схема не является только extension layer с другим generated name;
- нужный workspace использует актуальную конфигурацию;
- нет путаницы между view schema и table schema.

Для lookup в коде используйте:

```csharp
var schema = userConnection.EntitySchemaManager.GetInstanceByName("Contact");
```

## Колонка не найдена

Проверьте:

- колонка добавлена в `InitializeColumns`;
- колонка находится в parent/extension layer;
- используется `ColumnValueName`, если это lookup id;
- для ESQ колонка явно добавлена через `esq.AddColumn`;
- имя не перепутано с display column.

Для lookup `Account` id обычно читается как `AccountId`, а display value может быть `AccountName`.

## Lookup возвращает пустой Guid

Проверьте:

- заполнено ли `{ColumnName}Id`;
- правильно ли указан `ReferenceSchemaUId`;
- загружена ли колонка в ESQ;
- не используется ли display column вместо value column;
- не удалена ли связанная запись.

## ExtendParent путают с новой сущностью

Если `ExtendParent = true`, это layer расширения. Ищите базовую схему по `ParentSchemaUId` и цепочку package-specific файлов.

Признаки extension layer:

- добавляет только часть колонок;
- generated entity наследует базовую entity;
- `RealUId` указывает на текущий слой;
- `GetParentRealUIds` продолжает цепочку.

## Индекс не работает как ожидается

Проверьте:

- индекс добавлен в `InitializeIndexes`;
- `ColumnUId` соответствует нужной колонке;
- `IsUnique` выставлен осознанно;
- в БД применены актуальные изменения конфигурации;
- фильтр запроса действительно использует индексируемые колонки.

Уникальный index не заменяет пользовательскую validation-ошибку. Для UX добавляйте listener validation.

## View ведёт себя не как таблица

Проверьте:

- `IsDBView = true`;
- schema наследуется от view/base schema;
- операции записи поддерживаются конкретным view-сценарием;
- required columns могли быть ослаблены;
- данные приходят из SQL view, а не из entity insert pipeline.

## Default values не заполнились

Проверьте:

- вызван ли `SetDefColumnValues()` перед сохранением новой entity;
- есть ли `DefValue` у колонки;
- default зависит от `SystemValueManager`;
- значение не перезаписано вручную перед `Save`.

## EventsProcess неожиданно выполняется

Проверьте:

- `CreateEventsProcess` в schema class;
- generated entity method `InitializeEmbeddedProcess`;
- `InitializeThrowEvents`;
- package-specific `EventsProcess` для extension layer;
- обычные `BaseEntityEventListener` рядом с generated process.

См. [EventListener EventsProcess](event-listeners-eventsprocess.md).

## Быстрый чеклист

- Имя схемы техническое.
- Проверены parent и extension layers.
- Lookup id читается через `{ColumnName}Id`.
- Display value не используется как FK.
- ESQ выбирает нужные колонки явно.
- Для новых entity вызывается `SetDefColumnValues()`.
- Для view не предполагается обычная write-семантика.
- Index и listener validation не подменяют друг друга.

## Связанные документы

- [Entity Schema Overview](entity-schema-overview.md)
- [Entity Schema columns and lookups](entity-schema-columns-lookups.md)
- [Entity Schema inheritance](entity-schema-inheritance.md)
- [ESQ troubleshooting](esq-troubleshooting.md)
- [EventListener troubleshooting](event-listeners-troubleshooting.md)
