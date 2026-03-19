# Страницы, секции и детали

<!-- Версия: 1.0 | Обновлено: 2026-03-19 | Платформа: BPMSoft 1.9 -->
<!-- Теги: BasePageV2, BaseSectionV2, BaseDetailV2, карточка, секция, деталь, MiniPage -->

## Иерархия UI-компонентов

```
BaseSchemaViewModel
    └── BaseEntityPage
            └── BasePageV2              — базовая страница карточки
                    ├── BaseSectionPage — страница с тегами и заметками
                    │       └── AccountPageV2, ContactPageV2, ...
                    └── BaseModulePageV2 — страница модуля (права, журнал)
                            └── конкретные страницы модулей

BaseSchemaViewModel
    └── BaseSectionV2                   — базовая секция (список/грид)
            └── AccountSectionV2, ContactSectionV2, ...

BaseSchemaViewModel
    └── BaseDetailV2                    — базовая деталь
            └── BaseGridDetailV2        — деталь с гридом
                    └── конкретные детали
```

## BasePageV2 — базовая страница карточки

Файл: `BasePageV2.NUI.js`

### Основные возможности
- Загрузка/сохранение данных сущности
- Работа с процессами (DCM, BPMN)
- Теги и заметки
- Печать отчётов
- Проверка прав доступа
- CTI-интеграция

### Ключевые миксины

| Миксин | Назначение |
|--------|-----------|
| `ContextHelpMixin` | Контекстная справка |
| `LookupQuickAddMixin` | Быстрое добавление из lookup |
| `SecurityUtilitiesMixin` | Проверка прав |
| `PrintReportUtilities` | Печать отчётов |
| `WizardUtilities` | Работа с мастером |
| `DcmPageMixin` | DCM (Case Management) |
| `EntityResponseValidationMixin` | Валидация ответов сервера |
| `EntityRelatedColumnsMixin` | Связанные колонки |

### Ключевые методы

```javascript
// Сохранение
save(config)              // сохранить запись
asyncValidate(callback)   // асинхронная валидация перед сохранением
onSaved(response, config) // после сохранения

// Навигация
onCloseCardButtonClick()  // закрыть карточку
onBackButtonClick()       // назад

// Данные
reloadEntity()            // перезагрузить данные
getColumnValues(columns)  // получить значения колонок
setColumnValues(values)   // установить значения

// Действия
getActions()              // меню действий (кнопка "Действия")
onActiveActionChange()    // смена действия
```

### Создание страницы карточки

```javascript
define("MyEntityPageV2", ["MyEntityPageV2Resources"], function(resources) {
    return {
        entitySchemaName: "MyEntity",

        attributes: {
            "Name": { dataValueType: BPMSoft.DataValueType.TEXT },
            "Status": {
                dataValueType: BPMSoft.DataValueType.LOOKUP,
                lookupListConfig: { columns: ["Name"] }
            }
        },

        details: {
            "MyDetail": {
                schemaName: "MyEntityDetailV2",
                entitySchemaName: "MyChildEntity",
                filter: {
                    masterColumn: "Id",
                    detailColumn: "MyEntity"
                }
            }
        },

        diff: [
            {
                "operation": "insert",
                "name": "Name",
                "parentName": "Header",
                "propertyName": "items",
                "values": {
                    "layout": { "column": 0, "row": 0, "colSpan": 12 }
                }
            },
            {
                "operation": "insert",
                "name": "Status",
                "parentName": "Header",
                "propertyName": "items",
                "values": {
                    "layout": { "column": 12, "row": 0, "colSpan": 12 },
                    "contentType": BPMSoft.ContentType.ENUM
                }
            },
            {
                "operation": "insert",
                "name": "MyDetailTab",
                "parentName": "Tabs",
                "propertyName": "tabs",
                "values": {
                    "caption": "Мои данные",
                    "items": []
                }
            },
            {
                "operation": "insert",
                "name": "MyDetail",
                "parentName": "MyDetailTab",
                "propertyName": "items",
                "values": {
                    "itemType": BPMSoft.ViewItemType.DETAIL
                }
            }
        ],

        methods: {
            onEntityInitialized: function() {
                this.callParent(arguments);
                // инициализация после загрузки данных
            }
        }
    };
});
```

## BaseSectionV2 — базовая секция

Файл: `BaseSectionV2.NUI.js`

### Возможности
- Грид (список записей) с пагинацией
- Фильтрация и группировка
- Аналитические дашборды
- Действия над записями
- Data binding

### Ключевые атрибуты

| Атрибут | Тип | Описание |
|---------|-----|----------|
| `GridData` | COLLECTION | Данные грида |
| `ActiveRow` | GUID | Выбранная строка |
| `IsGridReloaded` | BOOLEAN | Грид перезагружен |
| `AnalyticsDataViewName` | TEXT | Имя вида аналитики |

### Ключевые методы

