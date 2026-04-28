# Analytics Dashboard Troubleshooting

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: analytics, dashboard, troubleshooting, widgets -->

> Диагностика проблем дашбордов: пустые вкладки, неработающие виджеты,
> неверные фильтры, drill-down, mobile и legacy-путаница.

## Dashboard пустой

Проверьте:

- запись `SysDashboard`;
- JSON в `Items`;
- JSON в `ViewConfig`;
- совпадение `ViewConfig.name` с ключом в `Items`;
- наличие `widgetType` в item config;
- права на чтение dashboard.

Точка входа: `AnalyticsServiceUtils.FetchDashboardItemsData`.

## Виджет не строится

Проверьте:

- `DashboardEnums.WidgetType`;
- view module;
- design module;
- configuration message;
- server class с `DashboardItemDataAttribute`;
- fallback на `BaseDashboardItemData`.

Если client registry есть, но server data class нет, UI может открыться без
ожидаемых данных.

## Indicator показывает неверное значение

Проверьте:

- `columnName`;
- `aggregationType`;
- `filterData`;
- primary column fallback;
- `timeZoneOffset` для date filters;
- права на исходную entity.

Точки входа:

- `IndicatorDashboardItemData.Platform.cs`;
- `BaseDashboardItemSelectBuilder`.

## Chart drill-down не работает

Проверьте:

- `ChartDrillDownProvider.drillDownHistory`;
- `serializedFilterData`;
- `columnDataValueType`;
- `columnsCaptions`;
- lookup path в client schema columns;
- `queryDataLimit`;
- `serieIndex`.

Для grid data проверьте `GetChartGridData` или `GetChartGridDataByFilter`.

## Dashboard grid пустой

Проверьте:

- `moduleConfig.entitySchemaName`;
- загрузку entity schema через `BPMSoft.require`;
- `DashboardListedGridViewModel`;
- filters в config;
- record rights исходной entity;
- paging options.

Точка входа: `DashboardGridModule.Platform.js`.

## Вкладки не сохраняют порядок

Проверьте:

- включен ли dashboard edit mode;
- доступна ли операция `CanCreateDefaultGridSettings`;
- не является ли вкладка favorite;
- обработчики drag-and-drop;
- save/cancel controls.

Точка входа: `DashboardBuilder.Platform.js`.

## Не работает section analytics

Проверьте:

- вызывается ли `GetDashboardItemDataForSection`;
- передается ли `bindingColumnValue`;
- поддерживает ли server data class section constructor;
- применяется ли `ApplySectionBindingFilter`;
- корректна ли привязочная колонка.

## Mobile dashboard не грузит данные

Проверьте:

- URL `rest/AnalyticsService/{method}`;
- POST `jsonData`;
- timeout;
- `ServiceResponseParser` на failure;
- доступность тех же dashboard records для mobile user.

Точка входа: `MobileAnalyticsService.Mobile.js`.

## Путаются разные analytics modules

Не используйте как основной dashboard runtime:

- `AnalyticsManager.Managers.js` — web analytics/Google Tag Manager;
- `AnalyticsModule.NUI.js` — legacy NUI;
- Apdex `Metric*` — отдельная подсистема метрик;
- `SysModuleAnalyticsReport` — связь модуля с analytics report.

## Связанные документы

- [Analytics dashboards overview](analytics-dashboards-overview.md)
- [Analytics dashboard pattern catalog](analytics-dashboard-pattern-catalog.md)
- [Services troubleshooting](services-troubleshooting.md)
- [ESQ troubleshooting](esq-troubleshooting.md)
