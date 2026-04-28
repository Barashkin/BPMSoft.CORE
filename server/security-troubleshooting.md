# Security Troubleshooting

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: security troubleshooting, rights, license, SecurityException, RightUtilities -->

> Практический чеклист диагностики отказов доступа, прав и лицензий.

## Нет права на операцию

Проверки:

- operation code написан без ошибки;
- пользователь входит в нужную роль;
- используется правильный `UserConnection`;
- проверка выполняется до изменения данных;
- для OR-сценария проверяются все допустимые операции.

Ищите вызовы:

```csharp
CheckCanExecuteOperation("OperationCode");
GetCanExecuteOperation("OperationCode");
```

## Кнопка видна, но действие запрещено

Вероятная причина: client rights и server rights рассинхронизированы.

Проверки:

- есть ли server-side check в service method;
- как клиент получает флаг видимости;
- не закешировано ли старое состояние прав;
- не используется ли действие для нескольких типов записей.

## Кнопка скрыта, хотя право есть

Проверки:

- `RightUtilities` callback отработал;
- attribute с правом обновился;
- `visible`/`enabled` binding указывает правильный attribute;
- section/page не переопределяет доступ отдельным domain condition;
- в SSP не применяется фильтр portal-only.

## Нет права на запись

Проверки:

- есть schema right;
- есть record right;
- запись не попадает под deny rule;
- `UseAdminRights` не маскирует ошибку в тесте;
- массовая операция проверяет каждую запись.

## Нет лицензии

Проверки:

- `LicHelper.GetSchemaLicRights` возвращает нужный флаг;
- `LicHelper.GetHasOperationLicense` возвращает `true`;
- лицензия назначена именно нужному пользователю;
- пользователь активен;
- сообщение различает `LicenceNotFound` и `RightLevelWarningMessage`.

## Portal user не изменяется

Проверки:

- есть `CanAdministratePortalUsers` или разрешённая альтернатива;
- target user имеет `ConnectionType = 1`;
- endpoint не пытается изменить обычного пользователя;
- `SystemUserConnection` используется только после checks;
- JSON response содержит `IsSecurityException`.

## SSP не видит сущность или колонку

Проверки:

- схема доступна на SSP;
- есть лицензия;
- колонка есть в allowed portal columns;
- portal column cache не устарел;
- текущий пользователь действительно SSP.

## External access падает

Проверки:

- сессия не находится в `IsSystemOperationsRestricted`;
- grantor активен;
- если grantor не текущий пользователь, есть `CanDelegateExternalAccess`;
- заполнены обязательные sys settings;
- клиент получил сообщение через `MsgChannelManager`.

## Практический минимум для нового endpoint

1. Определите operation code.
2. Проверьте operation right в начале метода.
3. Проверьте domain condition.
4. Проверьте schema/record/license, если endpoint работает с записью.
5. Выполните действие.
6. Верните понятный response shape.
7. Добавьте client handling для отказа.

## Связанные документы

- [Security overview](security-overview.md)
- [Security server operations](security-server-operations.md)
- [Security schema and record rights](security-schema-record-rights.md)
- [Security licenses](security-licenses.md)
- [Services troubleshooting](services-troubleshooting.md)
