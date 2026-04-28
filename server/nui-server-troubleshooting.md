# NUI Server Troubleshooting

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: NUI, troubleshooting, approval, grid, export, workplace -->

> Диагностика серверного слоя NUI: согласования, массовые операции,
> Excel export, audit archive, configuration/workplace endpoints.

## Быстрая классификация

| Симптом | Начать с |
| ------- | -------- |
| Approve/reject не срабатывает | [nui-visa-approval.md](nui-visa-approval.md) |
| История виз пустая | `SysModuleVisa`, `VisaDataService.GetVisaHistory` |
| Массовое удаление зависло | `GridUtilitiesService`, `MultiDelete` log, AppScheduler |
| Экспорт Excel запрещён | `CanExportGrid`, `UseEntityOperationGrantee`, `Export` |
| Excel скачивается пустым | serialized `SelectQuery`, фильтры, binary columns |
| Audit archive возвращает `0` | даты, operation types |
| Секция/рабочее место не обновилось | `WorkplaceService`, cache reset |

## Approval / visa

Проверьте:

1. `ApprovalRequest.id` и `schemaName`.
2. Существует ли visa record.
3. Не находится ли виза уже в финальном статусе.
4. Что `IApprovalAction` зарегистрирован и доступен через `ClassFactory`.
5. Для SSP — доступ пользователя и route `[SspServiceRoute]`.

Типовые ошибки:

- `VisaNotFoundException` — неверный id/schema;
- `VisaFinalStatusException` — повторный approve/reject;
- `SaveVisaChangesException` — изменения статуса не сохранились.

## Visa history

Если история пустая:

1. Проверьте `SysModule.Code` для `parentSchemaName`.
2. Проверьте связь `SysModule.SysModuleVisa`.
3. Проверьте `VisaSchemaUId` и `MasterColumnUId`.
4. Убедитесь, что записи не `IsCanceled`.
5. Убедитесь, что статус не `ApprovalConstants.Canceled`.

## Record operations

Для `DeleteRecords(...)` и `DeleteRecordsAsync(...)` проверьте:

- `rootSchema`;
- primary column values или `filtersConfig`;
- locked records через collision checker;
- record rights текущего пользователя;
- `DefaultNumberItemsReturned`;
- наличие scheduled job для большого набора.

Логгер: `MultiDelete`.

Если ошибка сохранилась в `MultiDeleteQueue`, смотрите `DenyReason`.

## Multi-link operations

Для `MultiOperationService.MultiLinkEntity(...)`:

1. `entityName` не должен быть пустым.
2. Должны быть `recordsId` или `filtersConfig`.
3. `parameters` должен десериализоваться в dictionary.
4. Strategy `MultiLinkEntity` должна создаться через `ClassFactory`.

Ошибки обычно возвращаются в `ConfigurationServiceResponse.Exception`.

## Excel export

Проверьте:

1. Корректно ли сериализован `SelectQuery`.
2. Есть ли право `CanExportGrid`.
3. Если включён `UseEntityOperationGrantee`, есть ли entity operation `Export`.
4. Значение `ExcelExportBatchSize`.
5. Не ожидает ли пользователь binary/image columns в файле.
6. Создался ли `StorableStreamEntity`.

Если включён `UseAdminOperationImportExport`, дополнительно проверьте запись в
`SysOperationAudit`.

## Audit archive

`AuditService.MoveToArchive(...)` возвращает `0`, если:

- `startDate` не распарсился;
- `endDate` не распарсился;
- operation types не совпали с enum;
- за период нет подходящих записей.

## Configuration / workplace

Если изменения секций или рабочих мест не видны:

1. Проверьте `SysModuleInWorkplace` и `SysAdminUnitInWorkplace`.
2. Проверьте `SysModuleEdit`, `CardSchema`, `CardModule`.
3. Вызовите `ResetScriptCache()` или `ResetWorkplaceCache()`.
4. Проверьте, что `RefreshWorkplace(...)` возвращает актуальный script.
5. Для visa в секции проверьте `SysModuleVisa`.

## Связанные документы

- [NUI Server Overview](nui-server-overview.md)
- [NUI Server Pattern Catalog](nui-server-pattern-catalog.md)
- [Services Troubleshooting](services-troubleshooting.md)
- [Security Troubleshooting](security-troubleshooting.md)
- [Quartz Troubleshooting](quartz-troubleshooting.md)
