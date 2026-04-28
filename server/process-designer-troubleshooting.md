# Process Designer UI Troubleshooting

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: ProcessDesigner, troubleshooting, ProcessLibrary, property pages -->

> Диагностика проблем UI-дизайнера процессов. Runtime ошибки исполнения
> процесса смотрите в [process-troubleshooting.md](process-troubleshooting.md).

## Дизайнер не открывается

Проверьте:

1. Вызов идёт через `ProcessModuleUtilities.showProcessSchemaDesigner`.
2. `schemaUId` не пустой для существующего процесса.
3. Feature `UseProcessDiagramComponent` выбирает ожидаемый тип:
   `process` или `processOld`.
4. Browser popup не заблокировал `window.open`.
5. Пользователь имеет право `CanManageProcessDesign`.

Источник: `ProcessModuleUtilities.NUI.js`,
`VwProcessLibSection.ProcessLibrary.js`.

## Открылся старый дизайнер

Проверьте feature `UseProcessDiagramComponent`.

Если feature выключена, utility использует `processOld`. Для process logs
аналогично используется `processLogOld`.

## Кнопки библиотеки процессов недоступны

Проверьте:

- operation right `CanManageProcessDesign`;
- demo mode через SysSetting `ShowDemoLinks`;
- foreign lock по schema UId;
- active version state;
- enabled flag процесса.

## Property page не перерисовывается

Проверьте:

- message `ReRenderPropertiesPage`;
- mode `PTP`;
- container id;
- suffix `-prSchElPropCt`;
- что `ProcessSchemaElementPropertiesEdit` уже инициализирован.

## Элемент не сохраняется

Проверьте validation:

- `nameValidator`;
- `duplicateNameValidator`;
- `customValidator`;
- mapping validator;
- `processElement.internalValidate`;
- содержимое `processElement.validationResults`.

Частая причина: code name не проходит regex
`^[a-zA-Z]{1}[a-zA-Z0-9_]*$`.

## Mapping не сохраняется

Проверьте:

- `GetParametersInfo`;
- `SetParametersInfo`;
- `SaveParameterInfo`;
- `SaveParameter`;
- `ActiveParameterEditUId`;
- mapping columns типа `BPMSoft.DataValueType.MAPPING`;
- validation на base property page.

## Source code editor пустой

Проверьте:

- module config `SourceCodeEditPage`;
- `Tag` (`methodsBody`, `compiledMethodsBody`, `AfterActivitySaveScript`);
- message `GetSourceCodeData`;
- module id вложенного editor;
- direction/mode сообщений.

## User task schema не появляется в списке

Проверьте:

- `ProcessUserTaskSchemaManager`;
- `schemaUId`;
- ESQ по `SysProcessUserTask`;
- `ExcludedSchemas` в filter;
- результат `ProcessModuleUtilities.getSchemasByFilter`.

## AfterActivitySaveScript не виден

Проверьте:

- element является `ProcessUserTaskSchema` или `ProcessSchemaUserTask`;
- user task schema загрузилась;
- `enableCustomEventHandlers = true`;
- вызвался `initIsAfterActivitySaveScriptEditVisible`.

## Ошибка удаления элемента

Для DCM и общих designer utilities проверьте:

- `ProcessSchemaDesignerUtilities.validateElementRemoval`;
- `schema.canRemoveElements`;
- message box `InvalidRemoveElement`;
- validation info на связанных элементах.

## Процесс сохранился, но не выполняется

Это уже runtime слой:

- [process-starting.md](process-starting.md);
- [process-user-tasks.md](process-user-tasks.md);
- [process-listeners-and-logs.md](process-listeners-and-logs.md);
- [process-troubleshooting.md](process-troubleshooting.md).

Не исправляйте property page, пока не подтверждено, что metadata сохранилась
неверно.
