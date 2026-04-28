# Analytics Dashboard Storage

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: SysDashboard, SysWidgetDashboard, DashboardItemType, ViewConfig -->

> Хранение дашбордов: схемы `SysDashboard`, `SysWidgetDashboard`,
> `DashboardItemType` и JSON-поля `Items`/`ViewConfig`.

## SysDashboard

`SysDashboard` — базовая entity schema платформенного дашборда.
В пакете `Platform` схема расширяет базовый слой:

- `Name = "SysDashboard"`;
- `ExtendParent = true`;
- `IsDBView = false`;
- `UseDenyRecordRights = false`;
- `UseRecordDeactivation = false`.

Сущность создает `SysDashboard_PlatformEventsProcess`, но сам generated
events process не содержит бизнес-логики.

## SysWidgetDashboard

`SysWidgetDashboard` наследуется от `SysDashboard` и используется для
виджет-дашбордов.

Особенности:

- `Name = "SysWidgetDashboard"`;
- `ExtendParent = false`;
- `Caption` не является обязательным;
- generated events process бросает событие `SysWidgetDashboardDeleted`.

## DashboardItemType

`DashboardItemType` — справочник типов элементов дашборда. Он наследуется от
`BaseCodeLookupSchema`, поэтому типы можно искать по коду.

Не путайте:

- `DashboardItemType` — metadata type в БД;
- `DashboardEnums.WidgetType` — клиентский registry view/design modules;
- `DashboardItemDataAttribute` — server-side привязка widget type к классу.

## Items and ViewConfig

`AnalyticsServiceUtils.FetchDashboardItemsData` читает из `SysDashboard` две
строковые колонки:

- `Items` — конфигурации виджетов по имени;
- `ViewConfig` — массив элементов раскладки.

Затем `GetDashboardViewConfig` соединяет эти структуры:

1. Берет `viewConfig.name`.
2. Ищет одноименный item в `items`.
3. Добавляет в view item поле `widgetType`.

Если `Items` пустой или элемент не найден по имени, виджет не попадает в
результат.

## Практические правила

- Имя в `ViewConfig.name` должно совпадать с ключом в `Items`.
- `widgetType` берется из item config, а не из layout.
- Для нового типа виджета нужны server data class и client registry.
- `SysWidgetDashboard` — специализированная схема, не замена всем
  `SysDashboard`.
- Ошибки в JSON чаще проявляются как пустой dashboard, а не как compile error.

## Связанные документы

- [Analytics dashboards overview](analytics-dashboards-overview.md)
- [Analytics dashboard services](analytics-dashboard-services.md)
- [Analytics dashboard widgets](analytics-dashboard-widgets.md)
- [Entity schema overview](entity-schema-overview.md)
