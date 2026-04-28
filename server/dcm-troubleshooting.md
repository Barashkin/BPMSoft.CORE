# DCM Dynamic Case Troubleshooting

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: DCM, troubleshooting, DcmDesigner, DcmLibrary -->

> Диагностика DCM designer, библиотеки, настроек секций, mappings и запуска
> DCM-процесса.

## DCM designer не открывается

Проверьте:

1. Hash имеет формат `{designer}/{schemaId}/{dcmSettingsId}/{packageUId}`.
2. `schemaId = add` используется только для создания новой схемы.
3. `DcmDesigner` создаёт `BPMSoft.DcmSchemaDesigner`.
4. `DcmSchemaManager` инициализирован.
5. `VwSysDcmLib` содержит нужную DCM-схему.

Источник: `DcmDesigner.DcmDesigner.js`.

## Стадия не отображается или не сохраняется

Проверьте:

- `DcmSchema.stages`;
- `DcmSchemaStage.stageRecordId`;
- `DcmSchemaStage.parentStageUId`;
- `DcmSchemaStage.getSerializableProperties`;
- feature `DcmStagesPermissions`, если проблема с permissions;
- `StageColumnUId` в `SysDcmSettings`.

## Элемент DCM не редактируется

Проверьте:

- `DcmSchemaElement.processFlowElement`;
- `DcmElementSchemaManager.createInstance`;
- `managerItemUId`;
- `getEditPageSchemaName` вложенного flow element;
- `BaseDcmSchemaElementPropertiesPage`.

## Transition не применился

Проверьте:

- `DcmSchema.transitions`;
- `DcmSchemaElement.getTransition`;
- `DcmSchemaElement.setTransition`;
- `DcmSchemaElementTransitionFactory`;
- `ExecuteAfterElement` и `sourceElementUId`;
- `DcmSchema` changed event `transitionChanged`.

## Mapping не сохраняется

Проверьте:

- используется ли `DcmMappingModule`, а не BPM mapping module;
- `mappingPageName = "DcmMappingPage"`;
- `mappingSelectionPageName = "DcmParameterSelectionPage"`;
- DCM element parameters;
- `defValueForDcm` для default values.

## DCM-схема не видна в библиотеке

Проверьте:

- view `VwSysDcmLib`;
- `DcmSchemaManager.entitySchemaName`;
- workspace/package;
- active version flags;
- `SysDcmSchemaInSettings`;
- filters по `SysDcmSettings`.

## Нельзя включить DCM-схему

Проверьте:

- `DcmSchemaManager.setEnabled`;
- validation filters;
- совпадение filter column и stage column;
- уникальность filters активных схем;
- confirmation при отключении последней активной схемы.

## Wizard завис на mask

Проверьте, что получены оба сообщения:

- `SectionDcmSettingsInitialized`;
- `SectionDcmLibraryInitialized`.

Затем проверьте `HideBodyMask` и module initialization в
`SectionWizardCasesSettings`.

## Настройки секции не сохраняются

Проверьте:

- PTP `ValidateSectionDcmSettings`;
- PTP `SaveSectionDcmSettings`;
- `OnSectionDcmSettingsSaved`;
- `SysDcmSettingsItem`;
- `StageColumn`;
- `Filters`;
- `SysDcmSchemaInSettingsManager`.

## Wizard не обновился после сохранения дизайнера

Проверьте ServerChannel event:

```text
ReloadSectionWizardCaseSettings
```

И совпадение `dcmSettingsId` с текущим settings item.

## DCM не запускается для записи

Проверьте:

- `DcmService.RunDcmProcess`;
- `dcmSchemaUId`;
- `entityRecordId`;
- `UserConnection.DcmSchemaManager.GetInstanceByUId`;
- `UserConnection.ProcessEngine.RunDcmProcess`.

Если запуск дошёл до runtime engine, дальнейшую ошибку смотрите в Process docs:
[process-troubleshooting.md](process-troubleshooting.md).

## Пользователь не видит нужную стадию

Проверьте:

- `DcmStagesPermissions`;
- `DcmSchemaStage.usePermissions`;
- `DcmSchemaStage.permissions`;
- `DcmService.GetAllowedStagesForCurrentUser`;
- server-side `DcmPermissions`.

## Это не service case

Если проблема про SLA, service item, routing или карточку обращения, ищите пакет
service cases. В Base DCM case settings не равны ITSM case lifecycle.
