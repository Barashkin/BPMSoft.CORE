# Process Designer Sandbox Messages

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: ProcessDesigner, sandbox, PTP, modules -->

> Sandbox messages связывают canvas, property pages, mini edit pages,
> source code editor и mapping modules. Большинство сообщений PTP, потому что
> designer работает с несколькими вложенными modules.

## Properties module

`ProcessSchemaElementPropertiesEdit.ProcessDesigner.js` регистрирует:

| Message | Mode | Direction | Роль |
| ------- | ---- | --------- | ---- |
| `ReRenderPropertiesPage` | PTP | subscribe | перерендерить property page в указанном контейнере |

Модуль отключает history state и живёт внутри designer shell.

## Flow element messages

`ProcessFlowElementPropertiesPage.ProcessDesigner.js`:

| Message | Direction | Роль |
| ------- | --------- | ---- |
| `GetParametersInfo` | subscribe | вернуть parameter values |
| `SetParametersInfo` | subscribe | применить parameter values |
| `SaveParameterInfo` | subscribe | сохранить parameter info |
| `DiscardParameterInfoChanges` | subscribe | отменить изменения параметра |
| `GetParameterEditInfo` | subscribe | данные для parameter edit page |
| `GetItemEditInfo` | subscribe | данные для item mini page |
| `DiscardItemInfoChanges` | subscribe | отменить item edit |
| `SaveItemInfo` | subscribe | сохранить item edit |
| `SaveParameter` | publish | сообщить о сохранении параметра |

## User task messages

`RootUserTaskPropertiesPage.ProcessDesigner.js`:

| Message | Direction | Роль |
| ------- | --------- | ---- |
| `GetProcessElementInfo` | subscribe | вернуть текущий process element |
| `SaveProcessElement` | publish | сохранить process element |
| `ValidateProcessElement` | publish | запустить validation |
| `GetValue` | publish | запросить value из source code edit |
| `GetSourceCodeData` | subscribe | подготовить data для source editor |
| `SourceCodeChanged` | subscribe | принять изменённый source code |

## Schema properties messages

`ProcessSchemaPropertiesPage.ProcessDesigner.js` использует:

- `GetSourceCodeData`;
- `SourceCodeChanged`;
- `GetValue`;
- `SaveItem`;
- `DiscardItem`.

Так schema page редактирует process methods, compiled methods и вложенные
items без history state.

## Save version message box

`SaveSchemaVersionMessageBox.ProcessDesigner.js` связывает modal dialog с
родителем через sandbox message `OnSaveVersionClick`.

Это отдельный паттерн: modal page не сохраняет версию напрямую, а публикует
намерение родителю.

## Module ids

У вложенных modules используются module ids, полученные через `getModuleId`.
Например, `RootUserTaskPropertiesPage` подписывается на source editor messages
только для module id `AfterActivitySaveScriptBody`.

Если подписка не срабатывает:

- проверьте module id;
- проверьте mode `PTP`;
- проверьте direction;
- убедитесь, что module уже создан;
- проверьте suffix контейнера.

## Практические правила

- Для вложенных редакторов используйте PTP messages.
- Не публикуйте широкие BROADCAST messages для state конкретной property page.
- Перед добавлением нового message проверьте, можно ли расширить существующий
  contract.
- В troubleshooting фиксируйте не только message name, но и module id.
