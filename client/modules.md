# AMD-модули BPMSoft (клиентская часть)

<!-- Версия: 1.0 | Обновлено: 2026-03-19 | Платформа: BPMSoft 1.9 -->
<!-- Теги: AMD, модули, RequireJS, define, attributes, messages, sandbox, diff, жизненный цикл -->

## Обзор

Клиентский код BPMSoft построен на **AMD** (Asynchronous Module Definition) через RequireJS. Каждый модуль — функциональная единица с объявленными зависимостями.

## Структура модуля

```javascript
define("MyModuleName", ["dep1", "dep2", "dep3"], function(dep1, dep2, dep3) {
    return {
        entitySchemaName: "Contact",    // привязка к сущности (опционально)

        mixins: {                        // подключение миксинов
            MyMixin: "BPMSoft.MyMixin"
        },

        attributes: {                    // атрибуты (свойства) модели
            "MyAttribute": {
                dataValueType: BPMSoft.DataValueType.TEXT,
                value: ""
            }
        },

        messages: {                      // сообщения sandbox
            "MyMessage": {
                mode: BPMSoft.MessageMode.PTP,
                direction: BPMSoft.MessageDirectionType.PUBLISH
            }
        },

        methods: {                       // методы
            init: function() {
                this.callParent(arguments);
            },
            myMethod: function() {
                // логика
            }
        },

        diff: [                          // декларативное описание UI
            {
                "operation": "insert",
                "name": "MyButton",
                "parentName": "ActionButtonsContainer",
                "propertyName": "items",
                "values": {
                    "itemType": BPMSoft.ViewItemType.BUTTON,
                    "caption": "Моя кнопка",
                    "click": { "bindTo": "myMethod" }
                }
            }
        ],

        rules: {},                       // бизнес-правила
        details: {}                      // детали
    };
});
```

## Жизненный цикл модуля

```
define() → загрузка зависимостей → init() → onEntityInitialized() → onPageInitialized()
                                                │
                                         Рендеринг через diff
                                                │
                                         Взаимодействие пользователя
                                                │
                                    save() / discard() / destroy()
```

### Ключевые методы жизненного цикла

| Метод | Когда вызывается |
|-------|-----------------|
| `init()` | Инициализация модуля |
| `onEntityInitialized()` | После загрузки данных сущности |
| `onPageInitialized()` | После полной инициализации страницы |
| `subscribeSandboxEvents()` | Подписка на сообщения sandbox |
| `save()` | Сохранение данных |
| `onSaved()` | После успешного сохранения |
| `destroy()` | Уничтожение модуля |

## Атрибуты (Attributes)

Атрибуты — реактивные свойства модели:

```javascript
attributes: {
    "Name": {
        dataValueType: BPMSoft.DataValueType.TEXT,
        value: "По умолчанию"
    },
    "IsActive": {
        dataValueType: BPMSoft.DataValueType.BOOLEAN,
        value: true
    },
    "Owner": {
        dataValueType: BPMSoft.DataValueType.LOOKUP,
        lookupListConfig: {
            columns: ["Name", "Department"]
        }
    },
    "Amount": {
        dataValueType: BPMSoft.DataValueType.MONEY,
        dependencies: [{
            columns: ["Price", "Quantity"],
            methodName: "calculateAmount"
        }]
    },
    "ItemsCollection": {
        dataValueType: BPMSoft.DataValueType.COLLECTION
    }
}
```

### DataValueType (основные)

| Тип | Описание |
|-----|----------|
| `TEXT` | Строка |
| `INTEGER` | Целое число |
| `FLOAT` | Дробное число |
| `MONEY` | Денежная сумма |
| `BOOLEAN` | Логическое |
| `DATE_TIME` / `DATE` / `TIME` | Дата/время |
| `LOOKUP` | Ссылка (выпадающий список) |
| `ENUM` | Перечисление |
| `GUID` | Уникальный идентификатор |
| `COLLECTION` | Коллекция |
| `CUSTOM_OBJECT` | Произвольный объект |
| `IMAGELOOKUP` | Ссылка на изображение |

## Сообщения (Messages / Sandbox)

Sandbox — шина сообщений между модулями.

### Типы сообщений

| Тип | Описание |
|-----|----------|
| `BPMSoft.MessageMode.PTP` | Point-to-point (один подписчик) |
| `BPMSoft.MessageMode.BROADCAST` | Рассылка всем подписчикам |

### Направления

| Направление | Описание |
|-------------|----------|
| `PUBLISH` | Модуль отправляет |
| `SUBSCRIBE` | Модуль принимает |
| `BIDIRECTIONAL` | В обе стороны |

### Пример

