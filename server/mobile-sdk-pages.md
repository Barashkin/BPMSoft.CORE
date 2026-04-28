# Mobile SDK Pages

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: Mobile SDK, GridPage, RecordPage, embedded detail, actions -->

> Клиентская конфигурация мобильных страниц: `BPMSoft.sdk.RecordPage`,
> `GridPage`, embedded details, actions и query config columns.

## RecordPage

`MobileContactModuleConfig.Mobile.js` и
`MobileActivityModuleConfig.Mobile.js` показывают основной стиль настройки:

- `setTitle`;
- `configureColumn`;
- `addColumn`;
- `setImageConfig`;
- `configureEmbeddedDetail`;
- `addQueryConfigColumns`.

Колонки настраиваются по модели, column set/detail name и имени колонки.

```javascript
BPMSoft.sdk.RecordPage.configureColumn("Activity", "relationsColumnSet",
    "Account", {
        viewType: BPMSoft.ViewTypes.Preview
    });
```

## Embedded details

Мобильные details описываются через `configureEmbeddedDetail`.

Типовые настройки:

- `title`;
- `displaySeparator`;
- `hideTitle`;
- `alwaysShowTitle`;
- `previewConfig`;
- `imageConfig`;
- `isInPlaceEditingMode`;
- `pagingConfig`.

Для Contact используются details коммуникаций, адресов и памятных дат.
Для Activity — участники.

## GridPage

Grid pages настраиваются через:

- `setImageColumn`;
- `setOrderByColumns`;
- `addColumns`;
- `configureSubtitleColumn`;
- `setAdditionalFilterModule`.

Activity grid добавляет служебные колонки статуса, owner, period columns и
настраивает subtitle как диапазон start/due date.

## Actions

`BPMSoft.sdk.Actions.add` создаёт мобильные действия:

- quick actions;
- создание связанных Activity;
- добавление записей embedded detail;
- копирование через `BPMSoft.ActionCopy`.

Action может передавать поля из source model в destination model и задавать
значения по macros current user contact.

## Filters

`BPMSoft.sdk.Module.addFilter` добавляет фильтр модуля. В Activity пример
исключает email activity type из мобильного списка.

## Практические правила

- Добавляйте в grid только нужные колонки, иначе sync и render дорожают.
- Для preview lookup используйте `BPMSoft.ViewTypes.Preview`.
- Для embedded detail явно задавайте preview и paging.
- Hidden/read-only служебные поля добавляйте через `addColumn`.
- Действия должны заполнять обязательные поля через constants или macros.

## Связанные документы

- [Mobile overview](mobile-overview.md)
- [Mobile manifest sync](mobile-manifest-sync.md)
- [Client page lifecycle](../client/client-page-lifecycle.md)
- [Client diff attributes rules](../client/client-diff-attributes-rules.md)
