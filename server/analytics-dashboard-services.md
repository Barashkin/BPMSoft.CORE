# Analytics Dashboard Services

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: AnalyticsService, AnalyticsServiceUtils, dashboard data, WCF -->

> Серверная выдача данных дашбордов: `AnalyticsService`,
> `AnalyticsServiceUtils`, factory и stream JSON responses.

## AnalyticsService

`AnalyticsService.Platform.cs` — WCF service для dashboard data.

Особенности:

- `[ServiceContract]`;
- наследуется от `BaseService`;
- реализует `IReadOnlySessionState`;
- методы используют `WebInvoke(Method = "POST")`;
- ответы возвращаются как `Stream`;
- `GetResponseStream` выставляет `application/json; charset=utf-8`.

## Public API

| Метод | Назначение |
| ----- | ---------- |
| `GetDashboardViewConfig` | вернуть layout + `widgetType` |
| `GetDashboardData` | вернуть данные всех items |
| `GetDashboardItemData` | вернуть данные одного item |
| `GetDashboardItemDataForSection` | вернуть item с section binding |
| `GetChartGridData` | вернуть drill grid графика |
| `GetChartGridDataByFilter` | вернуть filtered drill grid |
| `GetChartGridDataConfigs` | вернуть columns config графика |
| `GetIndicatorGridDataConfig` | вернуть columns config индикатора |
| `GetIndicatorGridData` | вернуть drill grid индикатора |

Большинство методов принимает `timeZoneOffset`, потому что dashboard filters и
date functions должны считаться в пользовательском времени.

## AnalyticsServiceUtils

`AnalyticsServiceUtils` выполняет основную работу:

1. Читает `Items` и `ViewConfig` из `SysDashboard`.
2. Находит item config по имени.
3. Определяет `widgetType`.
4. Создает обработчик через `DashboardItemDataFactory`.
5. Возвращает JSON данных виджета.

Если factory не нашла class для widget type, обычный dashboard path падает
обратно на `BaseDashboardItemData`.

## DashboardItemDataFactory

`DashboardItemDataFactory` сканирует workspace assembly и ищет классы:

- с атрибутом `[DashboardItemData("...")]`;
- реализующие `IDashboardItemData`.

Класс создается через `ClassFactory.ForceGet` с constructor arguments:

- `dashboardName`;
- `config`;
- `bindingColumnValue` для section path;
- `userConnection`;
- `timeZoneOffset`.

## Base select builder

`BaseDashboardItemSelectBuilder` строит ESQ/Select для data classes и учитывает:

- `CancellationToken`;
- `timeZoneOffset`;
- date macros filters;
- `DatePartQueryFunction.UtcOffset`;
- pageable options;
- map колонок для чтения из `IDataReader`.

## Практические правила

- Не возвращайте dashboard JSON через обычный DTO, если локальный паттерн
  использует `Stream`.
- Для нового server widget data class добавляйте `DashboardItemDataAttribute`.
- Для section dashboard реализуйте constructor с `bindingColumnValue`.
- Для date filters всегда передавайте `timeZoneOffset`.
- Если данные пустые, проверяйте `Items`, `ViewConfig`, `widgetType` и factory.

## Связанные документы

- [Analytics dashboards overview](analytics-dashboards-overview.md)
- [Analytics dashboard storage](analytics-dashboard-storage.md)
- [Analytics dashboard widgets](analytics-dashboard-widgets.md)
- [Services overview](services-overview.md)