```javascript
messages: {
    "SaveRecord": {
        mode: BPMSoft.MessageMode.PTP,
        direction: BPMSoft.MessageDirectionType.PUBLISH
    },
    "UpdateDetail": {
        mode: BPMSoft.MessageMode.PTP,
        direction: BPMSoft.MessageDirectionType.BIDIRECTIONAL
    }
},

methods: {
    init: function() {
        this.callParent(arguments);
        this.sandbox.subscribe("UpdateDetail", this.onDetailUpdate, this, [this.sandbox.id]);
    },
    saveRecord: function() {
        this.sandbox.publish("SaveRecord", null, [this.sandbox.id]);
    },
    onDetailUpdate: function(config) {
        this.reloadEntity();
    }
}
```

### Ключевые системные сообщения

| Сообщение | Направление | Описание |
|-----------|-------------|----------|
| `SaveRecord` | PUBLISH | Сохранить запись |
| `CloseCard` | PUBLISH | Закрыть карточку |
| `OpenCard` / `OpenCardInChain` | PUBLISH | Открыть карточку |
| `UpdateDetail` | BIDIRECTIONAL | Обновить деталь |
| `DetailChanged` | BIDIRECTIONAL | Деталь изменена |
| `GetCardState` | SUBSCRIBE | Получить состояние карточки |
| `IsCardChanged` | SUBSCRIBE | Проверить изменения |
| `GetColumnsValues` | SUBSCRIBE | Получить значения колонок |
| `GetEntityInfo` | SUBSCRIBE | Информация о сущности |
| `ReloadCardData` | PUBLISH | Перезагрузить данные карточки |
| `GridRowChanged` | SUBSCRIBE | Выбрана строка в гриде |

## diff — декларативный UI

```javascript
diff: [
    {
        "operation": "insert",         // insert, remove, merge, move
        "name": "ElementName",         // уникальное имя элемента
        "parentName": "ParentContainer",
        "propertyName": "items",       // куда вставляется
        "index": 0,                    // позиция (опционально)
        "values": {
            "itemType": BPMSoft.ViewItemType.BUTTON,
            "caption": { "bindTo": "Resources.Strings.MyCaption" },
            "click": { "bindTo": "onButtonClick" },
            "visible": { "bindTo": "IsButtonVisible" }
        }
    },
    {
        "operation": "remove",
        "name": "ElementToRemove"
    },
    {
        "operation": "merge",
        "name": "ExistingElement",
        "values": {
            "visible": false
        }
    }
]
```

### ViewItemType

| Тип | Описание |
|-----|----------|
| `BUTTON` | Кнопка |
| `LABEL` | Текстовая метка |
| `CONTAINER` | Контейнер |
| `GRID_LAYOUT` | Сетка |
| `MODEL_ITEM` | Поле модели (автоматический виджет по DataValueType) |
| `MODULE` | Встроенный модуль |
| `DETAIL` | Деталь |
| `TAB_PANEL` | Панель вкладок |
| `COLOR_BUTTON` | Кнопка выбора цвета |
| `RADIO_GROUP` | Группа радиокнопок |
| `DESIGN_ITEM` | Элемент дизайнера |
| `HYPERLINK` | Гиперссылка |
| `INFORMATION_BUTTON` | Информационная кнопка |

## Бизнес-правила (rules)

```javascript
rules: {
    "City": {
        "FiltrationCityByCountry": {
            ruleType: BusinessRuleModule.enums.RuleType.FILTRATION,
            autocomplete: true,
            baseAttributePatch: "Country",
            comparisonType: BPMSoft.ComparisonType.EQUAL,
            type: BusinessRuleModule.enums.ValueType.ATTRIBUTE,
            attribute: "Country"
        }
    }
}
```

## Детали (details)

```javascript
details: {
    "Communications": {
        schemaName: "AccountCommunicationDetail",
        entitySchemaName: "AccountCommunication",
        filter: {
            masterColumn: "Id",
            detailColumn: "Account"
        }
    },
    "Activities": {
        schemaName: "ActivityDetailV2",
        entitySchemaName: "Activity",
        filter: {
            masterColumn: "Id",
            detailColumn: "Account"
        }
    }
}
```

---

## Типовые сценарии

### 1. Создание модуля с атрибутами и diff

```javascript
define("ContactPageV2", ["ContactPageV2Resources"], function(resources) {
    return {
        entitySchemaName: "Contact",
        attributes: {
            "FullJobTitle": {
                dataValueType: BPMSoft.DataValueType.TEXT,
                dependencies: [{
                    columns: ["Job", "Department"],
                    methodName: "updateFullJobTitle"
                }]
            }
        },
        methods: {
            updateFullJobTitle: function() {
                var job = this.get("Job");
                var dept = this.get("Department");
                this.set("FullJobTitle",
                    (job ? job.displayValue : "") + " / " + (dept ? dept.displayValue : ""));
            }
        },
        diff: [
            {
                "operation": "insert",
                "name": "FullJobTitle",
                "parentName": "Header",
                "propertyName": "items",
                "values": {
                    "layout": { "column": 0, "row": 2, "colSpan": 24 },
                    "enabled": false
                }
            }
        ]
    };
});
```

