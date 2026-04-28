# NUI Server Boundaries

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: NUI, boundaries, Services, Client, Security -->

> Границы NUI server layer с уже описанными dive-блоками.

## Services

Services dive описывает общий WCF/REST фундамент:

- `[ServiceContract]`;
- `[OperationContract]`;
- `[WebInvoke]`;
- `BaseService`;
- `ConfigurationServiceResponse`;
- client service calls.

NUI server dive описывает предметные сервисы поверх этого фундамента:
approval, visa, grid operations, Excel export, audit archive, configuration
data и workplace.

## Client Module

Client Module dive отвечает за AMD-модули, sandbox, diff, view models и
`ServiceHelper`.

NUI server отвечает за endpoint и server-side выполнение действия. Если
проблема в кнопке, diff или sandbox message — это Client. Если запрос дошёл до
сервера и падает на правах, ESQ, AppScheduler или DTO — это NUI server.

## Security

Security dive описывает модель прав. NUI server применяет эти права в
конкретных сценариях:

- `CanExportGrid` / entity operation `Export`;
- record rights перед удалением;
- SSP route и доступ к approval;
- admin operations для audit/change log.

## Administration

Administration описывает метаданные рабочих мест, секций, настроек и пакетов.
NUI configuration/workplace показывает, как сервер отдаёт эти данные client
shell и управляет cache.

## FileImport

FileImport — это загрузка Excel/данных в систему: upload, mapping, chunks,
validation. NUI Excel export — обратное направление: выгрузка grid/dashboard
данных по serialized `SelectQuery`.

## Reports

Reports dive покрывает Word/FastReport/printables. NUI Excel export строит
Excel-файл из grid query и не использует report templates.

## Process

Process dive описывает execution, user tasks, logs и scheduler запуска
процессов. NUI может иметь сервисы вроде `ProcessInfoService`, но approval API
не надо смешивать с runtime процессов, если нет явного процесса после
approve/reject.

## Notifications

Notifications/Reminders покрывает delivery уведомлений, counters, websocket и
push. NUI visa/approval меняет и читает согласования. Счётчики виз и
providers находятся на границе, но pipeline уведомлений описывается в
Notifications dive.

## Activity / Email

Activity/Email отвечает за задачи, письма, календарь и mailbox sync. NUI
сервисы могут обслуживать activity UI, но это не делает activity lifecycle
частью NUI server dive.

## Связанные документы

- [NUI Server Overview](nui-server-overview.md)
- [Services Overview](services-overview.md)
- [Client Module Overview](../client/client-module-overview.md)
- [Security Overview](security-overview.md)
- [Administration And Configuration Overview](admin-configuration-overview.md)
- [Notifications Reminders Overview](notifications-reminders-overview.md)
