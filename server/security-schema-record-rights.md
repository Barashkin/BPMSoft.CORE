# Security Schema And Record Rights

<!-- Версия: 1.1 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: schema rights, record rights, column rights, RightsService, DBSecurityEngine, NUI -->

> Права на схемы, записи и колонки: чтение, добавление, изменение, удаление и управление правами.
> Применение этих проверок в NUI grid operations и Excel export см. в
> [nui-record-operations.md](nui-record-operations.md) и
> [nui-excel-grid-export.md](nui-excel-grid-export.md).

## SchemaOperationRightLevels

Schema rights описывают доступ к объекту в целом.

| Уровень | Значение | Описание |
| ------- | -------- | -------- |
| `CanRead` | 1 | чтение записей схемы |
| `CanAppend` | 2 | добавление записей |
| `CanEdit` | 4 | изменение записей |
| `CanDelete` | 8 | удаление записей |

На клиенте эти флаги доступны через `RightUtilities.SchemaOperationRightLevels`.

## Record rights

Record rights описывают доступ к конкретной записи.

```csharp
var rightLevel = UserConnection.DBSecurityEngine.GetEntitySchemaRecordRightLevel(
    userId,
    schemaName,
    recordId);
```

В `RightsService` результат превращается в набор флагов для клиента.

## Проверка редактирования записи

В массовых операциях сначала проверяется право на запись, затем бизнес-условия.

```csharp
if (!GetIsEntitySchemaRecordEditingAllowed(_userConnection.DBSecurityEngine, "Lead", leadId)) {
    leadErrors.Add(leadId, NoRightsToEditCurrentRecordForUserError);
    return false;
}
```

Такой порядок помогает отделить security failure от domain validation.

## Schema vs record failure

`RightsService` различает:

- нет права по схеме;
- нет права по записи;
- нет лицензии;
- есть лицензия, но не хватает right level.

```csharp
if (!rightsHelper.GetCanDeleteSchemaRecordRight(schemaName, id)) {
    SchemaOperationRightLevels rightLevels = UserConnection.LicHelper.GetSchemaLicRights(schemaName, true);
    bool hasLicRight = (rightLevels & SchemaOperationRightLevels.CanDelete) == SchemaOperationRightLevels.CanDelete;
    return hasLicRight ? "RightLevelWarningMessage" : "LicenceNotFound";
}
```

## Column rights

Column rights применяются для чувствительных полей и portal/SSP сценариев. В SSP helpers доступные колонки фильтруются отдельно.

```csharp
return entitySchema.Columns
    .Where(x => CanReadColumnSSPUser(entityName, x));
```

## UseDenyRecordRights

`UseDenyRecordRights` задаётся на уровне entity schema. Значение `false` отключает deny-record-rights для конкретной схемы.

Подробно см. [Entity schema views, indexes and rights](entity-schema-views-indexes-rights.md).

## Практические правила

- Для UI доступности кнопок достаточно client check, но действие должно проверяться на сервере.
- Для массовых операций проверяйте каждую запись.
- Для portal/SSP проверяйте и схему, и доступные колонки.
- Разделяйте "нет права" и "нет лицензии" в сообщениях.
- Не используйте `UseAdminRights = true`, если нужно проверить record rights текущего пользователя.

## Связанные документы

- [Security overview](security-overview.md)
- [Security licenses](security-licenses.md)
- [Security client rights](security-client-rights.md)
- [Entity schema views, indexes and rights](entity-schema-views-indexes-rights.md)
- [NUI Record Operations](nui-record-operations.md)
- [NUI Excel Grid Export](nui-excel-grid-export.md)
