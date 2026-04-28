# NUI Server Pattern Catalog

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: NUI, patterns, WCF, grid, approval, export -->

> Каталог рабочих паттернов NUI server layer: как устроены сервисы,
> массовые операции, экспорт, approval и configuration endpoints.

## Thin WCF facade

Паттерн:

1. Класс помечен `[ServiceContract]`.
2. Метод помечен `[OperationContract]` и `[WebInvoke]`.
3. Сервис наследуется от `BaseService`.
4. Метод валидирует входные данные.
5. Предметная работа делегируется helper/manager/action.
6. Ответ возвращается как DTO, `ConfigurationServiceResponse`, `BaseResponse`
   или serialized NUI response.

Примеры:

- `ApprovalService.NUI.cs`;
- `AuditService.NUI.cs`;
- `ConfigurationDataService.NUI.cs`.

## Default + SSP route

Если NUI действие должно работать из основного приложения и SSP, сервис
использует:

```csharp
[DefaultServiceRoute]
[SspServiceRoute]
```

Примеры: `ApprovalService`, `VisaDataService`, `ActivityUtilService`.

Проверяйте SSP-права отдельно: наличие route не означает, что portal user
может читать все связанные данные.

## Serialized SelectQueryResponse

Некоторые NUI endpoints возвращают не strongly typed бизнес DTO, а
`SelectQueryResponse`, сериализованный в строку.

Пример: `VisaDataService.GetVisaEntities(...)`.

Это удобно для grid/list UI, потому что клиент получает rows и row config в
формате NUI data layer.

## FiltersConfig to record ids

Для массовых операций UI может передать не список ids, а фильтры текущего
грида. Серверный паттерн:

```text
filtersConfig
  -> JsonConvert.DeserializeObject<Filters>
  -> SelectQuery.BuildEsq(UserConnection)
  -> primary column values
  -> bulk operation
```

Пример: `GridUtilitiesServiceHandler.GetPrimaryColumnValuesFromFilters(...)`.

## Small sync / large async

Для удаления записей `DeleteRecordsAsync(...)` выбирает режим по размеру:

- малый набор — выполнить `MultiDeleteExecutor` сразу;
- большой набор или delete all — запустить class job через `AppScheduler`.

Порог берётся из `DefaultNumberItemsReturned`.

## Per-record executor

Bulk operation не должна быть одним SQL delete без контроля. Паттерн NUI:

- worker получает коллекцию ids;
- ESQ загружает записи;
- executor проверяет права каждой записи;
- операция выполняется по одной записи;
- результат фиксируется через `RecordProcessed`.

Примеры:

- `BaseRecordExecutor`;
- `BaseRecordsOperationWorker`;
- `MultiDeleteOperationAgent`.

## Export rights fallback

Excel export сначала проверяет глобальную операцию `CanExportGrid`. Если
включён `UseEntityOperationGrantee`, допускается fallback на entity operation
`Export` для конкретной схемы.

Этот паттерн полезен, когда глобальное право заменяется более точной
entity-level моделью.

## Cache reset endpoints

Для configuration/workplace сервисов отдельные методы управляют cache:

- `ResetScriptCache`;
- `ResetWorkplaceCache`;
- `SetWorkplaceCache`;
- `RefreshWorkplace`.

После изменения `SysWorkplace`, `SysModule` или состава секций не забывайте
проверять server/client cache.

## Audit as side effect

Некоторые NUI операции пишут audit записи как побочный эффект. Например,
`ExportToExcelService` при включённом `UseAdminOperationImportExport` пишет в
`SysOperationAudit`.

Не смешивайте это с `AuditService.MoveToArchive`: export создаёт запись,
audit service архивирует журнал.

## Связанные документы

- [NUI Server Overview](nui-server-overview.md)
- [NUI Record Operations](nui-record-operations.md)
- [NUI Excel Grid Export](nui-excel-grid-export.md)
- [NUI Visa And Approval](nui-visa-approval.md)
- [NUI Server Troubleshooting](nui-server-troubleshooting.md)
