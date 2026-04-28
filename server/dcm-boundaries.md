# DCM Boundaries

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: DCM, boundaries, ProcessDesigner, Case, Process runtime -->

> DCM пересекается с Process Designer, Process runtime и словами `Case` в UI.
> Этот документ фиксирует границы, чтобы не смешивать разные подсистемы.

## DCM vs BPM Process Designer

DCM:

- stage-based designer;
- `DcmSchema`;
- `DcmSchemaStage`;
- `DcmSchemaElement`;
- `DcmSchemaDesignerViewModel`;
- `DcmSchemaManager`;
- настройки через `SysDcmSettings`.

BPM Process Designer:

- process flow elements;
- sequence flows;
- gateways/events/tasks;
- `ProcessSchema`;
- `ProcessFlowElementPropertiesPage`;
- BPM property pages.

Общие base-паттерны описаны в
[process-designer-ui-overview.md](process-designer-ui-overview.md), а DCM
детали — в этом dive.

## DCM vs Process runtime

DCM metadata запускается через:

```text
ProcessEngine.RunDcmProcess(entityRecordId, dcmSchema)
```

Но DCM docs не описывает:

- generated `Process`;
- `ProcessModel`;
- `InternalExecute`;
- `SysProcessLog`;
- Quartz process jobs.

Для runtime используйте [process-overview.md](process-overview.md).

## DCM case settings vs service Case

`SectionWizardCasesSettings` и `VwDcmLibSection` используют слово `Case` в
значении DCM case schema. Это не service desk case lifecycle.

Base содержит UI/search обвязку для `CaseSearchRowSchema`, но не содержит
полной ITSM-сущности `Case`, SLA и routing lifecycle.

См. [knowledge-base-search-case-dcm.md](knowledge-base-search-case-dcm.md).

## DCM vs Knowledge Base / Case Terms

Knowledge Base / Case Terms Dive описывает:

- KB entity и UI;
- portal KB;
- search rows;
- CaseTerm calendar;
- DCM case settings как границу.

DCM Dive описывает:

- DCM metadata;
- DCM designer;
- DCM settings;
- DCM library;
- DCM service launch.

## DCM vs Section Wizard

Section wizard — это UI-хост для настройки секции. DCM использует wizard step
`SectionWizardCasesSettings`, но не вся логика wizard относится к DCM.

В DCM важно только:

- инициализация `SectionDcmSettings`;
- инициализация `VwDcmLibSection`;
- validation/save DCM settings;
- reload через ServerChannel.

## DCM vs Global Search

DCM не является поисковым контуром. `CaseSearchRowSchema` и DCM settings могут
встречаться рядом в документации по case/search, но DCM-схемы не описывают
индексацию или search providers.

## Практические правила

- Если проблема в стадиях записи — это DCM.
- Если проблема в выполнении user task — это Process runtime.
- Если проблема в карточке обращения/SLA — это внешний service case пакет.
- Если проблема в wizard save/settings — это DCM library/settings контур.
