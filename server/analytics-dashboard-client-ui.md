# Analytics Dashboard Client UI

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: DashboardsModule, DashboardBuilder, dashboard UI, designer -->

> Клиентский runtime дашбордов: `DashboardsModule`, `DashboardBuilder`,
> вкладки, избранное, edit mode и designer integration.

## DashboardsModule

`DashboardsModule.Platform.js` наследуется от `BPMSoft.BaseSchemaModule`.

Ключевые поля:

- `viewModelClassName = "BPMSoft.BaseDashboardsViewModel"`;
- `builderClassName = "BPMSoft.DashboardBuilder"`;
- `viewConfigClass = "BPMSoft.DashboardsViewConfig"`;
- profile key: `DashboardId`.

Модуль:

- регистрирует sandbox messages;
- строит dashboard profile key из history state;
- вызывает `DashboardBuilder.build`;
- обновляет selected sidebar item;
- подключает Insight widgets, кроме portal dashboard.

## Sandbox messages

Важные сообщения:

- `NeedHeaderCaption`;
- `SelectedSideBarItemChanged`;
- `ContextHelpModuleLoaded`;
- `CanChangeHistoryState`;
- `ConfirmBeforeExitDashboardEditModeRequest`.

Эти сообщения защищают от потери несохраненных изменений и синхронизируют shell
с history/sidebar.

## DashboardBuilder

`DashboardBuilder.Platform.js` генерирует UI:

- tab panel;
- search dashboard button;
- settings menu;
- add/edit/copy/delete dashboard;
- screenshot;
- enable dashboard edit mode;
- hidden base tabs;
- manage rights;
- save/cancel/sort controls для порядка вкладок.

Builder использует:

- `RightUtilities`;
- `MaskHelper`;
- `DashboardManager`;
- `DashboardManagerItem`;
- `FilterableList`;
- `FavoriteTabsDecorator`.

## Favorites and ordering

Вкладки поддерживают:

- избранное;
- filterable search;
- drag-and-drop порядка;
- edit mode;
- сохранение/откат изменений.

Drag-and-drop доступен только при успешной проверке операции
`CanCreateDefaultGridSettings`.

## System Designer dashboards

Для системного дизайнера используются отдельные UIv2 modules:

- `SystemDesignerDashboardsModule.UIv2.js`;
- `SystemDesignerDashboardsViewModel.UIv2.js`;
- `SystemDesignerDashboardBuilder.UIv2.js`.

Там же находятся действия edit/rights для текущего dashboard.

## Section dashboards

`SectionDashboardsModule.Platform.js` наследует общий dashboard shell, но
работает в контексте секции и history state.

## Практические правила

- Для shell-логики используйте `DashboardsModule`, не widget module.
- Для прав на вкладки и меню проверяйте `RightUtilities`.
- Для режима редактирования учитывайте confirm-before-exit сообщения.
- Для поиска вкладок используйте `FilterableList`, не кастомный список.
- Для System Designer не переиспользуйте напрямую обычный builder без проверки
  его viewModel/viewConfig contract.

## Связанные документы

- [Analytics dashboards overview](analytics-dashboards-overview.md)
- [Analytics dashboard widgets](analytics-dashboard-widgets.md)
- [Analytics dashboard drilldown section](analytics-dashboard-drilldown-section.md)
- [Client module overview](../client/client-module-overview.md)
