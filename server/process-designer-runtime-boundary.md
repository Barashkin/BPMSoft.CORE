# Process Designer Runtime Boundary

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: ProcessDesigner, ProcessSchema, runtime, metadata -->

> Process Designer редактирует metadata. Runtime Process Dive объясняет, как
> эта metadata исполняется. Смешивать эти два слоя в диагностике нельзя.

## UI слой

UI designer работает с:

- process schema metadata;
- flow element metadata;
- parameters и mappings;
- source code blocks на schema/user task pages;
- validation results;
- service calls к schema manager;
- property page modules.

Основные файлы:

- `ProcessModuleUtilities.NUI.js`;
- `ProcessSchemaElementPropertiesEdit.ProcessDesigner.js`;
- `BaseProcessSchemaElementPropertiesPage.ProcessDesigner.js`;
- `ProcessFlowElementPropertiesPage.ProcessDesigner.js`;
- `ProcessSchemaPropertiesPage.ProcessDesigner.js`;
- `RootUserTaskPropertiesPage.ProcessDesigner.js`.

## Runtime слой

Runtime работает с:

- generated `ProcessSchema`;
- generated `Process`;
- `ProcessModel`;
- `ProcessUserTask.InternalExecute`;
- `ProcessExecutingContext`;
- `SysProcessLog`;
- Quartz/job запуском.

См. [process-overview.md](process-overview.md),
[process-runtime-schema.md](process-runtime-schema.md),
[process-user-tasks.md](process-user-tasks.md).

## Связь через generated metadata

Некоторые `*.ProcessDesigner.cs` файлы одновременно важны для дизайнера и
runtime. Например CRUD user tasks имеют:

- design-time attributes (`DesignModeGroup`, `DesignModeProperty`);
- editors вроде `processschemaparametervalueedit`;
- runtime class `ProcessUserTask`.

Для Process Designer UI документации берите из таких файлов только design-time
metadata и editor contracts. Runtime execute logic оставляйте Process Dive.

## Типичные ошибки границы

| Симптом | Где смотреть сначала |
| ------- | -------------------- |
| Не открывается canvas | `process-designer-entry-shell.md` |
| Не сохраняется поле на правой панели | property page / sandbox |
| Неверный parameter mapping | mapping modules / validation |
| Процесс сохранился, но не запускается | Process runtime docs |
| Процесс запускается, но падает task | `process-user-tasks.md` |
| Нет записи в runtime log | `process-listeners-and-logs.md` |

## Feature boundary

`UseProcessDiagramComponent` переключает новый/старый diagram component.
Это UI feature, а не runtime feature.

Runtime запуск процесса может работать даже если designer UI не открывается.
И наоборот, успешное сохранение схемы не гарантирует успешное выполнение.

## Практические правила

- В UI баге сначала проверяйте property page state и service response.
- В runtime баге сначала проверяйте process log и generated task code.
- Не исправляйте runtime `InternalExecute`, если проблема только в списке
  параметров на property page.
- Не добавляйте UI fallback для runtime ошибки без проверки process logs.