```javascript
reloadGridData()           // перезагрузить данные грида
loadDashboardModule()      // загрузить модуль дашборда
updateSection()            // обновить секцию
getFilters()               // получить текущие фильтры
```

### Создание секции

```javascript
define("MyEntitySectionV2", [], function() {
    return {
        entitySchemaName: "MyEntity",

        methods: {
            getFilters: function() {
                var filters = this.callParent(arguments);
                filters.addItem(BPMSoft.createColumnFilterWithParameter(
                    BPMSoft.ComparisonType.EQUAL,
                    "IsActive", true
                ));
                return filters;
            }
        },

        diff: []
    };
});
```

## BaseDetailV2 — базовая деталь

Файл: `BaseDetailV2.NUI.js`

### Ключевые атрибуты

| Атрибут | Тип | По умолчанию | Описание |
|---------|-----|-------------|----------|
| `CanAdd` | BOOLEAN | — | Право добавлять |
| `CanEdit` | BOOLEAN | — | Право редактировать |
| `CanDelete` | BOOLEAN | — | Право удалять |
| `Collection` | COLLECTION | — | Данные детали |
| `MasterRecordId` | GUID | — | ID мастер-записи |
| `DetailColumnName` | TEXT | — | Колонка связи |
| `IsDetailCollapsed` | BOOLEAN | — | Свёрнута ли деталь |
| `IsEnabled` | BOOLEAN | true | Активна ли деталь |

### Взаимодействие деталь ↔ страница

```
[Page]                              [Detail]
   │                                   │
   │──── UpdateDetail ────────────────→│  обновить данные
   │                                   │
   │←─── DetailChanged ───────────────│  деталь изменена
   │                                   │
   │←─── GetColumnsValues ────────────│  запросить значения мастер-записи
   │                                   │
   │──── SaveRecord ──────────────────→│  сохранить запись (перед добавлением)
```

### Создание детали

```javascript
define("MyEntityDetailV2", ["ConfigurationEnums"], function(ConfigurationEnums) {
    return {
        entitySchemaName: "MyChildEntity",

        attributes: {},

        methods: {
            getAddRecordButtonVisible: function() {
                return this.getToolsVisible();
            },
            onCardSaved: function() {
                this.openCardInChain({
                    schemaName: "MyChildEntityPageV2",
                    operation: ConfigurationEnums.CardStateV2.ADD,
                    moduleId: this.getEditPageSandboxId()
                });
            }
        },

        diff: []
    };
});
```

## MiniPage — мини-карточка

Компактная карточка для быстрого просмотра/редактирования.

```javascript
define("MyEntityMiniPage", [], function() {
    return {
        entitySchemaName: "MyEntity",

        attributes: {
            "MiniPageModes": {
                value: [BPMSoft.ConfigurationEnums.CardOperation.VIEW,
                        BPMSoft.ConfigurationEnums.CardOperation.ADD]
            }
        },

        diff: [
            {
                "operation": "insert",
                "name": "Name",
                "parentName": "MiniPage",
                "propertyName": "items",
                "values": {
                    "layout": { "column": 0, "row": 0, "colSpan": 24 }
                }
            }
        ]
    };
});
```

---

## Типовые сценарии

### 1. Создание страницы карточки с полями и деталью

```javascript
define("OrderPageV2", ["OrderPageV2Resources"], function(resources) {
    return {
        entitySchemaName: "Order",
        attributes: {
            "Number": { dataValueType: BPMSoft.DataValueType.TEXT },
            "Amount": { dataValueType: BPMSoft.DataValueType.MONEY },
            "Status": {
                dataValueType: BPMSoft.DataValueType.LOOKUP,
                lookupListConfig: { columns: ["Name"] }
            }
        },
        details: {
            "OrderProducts": {
                schemaName: "OrderProductDetailV2",
                entitySchemaName: "OrderProduct",
                filter: { masterColumn: "Id", detailColumn: "Order" }
            }
        },
        diff: [
            {
                "operation": "insert", "name": "Number",
                "parentName": "Header", "propertyName": "items",
                "values": { "layout": { "column": 0, "row": 0, "colSpan": 12 } }
            },
            {
                "operation": "insert", "name": "Amount",
                "parentName": "Header", "propertyName": "items",
                "values": { "layout": { "column": 12, "row": 0, "colSpan": 12 } }
            },
            {
                "operation": "insert", "name": "ProductsTab",
                "parentName": "Tabs", "propertyName": "tabs",
                "values": { "caption": "Продукты", "items": [] }
            },
            {
                "operation": "insert", "name": "OrderProducts",
                "parentName": "ProductsTab", "propertyName": "items",
                "values": { "itemType": BPMSoft.ViewItemType.DETAIL }
            }
        ],
        methods: {
            onEntityInitialized: function() {
                this.callParent(arguments);
            }
        }
    };
});
```

