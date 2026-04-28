# File Import Templates Duplicates Tags

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: FileImportTemplate, duplicates, tags, mapping -->

> Шаблоны импорта, управление дублями и tags в FileImport wizard.

## Import templates

`FileImportTemplate` хранит переиспользуемые настройки маппинга. `FileImportTemplateService` сохраняет mapping как JSON в binary `TemplateData`.

```csharp
return Column.Parameter(Encoding.UTF8.GetBytes(JsonConvert.SerializeObject(columns)));
```

## Applying template

При применении template service:

1. Получает `TemplateData`.
2. Десериализует `IEnumerable<ImportColumn>`.
3. Сравнивает columns по `Source`.
4. Переносит destinations в текущую сессию.
5. Сохраняет applied template id в `SessionData`.

Если template id пустой, importer вызывает `RefreshColumnMapping`.

## Client template UI

Клиентские компоненты:

- `FileImportTemplateMixin`;
- `SaveImportTemplateModalBox`;
- `NewImportTemplateModalBox`;
- `FileImportTemplateLookupSection`.

Они используются на шагах wizard, где пользователь выбирает или сохраняет mapping.

## Duplicate management

`FileImportDuplicateManagementPage` — шаг выбора поведения при совпадении key columns. Он связан с template mixin и ведёт к `FileImportProcessingPage`.

Дубли в runtime обрабатываются через primary entity finder: импорт либо обновляет найденную запись, либо создаёт новую.

## Tags mapping

Tags flow включает:

- `FileImportTagsMappingPage`;
- `ImportTagModule`;
- `ImportTagModuleSchema`;
- `ValidateTagsMappingParameters`;
- `FileImportTagManager`.

Индивидуальные tags создаются в `FileImportEntitiesChunkProcessor` до сохранения сущностей.

## Result counts

Result page показывает:

- сколько строк импортировано;
- сколько строк не импортировано;
- сколько новых tags создано;
- успешность tags import.

## Практические правила

- Template должен применяться только к совместимому файлу: source columns должны совпадать.
- Не применяйте destinations template к колонкам с другим смыслом только по позиции.
- Duplicate strategy должна опираться на key columns.
- Tags валидируйте до запуска processing.
- Для проблем tags смотрите и result page, и server-side tag events.

## Связанные документы

- [File Import overview](file-import-overview.md)
- [File import mapping validation](file-import-mapping-validation.md)
- [File import wizard UI](file-import-wizard-ui.md)
- [Entity schema folders tags files](entity-schema-folders-tags-files.md)
