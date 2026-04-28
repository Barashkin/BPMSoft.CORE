# Analytics Dashboard Widgets

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: DashboardEnums, Chart, Indicator, DashboardGrid, widgets -->

> Типы виджетов дашборда: client registry, server data classes,
> indicator, chart grid и dashboard grid.

## Client registry

`DashboardEnums.Platform.js` содержит `BPMSoft.DashboardEnums.WidgetType`.
Для каждого типа задаются два блока:

- `view` — модуль отображения и message конфигурации;
- `design` — модуль дизайнера и schema дизайнера.

Примеры типов:

| Widget type | View module | Designer |
| ----------- | ----------- | -------- |
| `Chart` | `ChartModule` | `ChartDesigner` |
| `Indicator` | `IndicatorModule` | `IndicatorDesigner` |
| `Gauge` | `GaugeModule` | `GaugeDesigner` |
| `DashboardGrid` | `DashboardGridModule` | `DashboardGridDesigner` |
| `Module` | custom module | `ModuleConfigEdit` |
| `WebPage` | `WebPageModule` | `WebPageDesigner` |
| `CalculationIndicator` | `CalculationIndicatorModule` | `CalculationIndicatorDesigner` |

`FullPipeline` добавляется условно, если включена feature `FullPipeline`.

## DashboardGrid

`DashboardGridModule.Platform.js` наследуется от `BaseWidgetModule`.

Паттерн:

1. Получает `GetDashboardGridConfig`.
2. Загружает entity schema по `moduleConfig.entitySchemaName`.
3. Использует `DashboardListedGridViewModel`.
4. Генерирует view через `DashboardListedGridViewConfig`.
5. При `GenerateDashboardGrid` пересоздает view/viewModel.

Это dashboard list widget, а не обычная section grid.

## Indicator

`IndicatorDashboardItemData.Platform.cs` описывает server data для
`widgetType = "Indicator"`.

`IndicatorDashboardItemSelectBuilder`:

- берет `columnName`;
- если колонка не задана, использует primary column;
- выбирает `aggregationType`, по умолчанию `Count`;
- строит `EntitySchemaAggregationQueryFunction`;
- добавляет фильтр из `filterData`;
- сохраняет alias и data value type.

`IndicatorDashboardItemData` также умеет вернуть grid config и grid records для
детализации.

## Chart drill grid

Для графиков данные drill grid возвращаются через:

- `AnalyticsService.GetChartGridData`;
- `AnalyticsService.GetChartGridDataByFilter`;
- `AnalyticsServiceUtils.GetChartGridData`;
- `ChartDashboardItemData.GetGridData`.

Параметры:

- `rowCount`;
- `rowOffset`;
- `serieIndex`;
- optional `filterValue`.

## Server widget registration

Server-side типы виджетов связываются через:

```text
[DashboardItemData("Indicator")]
```

Класс должен реализовать `IDashboardItemData`. Factory ищет такие классы в
workspace assembly.

## Практические правила

- Для нового widget type синхронизируйте client `DashboardEnums` и server
  `DashboardItemDataAttribute`.
- Для grid widget обязательно задавайте `entitySchemaName`.
- Для indicator проверяйте `columnName`, `aggregationType`, `filterData`.
- Для chart drill grid учитывайте `rowCount`, `rowOffset`, `serieIndex`.
- Не смешивайте `DashboardItemType` lookup и `DashboardEnums.WidgetType`.

## Связанные документы

- [Analytics dashboards overview](analytics-dashboards-overview.md)
- [Analytics dashboard services](analytics-dashboard-services.md)
- [Analytics dashboard client UI](analytics-dashboard-client-ui.md)
- [ESQ overview](esq-overview.md)
