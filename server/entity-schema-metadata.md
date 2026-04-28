# Entity Schema Metadata

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: EntitySchema, InitializeProperties, UId, RealUId, ExtendParent, IsDBView -->

> Метаданные схемы: идентичность, наследование, DB view/table, flags прав и деактивации записей.

## InitializeProperties

Главный блок идентичности схемы находится в `InitializeProperties`.

```csharp
protected override void InitializeProperties() {
    base.InitializeProperties();
    UId = new Guid("...");
    RealUId = new Guid("...");
    Name = "Metric";
    ParentSchemaUId = new Guid("...");
    ExtendParent = false;
    CreatedInPackageId = new Guid("...");
    IsDBView = false;
    UseDenyRecordRights = false;
    UseRecordDeactivation = true;
}
```

## Основные свойства

| Свойство | Смысл |
| --- | --- |
| `UId` | идентификатор текущей schema metadata |
| `RealUId` | идентификатор реальной схемы при расширениях |
| `Name` | техническое имя схемы |
| `ParentSchemaUId` | родительская схема |
| `ExtendParent` | схема расширяет родителя, а не создаёт отдельную таблицу |
| `CreatedInPackageId` | пакет, где создан metadata layer |
| `IsDBView` | схема является представлением |
| `UseDenyRecordRights` | включает модель запрета прав на запись |
| `UseRecordDeactivation` | включает деактивацию записей через inactive column |

## Virtual base schemas

Базовые схемы помечаются `[IsVirtual]`.

```csharp
[IsVirtual]
public class BaseEntitySchema : EntitySchema
{
}
```

Такие схемы задают общую модель, но не являются прикладной таблицей сами по себе.

## Table vs DB view

Обычная таблица:

```csharp
IsDBView = false;
```

Представление:

```csharp
IsDBView = true;
```

Пример view-схемы: `VwWebhookV2Schema.Webhook.cs`. View часто наследуется от другой view/base schema и может переопределять только отдельные колонки.

## Record deactivation

`UseRecordDeactivation = true` означает, что для схемы используется деактивация записей. В `MetricSchema.Apdex.cs` дополнительно есть advanced-колонка `RecordInactive`.

```csharp
UseRecordDeactivation = true;
```

Это не то же самое, что физическое удаление. При анализе удаления проверяйте также EventListener и бизнес-логику.

## Rights flags

`UseDenyRecordRights` встречается почти во всех schema metadata. Сам флаг не заменяет проверку прав в сервисах или listener'ах, но влияет на модель record rights.

Для практических проверок прав см. [Services UserConnection And Security](services-userconnection-security.md).

## Связанные документы

- [Entity Schema Overview](entity-schema-overview.md)
- [Entity Schema inheritance](entity-schema-inheritance.md)
- [Entity Schema views, indexes and rights](entity-schema-views-indexes-rights.md)
- [EventListener validation and safety](event-listeners-validation-and-safety.md)
