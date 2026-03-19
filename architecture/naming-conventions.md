# Конвенции именования в BPMSoft

<!-- Версия: 1.0 | Обновлено: 2026-03-19 | Платформа: BPMSoft 1.9 -->
<!-- Теги: именование, конвенции, файлы, замещение, override -->

## Именование файлов

Формат: `{ИмяКласса}.{Пакет}.{расширение}`

| Пример файла | Класс | Пакет | Тип |
|-------------|-------|-------|-----|
| `AccountSchema.Base.cs` | AccountSchema | Base | C# |
| `AccountPageV2.UIv2.js` | AccountPageV2 | UIv2 | JS |
| `AccountMiniPage.UIv2.less` | AccountMiniPage | UIv2 | LESS |
| `Account.Base.cs` | Account | Base | C# (entity class) |
| `AccountSchema.SSP.cs` | AccountSchema | SSP | C# (замещение) |

## Замещение (Overriding)

Один и тот же класс может быть определён в разных пакетах. Более поздний пакет замещает поведение:

```
ContactSchema.Base.cs           ← базовое определение
ContactSchema.SSP.cs            ← расширение в пакете SSP
ContactSchema.Completeness.cs   ← расширение в пакете Completeness
ContactSchema.EmailMining.cs    ← расширение в пакете EmailMining
```

## Серверные классы (C#)

