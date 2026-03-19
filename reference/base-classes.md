# Справочник базовых классов и иерархий

<!-- Версия: 1.0 | Обновлено: 2026-03-19 | Платформа: BPMSoft 1.9 -->
<!-- Теги: базовые классы, иерархия, наследование, namespace, EntitySchema, BasePageV2 -->

## Серверные базовые классы (C#)

### Иерархия схем сущностей

```
BPMSoft.Core.Entities.EntitySchema
    └── BaseEntitySchema [IsVirtual]
            │
            ├── BaseLookupSchema
            │       │   Колонки: + Name, Description
            │       │
            │       ├── BaseCodeLookupSchema
            │       │       │   Колонки: + Code
            │       │       │
            │       │       └── BaseHierarchicalLookupSchema
            │       │               Колонки: + Parent (self-ref)
            │       │
            │       ├── SysAdminUnitSchema
            │       ├── SysSettingsSchema
            │       └── множество справочных сущностей
            │
            ├── BaseFileSchema
            │       Колонки: + Name, Data, Type, Version, Size
            │       └── ContactFileSchema, AccountFileSchema, ...
            │
            ├── BaseItemInFolderSchema
            │       Колонки: + Folder (Lookup)
            │       └── ContactInFolderSchema, AccountInFolderSchema, ...
            │
            ├── Contact_Base_BPMSoftSchema
            ├── Account_Base_BPMSoftSchema
            ├── Activity_Base_BPMSoftSchema
            └── ... (все остальные сущности)
```

### Колонки по уровням иерархии

| Уровень | Колонки |
|---------|---------|
| **BaseEntitySchema** | Id, CreatedOn, CreatedBy, ModifiedOn, ModifiedBy, ProcessListeners |
| **BaseLookupSchema** | + Name (PrimaryDisplay), Description |
| **BaseCodeLookupSchema** | + Code |
| **BaseHierarchicalLookupSchema** | + Parent (self-reference) |
| **BaseFileSchema** | + Name, Data, Type, Version, Size |

### Иерархия Entity (экземпляров)

```
BPMSoft.Core.Entities.Entity
    └── BaseEntity
            ├── BaseLookup
            ├── Contact
            ├── Account
            ├── Activity
            └── ...
```

## Серверные EventListener'ы

```
IAppEventListener (interface)
    └── AppEventListenerBase
            └── NotificationEventListener
            └── ...

BaseEntityEventListener (BPMSoft.Core.Entities.Events)
    ├── BaseEntityOwnerEventListener
    ├── BaseSysSettingsEventListener<T>
    ├── LookupEventListener
    ├── ContactEventListener
    ├── FileSecurityExcludedUriEventListener
    └── ...
```

### Регистрация Entity EventListener

```csharp
[EntityEventListener(SchemaName = "Contact")]
public class ContactEventListener : BaseEntityEventListener { }
```

### Интерфейс App EventListener

```csharp
public interface IAppEventListener
{
    void OnAppStart(AppEventContext context);
    void OnAppEnd(AppEventContext context);
    void OnSessionStart(AppEventContext context);
    void OnSessionEnd(AppEventContext context);
}
```

## Серверные сервисы

```
[ServiceContract] WCF Services
    ├── BaseService (базовый класс, предоставляет UserConnection)
    │       ├── AnalyticsService
    │       └── ...
    └── Standalone services (UserConnection из HttpContext)
            ├── AdministrationService
            ├── CalendarService
            └── ...
```

## Серверные процессы

```
BPMSoft.Core.Process.Process
    └── конкретные процессы (MyProcess, SetRunningStatusDelivery, ...)

BPMSoft.Core.Process.ProcessUserTask
    ├── AddDataUserTask
    ├── ReadDataUserTask
    ├── ChangeDataUserTask
    ├── DeleteDataUserTask
    ├── ActivityUserTask
    ├── SendEmailUserTask
    ├── CallUserTask
    └── ...
```

## Клиентские базовые классы (JavaScript)

### Иерархия страниц

```
BaseSchemaViewModel
    └── BaseEntityPage
            └── BasePageV2 (NUI)
                    ├── BaseSectionPage (NUI)
                    │       └── [AccountPageV2, ContactPageV2, ...]
                    └── BaseModulePageV2 (NUI)
                            └── [модульные страницы]
```

### Иерархия секций

```
BaseSchemaViewModel
    └── BaseSectionV2 (NUI)
            └── [AccountSectionV2, ContactSectionV2, ...]
```

### Иерархия деталей

```
BaseSchemaViewModel
    └── BaseDetailV2 (NUI)
            └── BaseGridDetailV2
                    └── [конкретные детали с гридом]
```

## Ключевые пространства имён (Namespace)

### Серверные

| Пространство имён | Содержимое |
|-------------------|-----------|
| `BPMSoft.Core` | UserConnection, SystemSettings, AppConnection |
| `BPMSoft.Core.Entities` | Entity, EntitySchema, EntitySchemaQuery |
| `BPMSoft.Core.Entities.Events` | BaseEntityEventListener, EntityBeforeEventArgs |
| `BPMSoft.Core.Process` | Process, ProcessUserTask, ProcessSchemaParameter |
| `BPMSoft.Core.DB` | Select, Insert, Update, Delete (низкоуровневые запросы) |
| `BPMSoft.Core.Factories` | ClassFactory (DI-контейнер) |
| `BPMSoft.Configuration` | Все конфигурационные классы |
| `BPMSoft.Web.Common` | IAppEventListener, AppEventContext |

### Клиентские (глобальные объекты)

| Объект | Содержимое |
|--------|-----------|
| `BPMSoft` | Ядро клиентского SDK |
| `BPMSoft.DataValueType` | Типы данных |
| `BPMSoft.MessageMode` | Режимы сообщений (PTP, BROADCAST) |
| `BPMSoft.MessageDirectionType` | Направления (PUBLISH, SUBSCRIBE) |
| `BPMSoft.ViewItemType` | Типы UI-элементов |
| `BPMSoft.ComparisonType` | Типы сравнения для фильтров |
| `BPMSoft.ContentType` | Типы контента полей |
| `BPMSoft.ConfigurationEnums` | Перечисления конфигурации |
| `BPMSoft.ConfigurationConstants` | Константы (Guid'ы записей) |
| `BPMSoft.ServiceHelper` | Вызов серверных сервисов |
| `BPMSoft.AjaxProvider` | HTTP-запросы |
| `BPMSoft.Mask` | Маска загрузки |
| `Ext` | ExtJS фреймворк |

## Типы фильтров (ComparisonType)

| Тип | Описание |
|-----|----------|
| `EQUAL` | Равно |
| `NOT_EQUAL` | Не равно |
| `GREATER` | Больше |
| `GREATER_OR_EQUAL` | Больше или равно |
| `LESS` | Меньше |
| `LESS_OR_EQUAL` | Меньше или равно |
| `CONTAIN` | Содержит |
| `NOT_CONTAIN` | Не содержит |
| `START_WITH` | Начинается с |
| `END_WITH` | Заканчивается на |
| `IS_NULL` | Пусто |
| `IS_NOT_NULL` | Не пусто |
| `BETWEEN` | Между |
| `EXISTS` | Существует (подзапрос) |
| `NOT_EXISTS` | Не существует (подзапрос) |

---

## Связанные темы

- [Схемы сущностей](../server/entity-schemas.md)
- [EventListener'ы](../server/event-listeners.md)
- [Страницы и секции](../client/pages-sections-details.md)
- [Каталог сущностей](entity-catalog.md)
- [Перечисления и константы](enums-constants.md)