### 2. Подписка на sandbox-сообщение

```javascript
messages: {
    "DetailSaved": {
        mode: BPMSoft.MessageMode.PTP,
        direction: BPMSoft.MessageDirectionType.SUBSCRIBE
    }
},
methods: {
    subscribeSandboxEvents: function() {
        this.callParent(arguments);
        this.sandbox.subscribe("DetailSaved", this.onDetailSaved, this,
            [this.getDetailId("MyDetail")]);
    },
    onDetailSaved: function(args) {
        this.reloadEntity();
        this.showInformationDialog("Деталь сохранена");
    }
}
```

### 3. Добавление кнопки через diff

```javascript
diff: [
    {
        "operation": "insert",
        "name": "SendEmailButton",
        "parentName": "LeftContainer",
        "propertyName": "items",
        "values": {
            "itemType": BPMSoft.ViewItemType.BUTTON,
            "caption": { "bindTo": "Resources.Strings.SendEmailCaption" },
            "click": { "bindTo": "onSendEmailClick" },
            "style": BPMSoft.controls.ButtonEnums.style.GREEN,
            "visible": { "bindTo": "canSendEmail" }
        }
    }
]
```

### 4. Реактивная зависимость атрибутов (dependencies)

```javascript
attributes: {
    "Price": { dataValueType: BPMSoft.DataValueType.MONEY },
    "Quantity": { dataValueType: BPMSoft.DataValueType.INTEGER },
    "TotalAmount": {
        dataValueType: BPMSoft.DataValueType.MONEY,
        dependencies: [{
            columns: ["Price", "Quantity"],
            methodName: "calcTotal"
        }]
    }
},
methods: {
    calcTotal: function() {
        var price = this.get("Price") || 0;
        var qty = this.get("Quantity") || 0;
        this.set("TotalAmount", price * qty);
    }
}
```

---

## Антипаттерны

❌ **Прямой доступ к DOM вместо diff** — ломается при замещении модуля другим пакетом.

```javascript
// ❌ Плохо
document.getElementById("myField").style.display = "none";

// ✅ Правильно — через diff
{ "operation": "merge", "name": "myField", "values": { "visible": false } }
```

❌ **Подписка на sandbox без отписки** — утечка памяти при многократном открытии страницы.

```javascript
// ❌ Плохо — без привязки к sandbox ID
this.sandbox.subscribe("MyMsg", this.handler, this);

// ✅ Правильно — с привязкой к sandbox ID (автоотписка при destroy)
this.sandbox.subscribe("MyMsg", this.handler, this, [this.sandbox.id]);
```

❌ **Циклические зависимости в define()** — бесконечная загрузка модуля.

```javascript
// ❌ ModuleA → ModuleB → ModuleA — цикл
define("ModuleA", ["ModuleB"], function() { ... });
define("ModuleB", ["ModuleA"], function() { ... });
```

❌ **Мутация this.get("Collection") напрямую** без методов коллекции.

```javascript
// ❌ Плохо
this.get("GridData").collection.items.push(newItem);

// ✅ Правильно — через методы BPMSoft.Collection
this.get("GridData").add(id, newItem);
```

---

## Troubleshooting

| Проблема | Причина | Решение |
|----------|---------|---------|
| Модуль не загружается | Ошибка в зависимостях `define()` | Проверить имена в `define()`, Network → 404 |
| Белый экран | Исключение в `init()` / `onEntityInitialized()` | DevTools → Console, найти стек ошибки |
| Атрибут не обновляется в UI | Неверный `dataValueType` или отсутствует `bindTo` в diff | Проверить `dataValueType`, в diff должен быть `"bindTo": "AttrName"` |
| Sandbox-сообщение не доходит | Несовпадение `direction` или sandbox ID | Проверить `direction` на обоих концах, совпадение sandbox ID |

**Советы по отладке:**

- `this.sandbox.id` — вывести в консоль для диагностики маршрутизации сообщений.
- DevTools → Network → фильтр по `rest/` для отслеживания серверных вызовов.
- `BPMSoft.SysSettings.getCachedValues("Key", callback)` — проверить системные настройки.

---

## Связанные темы

- [Страницы и секции](pages-sections-details.md)
- [Миксины](mixins.md)
- [Утилиты](utilities.md)
- [Перечисления и константы](../reference/enums-constants.md)