### Схемы сущностей
| Паттерн | Назначение | Пример |
|---------|-----------|--------|
| `{Name}Schema.{Pkg}.cs` | Описание схемы (колонки, индексы) | `ContactSchema.Base.cs` |
| `{Name}.{Pkg}.cs` | Класс сущности (бизнес-логика) | `Contact.Base.cs` |
| `{Name}Consts.{Pkg}.cs` | Константы сущности (Guid'ы записей) | `ContactConsts.Base.cs` |

### Обработчики событий
| Паттерн | Назначение | Пример |
|---------|-----------|--------|
| `{Name}EventListener.{Pkg}.cs` | Обработчик событий сущности | `ContactEventListener.OmnichannelMessaging.cs` |
| `{Name}AppEventListener.{Pkg}.cs` | Обработчик событий приложения | `FileImportAppEventListener.FileImport.cs` |

### Сервисы
| Паттерн | Назначение | Пример |
|---------|-----------|--------|
| `{Name}Service.{Pkg}.cs` | WCF-сервис | `AdministrationService.UIv2.cs` |
| `{Name}ServiceSchema.{Pkg}.cs` | Схема сервиса | — |

### Процессы
| Паттерн | Назначение | Пример |
|---------|-----------|--------|
| `{Name}UserTask.{Pkg}.cs` | Элемент бизнес-процесса | `AddDataUserTask.ProcessDesigner.cs` |
| `{Name}Process.{Pkg}.cs` | Бизнес-процесс | `ActualizeOrganizationalStructureProcess.Base.cs` |

### Вспомогательные
| Паттерн | Назначение | Пример |
|---------|-----------|--------|
| `{Name}Helper.{Pkg}.cs` | Вспомогательный класс | `AnniversaryRemindingsHelper.Base.cs` |
| `{Name}Utilities.{Pkg}.cs` | Утилиты | `ActivityUtils.Base.cs` |
| `{Name}Provider.{Pkg}.cs` | Провайдер данных | `AccountNotificationProvider.NUI.cs` |

## Клиентские модули (JavaScript)

### Страницы и секции
| Паттерн | Назначение | Пример |
|---------|-----------|--------|
| `{Entity}PageV2.{Pkg}.js` | Страница карточки | `AccountPageV2.UIv2.js` |
| `{Entity}SectionV2.{Pkg}.js` | Раздел (список) | `AccountSectionV2.NUI.js` |
| `{Entity}MiniPage.{Pkg}.js` | Мини-карточка | `AccountMiniPage.UIv2.js` |

### Детали
| Паттерн | Назначение | Пример |
|---------|-----------|--------|
| `{Name}DetailV2.{Pkg}.js` | Деталь | `AccountContactsDetailV2.UIv2.js` |
| `{Name}Detail.{Pkg}.js` | Деталь (старая) | `AccountBillingInfoDetail.NUI.js` |

### Миксины и утилиты
| Паттерн | Назначение | Пример |
|---------|-----------|--------|
| `{Name}Mixin.{Pkg}.js` | Миксин | `LookupQuickAddMixin.NUI.js` |
| `{Name}Utilities.{Pkg}.js` | Утилиты | `RightUtilities.NUI.js` |
| `{Name}Module.{Pkg}.js` | Модуль | `TagModule.NUI.js` |

### Стили
| Паттерн | Назначение | Пример |
|---------|-----------|--------|
| `{Name}.{Pkg}.less` | Стили компонента | `AccountMiniPage.UIv2.less` |
| `{Name}CSS.{Pkg}.js` | JS-обёртка стилей | `AccountMiniPageCSS.UIv2.js` |

## Суффиксы версий

| Суффикс | Значение |
|---------|----------|
| `V2` | Текущая версия (Freedom UI / UIv2) |
| без суффикса | Старая версия (Classic UI) |
| `Schema` | Описание метаданных |

---

## Типовые сценарии

### 1. Найти все замещения конкретной сущности по имени файла

Чтобы найти все файлы, замещающие схему `Contact`, ищите по паттерну `ContactSchema.*.cs`:

```
ContactSchema.Base.cs           ← базовое определение (пакет Base)
ContactSchema.SSP.cs            ← замещение в пакете SSP
ContactSchema.Completeness.cs   ← замещение в пакете Completeness
ContactSchema.EmailMining.cs    ← замещение в пакете EmailMining
```

Аналогично для клиентских модулей — `ContactPageV2.*.js`:

```
ContactPageV2.NUI.js            ← базовая страница
ContactPageV2.UIv2.js           ← замещение в UIv2
ContactPageV2.MyCustomPkg.js    ← кастомное замещение
```

**Правило:** средняя часть имени файла (между первой и последней точкой) — имя пакета-владельца.

### 2. Определить пакет и тип класса по имени файла

По имени файла можно однозначно определить:

| Файл | Класс | Пакет | Тип |
|------|-------|-------|-----|
| `AccountEventListener.CrtBase.cs` | AccountEventListener | CrtBase | Обработчик событий сущности |
| `LeadScoringService.ML.cs` | LeadScoringService | ML | WCF-сервис |
| `ContactSectionV2.NUI.js` | ContactSectionV2 | NUI | Раздел (секция) |
| `LookupQuickAddMixin.NUI.js` | LookupQuickAddMixin | NUI | Миксин |
| `ActivityUtils.Base.cs` | ActivityUtils | Base | Утилитарный класс |

Алгоритм разбора: `{КлассПоПаттерну}.{ИмяПакета}.{Расширение}` → суффикс класса (`Service`, `EventListener`, `PageV2`, `Mixin` и т.д.) указывает тип.

### 3. Создать правильно именованный файл для нового EventListener

Для создания EventListener на сущность `Invoice` в пакете `MyPackage`:

```
Имя файла:  InvoiceEventListener.MyPackage.cs
Класс:      InvoiceEventListener
Namespace:  BPMSoft.Configuration
```

```csharp
// InvoiceEventListener.MyPackage.cs
namespace BPMSoft.Configuration
{
    using BPMSoft.Core.Entities;
    using BPMSoft.Core.Entities.Events;

    [EntityEventListener(SchemaName = "Invoice")]
    public class InvoiceEventListener : BaseEntityEventListener
    {
        public override void OnSaving(object sender, EntityBeforeEventArgs e) {
            var entity = (Entity)sender;
            // логика перед сохранением
        }
    }
}
```

Для AppEventListener:

```
Имя файла:  MyFeatureAppEventListener.MyPackage.cs
Класс:      MyFeatureAppEventListener
```

---

## Антипаттерны

### Нарушение конвенции именования

```
// НЕПРАВИЛЬНО
myService.cs              ← нет имени пакета, нарушен PascalCase
contact_handler.Base.cs   ← snake_case вместо PascalCase
AccountPage.js            ← нет имени пакета
```

**Последствия:** файл невозможно найти стандартным поиском по паттерну, непонятно к какому пакету относится, нарушается механизм замещения.

### Создание файла без суффикса пакета

```
// НЕПРАВИЛЬНО
ContactEventListener.cs     ← к какому пакету относится?
```

**Последствия:** при наличии нескольких пакетов невозможно определить владельца файла. Нарушается процесс компиляции и замещения.

**Правильно:** `ContactEventListener.MyPackage.cs`

### Использование одинаковых имён классов в разных пакетах без понимания порядка замещения

```
// Пакет A (зависит от Base)
AccountHelper.A.cs → class AccountHelper { ... }

// Пакет B (зависит от A)
AccountHelper.B.cs → class AccountHelper { ... }
// Класс из B полностью замещает класс из A!
```

**Последствия:** класс из пакета ниже по иерархии зависимостей полностью перезаписывает одноимённый класс из родительского пакета. Если это не было намеренным замещением — логика из пакета A будет потеряна.

**Правильно:** использовать уникальные имена классов или осознанно создавать замещение с вызовом `base`-методов.

---

## Troubleshooting

### Типичные ошибки

| Ошибка | Причина | Решение |
|--------|---------|---------|
| Класс не найден платформой при компиляции | Имя файла не соответствует паттерну `{Класс}.{Пакет}.{расширение}` или файл не включён в пакет | Проверить формат имени файла; убедиться, что файл добавлен в дескриптор пакета |
| Замещение не работает — загружается старая версия | Неправильный порядок зависимостей пакетов: замещающий пакет не зависит от пакета с оригиналом | Проверить `descriptor.json` — замещающий пакет должен зависеть от пакета, содержащего оригинальную схему |
| Два файла с одинаковым именем класса конфликтуют | Оба файла в пакетах одного уровня (нет прямой зависимости) | Установить явную зависимость между пакетами или переименовать один из классов |
| Клиентский модуль не загружается | Имя файла JS-модуля не совпадает с первым аргументом `define("ModuleName", ...)` | Имя в `define` должно совпадать с именем класса (часть до первой точки в имени файла) |

### Советы по отладке

- **Поиск файлов по паттерну:** `{EntityName}*.{Package}.*` — найти все артефакты конкретной сущности в пакете.
- **Проверка цепочки замещения:** в конфигурации BPMSoft → раздел «Конфигурация» → найти схему → вкладка «Иерархия замещений».
- **Порядок пакетов:** Конфигурация → Пакеты → столбец «Позиция» показывает порядок загрузки.

---

## Связанные темы

- [Архитектура платформы](platform-overview.md)
- [Схемы сущностей (Entity Schemas)](../server/entity-schemas.md)
- [Обработчики событий (EventListeners)](../server/event-listeners.md)
- [WCF-сервисы](../server/services.md)
