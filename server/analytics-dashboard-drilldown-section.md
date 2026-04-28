# Analytics Dashboard Drill Down And Section Binding

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: drill-down, section dashboards, ChartDrillDownProvider, bindingColumnValue -->

> Drill-down графиков и секционная аналитика: история, фильтры,
> grid data и `bindingColumnValue`.

## ChartDrillDownProvider

`ChartDrillDownProvider.Platform.js` управляет drill-down для chart widgets.

Используемые mixins:

- `EntityStructureHelperMixin`;
- `ChartDrillDownProviderUtils`;
- `QueryCancellationMixin`.

Ключевые поля:

- `queryDataLimit`;
- `ignoreQueryDataLimit`;
- `filterMessageTag`;
- `columnDataValueType`;
- `columnsCaptions`;
- `serializedFilterData`;
- `drillDownHistory`;
- `seriesConfig`;
- `initialGeneralState`;
- `initialSeriesState`.

## Drill history

Provider хранит историю переходов и генерирует событие `historyChanged`.

При выборе колонки:

1. Добавляется фильтр выбранного элемента.
2. Обновляется current history.
3. Сохраняются caption и data value type выбранной колонки.

Для column metadata provider читает client schema columns, включая lookup paths.

## Grid data after drill

Серверные endpoints:

- `GetChartGridData`;
- `GetChartGridDataByFilter`;
- `GetChartGridDataConfigs`.

Ключевые параметры:

- `dashboardId`;
- `itemName`;
- `timeZoneOffset`;
- `rowCount`;
- `rowOffset`;
- `serieIndex`;
- `filterValue`.

## Section binding

Для аналитики внутри карточки/секции используется:

```text
GetDashboardItemDataForSection(dashboardId, itemName, timeZoneOffset, bindingColumnValue)
```

`AnalyticsServiceUtils` передает `bindingColumnValue` в factory, а data class
должен применить section binding filter.

В `IndicatorDashboardItemData.GetData` перед построением select вызывается
`ApplySectionBindingFilter`.

## SectionDashboardsModule

`SectionDashboardsModule.Platform.js` — клиентская точка для дашбордов в
контексте секции. Она переиспользует общий shell и связывает UX с history state.

## Практические правила

- Для drill-down проверяйте не только chart config, но и `drillDownHistory`.
- Для date filters передавайте корректный `timeZoneOffset`.
- Для section analytics data class должен поддерживать constructor с
  `bindingColumnValue`.
- Для grid paging используйте `rowCount` и `rowOffset`.
- Если lookup path не drill-down-ится, проверьте client schema columns.

## Связанные документы

- [Analytics dashboards overview](analytics-dashboards-overview.md)
- [Analytics dashboard services](analytics-dashboard-services.md)
- [Analytics dashboard widgets](analytics-dashboard-widgets.md)
- [ESQ filters](esq-filters.md)
