# Security Licenses

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: LicHelper, LicManager, license rights, schema license, operation license -->

> Лицензии дополняют права: пользователь может иметь право, но не иметь лицензии на операцию или схему.

## Operation license

Для проверки лицензии на операцию используется `LicHelper`.

```csharp
bool hasLicense = UserConnection.LicHelper.GetHasOperationLicense(operation);
```

Пример: `CtiRightsService` проверяет operation license для CTI-операций.

## Schema license rights

Для схем используются license rights с теми же флагами, что и schema rights.

```csharp
SchemaOperationRightLevels rightLevels = UserConnection.LicHelper.GetSchemaLicRights(schemaName, true);
bool canDeleteByLicense =
    (rightLevels & SchemaOperationRightLevels.CanDelete) == SchemaOperationRightLevels.CanDelete;
```

`RightsService` использует этот результат, чтобы выбрать между сообщениями:

- `RightLevelWarningMessage` — лицензия есть, но не хватает прав;
- `LicenceNotFound` — не хватает лицензии.

## LicManager

Для назначения и удаления лицензий используется `LicManager`.

```csharp
UserConnection.AppConnection.LicManager.AddUserLicense(SystemUserConnection, userId, sysPackageId);
UserConnection.AppConnection.LicManager.DeleteUserLicense(SystemUserConnection, userId, sysPackageId);
```

Такой код должен выполняться после проверки operation right текущего пользователя.

## License vs rights

| Ситуация | Что проверять |
| -------- | ------------- |
| Кнопка недоступна | client rights + server rights |
| Запись не удаляется | record right + schema license |
| Раздел не открывается | schema read right + license |
| Пользователь не может выполнить CTI-операцию | operation right + operation license |
| Portal user management | operation right + LicManager action |

## Практические правила

- Не смешивайте текст ошибки "нет прав" и "нет лицензии".
- Проверяйте лицензию на сервере, даже если кнопка скрыта на клиенте.
- Назначение лицензии выполняйте через `SystemUserConnection`, но только после проверки текущего пользователя.
- Для схем используйте битовые флаги `SchemaOperationRightLevels`.
- Логи должны содержать license/operation code, но не чувствительные данные.

## Связанные документы

- [Security overview](security-overview.md)
- [Security schema and record rights](security-schema-record-rights.md)
- [Security SSP portal](security-ssp-portal.md)
- [Services response errors](services-response-errors.md)