### 2. Добавление фильтра в секцию

```javascript
define("OrderSectionV2", [], function() {
    return {
        entitySchemaName: "Order",
        methods: {
            getFilters: function() {
                var filters = this.callParent(arguments);
                filters.addItem(BPMSoft.createColumnFilterWithParameter(
                    BPMSoft.ComparisonType.NOT_EQUAL,
                    "Status.Name", "Отменён"
                ));
                return filters;
            }
        },
        diff: []
    };
});
```

### 3. Создание детали с кнопкой добавления

```javascript
define("OrderProductDetailV2", ["ConfigurationEnums"], function(ConfigurationEnums) {
    return {
        entitySchemaName: "OrderProduct",
        methods: {
            getAddRecordButtonVisible: function() {
                return this.getToolsVisible();
            },
            addRecord: function() {
                var masterRecordId = this.get("MasterRecordId");
                if (!masterRecordId) {
                    return;
                }
                this.openCardInChain({
                    schemaName: "OrderProductPageV2",
                    operation: ConfigurationEnums.CardStateV2.ADD,
                    moduleId: this.getEditPageSandboxId(),
                    defaultValues: [{
                        name: "Order",
                        value: masterRecordId
                    }]
                });
            }
        },
        diff: []
    };
});
```

### 4. MiniPage для быстрого просмотра

```javascript
define("OrderMiniPage", [], function() {
    return {
        entitySchemaName: "Order",
        attributes: {
            "MiniPageModes": {
                value: [BPMSoft.ConfigurationEnums.CardOperation.VIEW,
                        BPMSoft.ConfigurationEnums.CardOperation.ADD]
            }
        },
        diff: [
            {
                "operation": "insert", "name": "Number",
                "parentName": "MiniPage", "propertyName": "items",
                "values": { "layout": { "column": 0, "row": 0, "colSpan": 24 } }
            },
            {
                "operation": "insert", "name": "Status",
                "parentName": "MiniPage", "propertyName": "items",
                "values": {
                    "layout": { "column": 0, "row": 1, "colSpan": 24 },
                    "contentType": BPMSoft.ContentType.ENUM
                }
            }
        ]
    };
});
```

---

## Антипаттерны

❌ **Вызов this.save() в onEntityInitialized()** — бесконечный цикл сохранения.

```javascript
// ❌ Плохо — save → onSaved → reloadEntity → onEntityInitialized → save → ...
onEntityInitialized: function() {
    this.callParent(arguments);
    this.save();
}
```

❌ **Обращение к деталям до загрузки страницы.**

```javascript
// ❌ Плохо — деталь ещё не инициализирована
init: function() {
    this.callParent(arguments);
    this.sandbox.publish("UpdateDetail", null, [this.getDetailId("MyDetail")]);
}

// ✅ Правильно — в onEntityInitialized или позже
onEntityInitialized: function() {
    this.callParent(arguments);
    this.sandbox.publish("UpdateDetail", null, [this.getDetailId("MyDetail")]);
}
```

❌ **Забыть callParent(arguments)** в переопределённых методах — ломается цепочка наследования.

```javascript
// ❌ Плохо
onEntityInitialized: function() {
    this.doSomething();
}

// ✅ Правильно
onEntityInitialized: function() {
    this.callParent(arguments);
    this.doSomething();
}
```

❌ **Большой diff без operation: "merge"** — дублирование элементов.

```javascript
// ❌ Плохо — insert элемента, который уже существует → дубль
{ "operation": "insert", "name": "Name", ... }

// ✅ Правильно — merge для изменения существующего элемента
{ "operation": "merge", "name": "Name", "values": { "visible": false } }
```

---

## Troubleshooting

| Проблема | Причина | Решение |
|----------|---------|---------|
| Деталь не обновляется | Не опубликовано сообщение `UpdateDetail` | `this.sandbox.publish("UpdateDetail", null, [this.getDetailId("DetailName")])` |
| Поле не отображается | Ошибка в diff: неверный `parentName`, `propertyName` или `layout` | Проверить `parentName` (Header/ProfileContainer), `propertyName: "items"`, координаты `layout` |
| Карточка не сохраняется | Ошибка валидации | Проверить `asyncValidate`, убедиться что callback вызывается с `{ success: true }` |
| MiniPage не открывается | Не задан `MiniPageModes` в attributes | Добавить атрибут `MiniPageModes` со списком операций |

**Советы по отладке:**

- `this.getDetailId("DetailName")` — вывести sandbox ID детали для проверки маршрутизации.
- `this.get("IsEntityInitialized")` — проверить, загружены ли данные сущности.
- DevTools → Elements → искать элемент по `data-item-marker` для диагностики layout.

---

## Связанные темы

- [AMD-модули](modules.md)
- [Миксины](mixins.md)
- [Утилиты](utilities.md)
- [Схемы сущностей](../server/entity-schemas.md)
