# Analytics Mobile Metrics And Legacy

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: mobile analytics, Apdex, legacy analytics, Insight -->

> Смежные зоны аналитики: mobile dashboard runtime, Apdex metrics,
> Insight widgets и legacy NUI modules.

## Mobile analytics service

`MobileAnalyticsService.Mobile.js` объявляет `BPMSoft.AnalyticsService`.

Паттерн вызова:

- base URL: `rest/AnalyticsService/`;
- метод: `POST`;
- `jsonData`;
- `BPMSoft.RequestManager.issueRequest`;
- `BPMSoft.Ajax.request`;
- timeout: `WebRequestTimeout.Ajax`;
- failure parsing через `BPMSoft.ServiceResponseParser`.

Клиентские методы повторяют server API:

- `getDashboardViewConfig`;
- `getDashboardData`;
- `getDashboardItemData`;
- `getDashboardItemDataForSection`;
- `getChartGridData`;
- `getChartGridDataConfigs`;
- `getIndicatorGridData`;
- `getIndicatorGridDataConfig`.

## Mobile dashboard modules

Ключевые mobile files:

- `MobileDashboardPageController.Mobile.js`;
- `MobileDashboardPageView.Mobile.js`;
- `MobileDashboardViewGenerator.Mobile.js`;
- `MobileDashboardDataManager.Mobile.js`;
- `MobileBaseDashboardItem.Mobile.js`;
- `MobileChartDashboardItem.Mobile.js`;
- `MobileIndicatorDashboardComponent.Mobile.js`;
- `MobileIndicatorDashboardItemPageView.Mobile.js`.

Mobile runtime не повторяет полностью web UI, но использует тот же
`AnalyticsService`.

## Apdex metrics

Apdex-метрики — отдельная подсистема, не `SysDashboard`.

Точки входа:

- `MetricSchema.Apdex.cs`;
- `MetricSection.Apdex.js`;
- `MetricPage.Apdex.js`.

Документируйте Apdex отдельно от dashboard widgets, чтобы не смешивать
измерения производительности с пользовательскими dashboard items.

## Insight integration

Insight-related files:

- `DashboardInsightEnums.InsightReport.js`;
- `InsightService.InsightReport.cs`;
- `InsightPageDesigner.InsightReport.js`.

`DashboardsModule` регистрирует Insight widgets через `DashboardInsightEnums`,
но не делает это для portal dashboard.

## Legacy and naming traps

Файлы, которые легко перепутать с runtime дашбордов:

- `AnalyticsManager.Managers.js` — web analytics/Google Tag Manager, не
  `AnalyticsService`;
- `AnalyticsModule.NUI.js` — legacy NUI module;
- `DashboardSectionV2.UIv2.js` — содержит признаки legacy/incomplete path;
- `SysModuleAnalyticsReportSchema.Base.cs` — связь модуля с analytics report,
  не основная сущность dashboard runtime.

## Практические правила

- Для mobile debug начинайте с URL `rest/AnalyticsService/{method}`.
- Apdex metrics документируйте как отдельную модель.
- Insight widgets учитывайте как extension к dashboard enum.
- `AnalyticsManager` не используйте как источник dashboard data.
- Legacy NUI files не берите как основной паттерн для новых dashboard features.

## Связанные документы

- [Analytics dashboards overview](analytics-dashboards-overview.md)
- [Analytics dashboard services](analytics-dashboard-services.md)
- [Mobile overview](mobile-overview.md)
- [Services client calls](services-client-calls.md)
