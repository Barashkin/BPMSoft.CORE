# Deduplication Client UI

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: deduplication UI, duplicates widget, merge module, rules page -->

> Клиентский UI дедупликации: виджет, страницы дублей, merge module, правила и настройки расписания.

## Widget

`DuplicatesWidgetViewModel` показывает найденные дубли на карточке/секции. При клике он сначала проверяет, может ли пользователь прочитать хотя бы одну запись из набора дублей.

```javascript
esq.filters.add("EntityIdInFilter",
    BPMSoft.createColumnInFilterWithParameters("Id", data.duplicates));
```

Если доступных записей нет, показывается информационное сообщение.

## Sections and pages

Deduplication расширяет типовые разделы:

- `ContactSectionV2.Deduplication.js`;
- `AccountSectionV2.Deduplication.js`;
- `ContactPageV2.Deduplication.js`;
- `AccountPageV2.Deduplication.js`;
- `ContactMiniPage.Deduplication.js`.

Для Contact section учитывается `DeduplicationEnabled` и операция поиска дублей.

## Duplicates pages

Ключевые UI modules:

- `DuplicatesPageV2`;
- `LazyDuplicatesPageV2`;
- `DuplicatesDetailModuleV2`;
- `LazyDuplicatesDetailViewModel`;
- `DuplicatesDetailViewConfigV2`.

Lazy pages нужны для больших наборов результатов и работают с offset/pagination service methods.

## Merge UI

`DuplicatesMergeModuleV2` и `DuplicatesMergeViewModelV2` открывают modal box и собирают выбранные значения колонок в `mergeConfig`.

Пользователь выбирает, из какой записи взять значение конфликтной колонки, затем UI публикует sandbox message `Merge`.

## Rules UI

`DuplicatesRulePageV2` и `DuplicatesRuleSectionV2` управляют правилами. Страница:

- ограничивает `Object` списком поддерживаемых схем;
- загружает доступные sections из `SysModule.GlobalSearchAvailable`;
- сбрасывает `RuleBody` при смене объекта в add mode;
- учитывает feature flags `ESDeduplication` и `BulkESDeduplication`.

## Settings pages

Дополнительные страницы:

- `DuplicateRulesSettings`;
- `ScheduledDuplicatesSearchSettingsPage`;
- `SearchDuplicatesUserTaskPropertiesPage`.

Они покрывают настройки правил, расписание поиска и свойства user task в дизайнере процессов.

## Практические правила

- Перед открытием страницы дублей проверяйте read access хотя бы к одной записи.
- Для больших результатов используйте lazy pages.
- Merge UI должен отправлять только выбранные конфликтные значения.
- Rules UI должен сбрасывать `RuleBody` при смене объекта в режиме добавления.
- Для Contact/Account проверяйте package extensions секций и страниц.

## Связанные документы

- [Deduplication overview](deduplication-overview.md)
- [Deduplication merge](deduplication-merge.md)
- [Deduplication rules](deduplication-rules.md)
- [Client Module Overview](../client/client-module-overview.md)
