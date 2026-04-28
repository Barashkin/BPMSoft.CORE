# Security Client Rights

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: RightUtilities, client rights, BaseSectionV2, schema rights, record rights -->

> Клиентские проверки прав управляют интерфейсом, но не заменяют серверную авторизацию.

## RightUtilities

`RightUtilities` — клиентский модуль для проверки операций, прав на схемы и записи.

```javascript
RightUtilities.checkCanExecuteOperation({
    operation: "CanManageAdministration"
}, function(result) {
    this.set("CanManageAdministration", result);
}, this);
```

В этом workspace `RightUtilities` найден как клиентский модуль, а не C# API.

## Schema right levels

```javascript
RightUtilities.getSchemaOperationRightLevel("Contact", function(rightLevel) {
    var canRead = (rightLevel & RightUtilities.SchemaOperationRightLevels.CanRead) !== 0;
    var canEdit = (rightLevel & RightUtilities.SchemaOperationRightLevels.CanEdit) !== 0;
});
```

Флаги:

- `CanRead`;
- `CanAppend`;
- `CanEdit`;
- `CanDelete`.

## Record right levels

```javascript
RightUtilities.getSchemaRecordRightLevel("Contact", recordId, function(rightLevel) {
    var canRead = (rightLevel & RightUtilities.RecordOperationRightLevels.CanRead) !== 0;
});
```

Record rights нужны для карточек, деталей, активных строк и действий над выбранными записями.

## Section-level checks

Секции могут переопределять `checkSchemaOperationAvailability`.

```javascript
checkSchemaOperationAvailability: function(callback, scope) {
    this.checkCanAdministratePortalUsers(callback, scope);
}
```

Пример: `UsersSectionV2.SSP.js` меняет видимость, доступные views и метод удаления в зависимости от `CanManageUsers`, `CanAdministratePortalUsers`, `CanViewConfiguration`.

## UI state

Типовой клиентский паттерн:

1. Проверить право асинхронно.
2. Сохранить результат в attribute.
3. Привязать `visible` или `enabled` в `diff`.
4. Повторить проверку на сервере в action endpoint.

## Практические правила

- Не доверяйте только скрытой кнопке.
- Проверяйте права до открытия destructive dialog.
- Для PTP sandbox actions передавайте состояние прав явно или перечитывайте его в получателе.
- При batch action проверяйте права на каждую запись на сервере.
- Если response от сервера вернул отказ, обновляйте UI state, а не только показывайте alert.

## Связанные документы

- [Security overview](security-overview.md)
- [Security server operations](security-server-operations.md)
- [Utilities](../client/utilities.md)
- [Client troubleshooting](../client/client-troubleshooting.md)
