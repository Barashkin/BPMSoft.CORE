# Knowledge Base And Case Terms Troubleshooting

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: KnowledgeBase, SSP, CaseTerm, troubleshooting -->

> Диагностика этого блока зависит от контура: desktop KB, portal KB, Global
> Search row, DCM case settings или календарный расчет сроков.

## Статья KB не отображается

Проверить:

1. Запись есть в `KnowledgeBase`.
2. Заполнены `Name` и `Type`.
3. У пользователя есть права чтения на `KnowledgeBase`.
4. Секция `KnowledgeBaseSectionV2` зарегистрирована в `SysModule`.
5. Если это портал, schema опубликована через SSP access list.
6. Если используется Global Search, сущность доступна для индексации.

## HTML статьи не работает

Проверить:

- feature `Playbook`;
- `HtmlEditModeEnabled`;
- `Notes`;
- `NotHtmlNote`;
- коллекцию `knowBaseImagesCollection`;
- вложенные изображения и `KnowledgeBaseFile`.

Если HTML-режим отключен, карточка может работать в plain text сценарии.

## Likes не считаются

Проверить:

- записи в `Like` с lookup на `KnowledgeBase`;
- текущий `CURRENT_USER_CONTACT`;
- batch-запросы `pushLikeItCountSelect` и `pushLikeItSelect`;
- delete/insert в `setLikeIt`;
- права на создание и удаление `Like`.

## Файлы KB не видны на портале

Проверить:

1. В desktop карточке используется `KnowledgeBaseFile`.
2. На портале обычный `Files` detail заменен на `FileDetailReadOnly`.
3. Detail filter: `KnowledgeBase.Id -> KnowledgeBaseFile.KnowledgeBase`.
4. У portal user есть права чтения файла.
5. `PortalColumnAccessList` не скрывает нужные поля.

## Portal KB позволяет лишние действия

Проверить `PortalKnowledgeBaseSection`:

- удалены ли `DataGridActiveRowDeleteAction`;
- удалены ли copy actions;
- `AddRecordButtonEnabled = false`;
- action menu не содержит export/delete;
- карточка скрывает actions button.

## Portal KB search не переходит в секцию

Проверить:

- `KnowledgeBaseSearchModule`;
- `minSearchCharsCount = 3`;
- `searchDelay = 350`;
- `BPMSoft.configuration.ModuleStructure.KnowledgeBase`;
- `Storage.Filters[sectionSchema].CustomFilters`;
- sandbox `PushHistoryState`.

Если `sectionSchema` не найден в module structure, переход не сформирует
корректный route.

## Case search row показывает пустые поля

`CaseSearchRowSchema.GlobalSearch.js` ожидает поля `Subject`, `ServiceItem`,
`Client`, `RegisteredOn`, `Status`, `Owner`. Если в текущей поставке нет
полноценного пакета `Case`, строка может существовать без рабочей сущности.

Проверить:

- установлен ли пакет с `Case`;
- есть ли поля в индексе Global Search;
- `Client` собирается из `Contact` / `Account`;
- права чтения на `Case` и связанные lookup.

## DCM case settings не обновляются

Проверить:

- `SectionWizardCasesSettings`;
- сообщения `SectionDcmSettingsInitialized` и `SectionDcmLibraryInitialized`;
- событие `ReloadSectionWizardCaseSettings` в `ServerChannel`;
- совпадение `dcmSettingsId`;
- публикацию `ReloadCaseSettings`;
- публикацию `ReloadDcmLibGridData`.

## Срок response/resolve не рассчитывается

Проверить:

1. Есть default rule в `DeadlineCalcSchemas`.
2. У strategy заполнен `Handler`.
3. `Type.GetType(className)` находит class type.
4. `ClassFactory.ForceGet` может создать strategy.
5. Strategy возвращает `ResponseTerm` или `ResolveTerm`.
6. `TimeTerm.Type` не default.
7. `TimeTerm.Value > 0`.

Если strategy выбрасывает исключение, `CaseTermIntervalSelector` пропускает ее
и переходит к следующей.

## Срок рассчитался не так

Смотреть `TermCalculationLogStore`:

- `CalculationStrategyRules`;
- `SelectedStrategy`;
- `CalculationParameters`;
- `ActiveTimeIntervals`;
- `UsedTimeTermIntervals`;
- `CalculationIntervals`;
- `CalendarData`;
- `CalendarTimeZoneInfo`;
- `UserTimeZoneInfo`;
- `TermTimeRemains`.

Частая причина расхождений — timezone conversion между user timezone и
calendar timezone.
