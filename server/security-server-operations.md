# Security Server Operations

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: DBSecurityEngine, SysAdminOperation, CheckCanExecuteOperation, SecurityException -->

> Серверные проверки операций через `DBSecurityEngine`.

## CheckCanExecuteOperation

`CheckCanExecuteOperation` выбрасывает исключение, если у текущего пользователя нет права на операцию.

```csharp
UserConnection.DBSecurityEngine.CheckCanExecuteOperation("CanManageAdministration");
```

Используйте этот вариант в public service methods, EventListener и Process/ScriptTask, если выполнение без права недопустимо.

## GetCanExecuteOperation

`GetCanExecuteOperation` возвращает `bool` и позволяет описать альтернативную логику.

```csharp
if (UserConnection.DBSecurityEngine.GetCanExecuteOperation("CanViewConfiguration") ||
        UserConnection.DBSecurityEngine.GetCanExecuteOperation("CanManageSysSettings")) {
    return true;
}
UserConnection.DBSecurityEngine.CheckCanExecuteOperation("CanManageAdministration");
```

Такой паттерн используется, когда несколько операций дают доступ к одному read-сценарию.

## CheckCanExecuteAnyOperation

Для OR-проверки нескольких операций может использоваться `CheckCanExecuteAnyOperation`.

Применяйте его, когда пользователь должен иметь хотя бы одно из прав.

## SysAdminOperation

`SysAdminOperation` — сущность администрируемых операций. В `SysAdminOperationSchema.Base.cs` generated EventsProcess разделяет:

- изменение операции — требует `CanManageAdministration`;
- чтение операции — допускает `CanViewConfiguration` или `CanManageSysSettings`, иначе требует `CanManageAdministration`.

## SecurityException

`SecurityException` используется как доменный сигнал отказа в доступе.

```csharp
if (!canAdministrate) {
    throw new SecurityException(
        string.Format(new LocalizableString("BPMSoft.Core",
            "DBSecurityEngine.Exception.CurrentUserCannotExecuteAdminOperation"),
            "CanAdministratePortalUsers"));
}
```

В публичном API можно вернуть структурированный ответ, но серверная проверка всё равно должна быть выполнена.

## SystemOperationRestrictedException

Для специальных ограниченных сессий проверяется `IsSystemOperationsRestricted`.

```csharp
if (userConnection.IsSystemOperationsRestricted) {
    throw new SystemOperationRestrictedException();
}
```

Пример: `ExternalAccessListener` запрещает сохранение и удаление при restricted system operations.

## Практические правила

- Проверяйте операцию до изменения данных.
- Не заменяйте server-side check клиентской видимостью кнопки.
- Для OR-сценариев используйте `GetCanExecuteOperation` или `CheckCanExecuteAnyOperation`.
- Для доменных ограничений добавляйте отдельную проверку после operation right.
- Логируйте operation code и business id при отказе в фоновом сценарии.

## Связанные документы

- [Security overview](security-overview.md)
- [Security UserConnection Context](security-userconnection-context.md)
- [Security troubleshooting](security-troubleshooting.md)
- [EventListener validation and safety](event-listeners-validation-and-safety.md)
