# Система миксинов

<!-- Версия: 1.0 | Обновлено: 2026-03-19 | Платформа: BPMSoft 1.9 -->
<!-- Теги: миксины, mixin, переиспользование, BPMSoft.MyMixin, Ext.define -->

## Обзор

Миксины — механизм переиспользования поведения между модулями. Миксин добавляет методы и свойства в класс без наследования.

## Определение миксина

```javascript
define("MyMixin", [], function() {
    Ext.define("BPMSoft.configuration.mixins.MyMixin", {
        alternateClassName: "BPMSoft.MyMixin",

        init: function(callback, scope) {
            // инициализация
            Ext.callback(callback, scope);
        },

        myMethod: function() {
            // логика миксина
        },

        destroy: function() {
            // очистка ресурсов
        }
    });

    return BPMSoft.MyMixin;
});
```

## Подключение миксина

```javascript
define("MyPageV2", ["MyMixin"], function() {
    return {
        mixins: {
            MyMixin: "BPMSoft.MyMixin"
        },

        methods: {
            init: function() {
                this.callParent(arguments);
                this.mixins.MyMixin.init.call(this);
            },

            myPageMethod: function() {
                // вызов метода миксина
                this.myMethod();
            }
        }
    };
});
```

## Ключевые миксины базового решения

### ContextHelpMixin
**Файл:** `ContextHelpMixin.NUI.js`
**Назначение:** Контекстная справка на страницах.

```javascript
mixins: { ContextHelpMixin: "BPMSoft.ContextHelpMixin" }
```
- Публикует `InitContextHelp`
- Подписывается на `ContextHelpModuleLoaded`
- Автоматически подключает Academy

### LookupQuickAddMixin
**Файл:** `LookupQuickAddMixin.NUI.js`
**Назначение:** Быстрое добавление записей из полей Lookup.

- Проверяет права через `RightUtilities.checkCanExecuteOperation`
- Регистрирует сообщения sandbox для создания записей

### SecurityUtilitiesMixin
**Файл:** `SecurityUtilities.NUI.js`
**Назначение:** Проверка прав доступа.

```javascript
// Проверка операции
this.checkCanExecuteOperation("CanManageAdministration", function(result) {
    if (result) { /* есть права */ }
});

// Проверка прав на схему
this.checkSchemaRightsAvailability("Contact", function(result) {
    // result.canRead, result.canEdit, result.canDelete
});
```

### CommunicationSynchronizerMixin
**Файл:** `CommunicationSynchronizerMixin.*.js`
**Назначение:** Синхронизация полей коммуникаций с деталью Communications.

```javascript
// Синхронизация при изменении поля Phone
this.sandbox.publish("SyncCommunication", {
    Name: "Phone",
    Value: this.get("Phone")
}, [this.getDetailId("Communications")]);
```

### DcmPageMixin
**Файл:** `DcmPageMixin.NUI.js`
**Назначение:** Интеграция с DCM (Dynamic Case Management) на страницах.

### CheckModuleDestroyMixin
**Файл:** `CheckModuleDestroyMixin.NUI.js`
**Назначение:** Проверка несохранённых изменений при уходе со страницы.

### SystemOperationsPermissionsMixin
**Файл:** `SystemOperationsPermissionsMixin.UIv2.js`
**Назначение:** Массовая проверка системных операций.

### ActivityDatesMixin
**Файл:** `ActivityDatesMixin.UIv2.js`
**Назначение:** Работа с датами активностей (начало, окончание, длительность).

### OAuthAuthenticationMixin
**Файл:** `OAuthAuthenticationMixin.UIv2.js`
**Назначение:** OAuth-аутентификация во внешних сервисах.

### MoneyUtilsMixin
**Файл:** `MoneyUtilsMixin.NUI.js`
**Назначение:** Вычисление сумм с учётом курсов валют.

### SchemaAccessControllerMixin
**Файл:** `SchemaAccessControllerMixin.SSP.js`
**Назначение:** Контроль доступа к схемам на портале самообслуживания.

## Полный список миксинов

| Миксин | Пакет | Категория |
|--------|-------|-----------|
| CheckModuleDestroyMixin | NUI | Навигация |
| ColumnEditMixin | NUI | Редактирование |
| ContextHelpMixin | NUI | Справка |
| CommunicationSynchronizerMixin | NUI | Коммуникации |
| DcmPageMixin | NUI | DCM |
| LookupQuickAddMixin | NUI | Lookup |
| MoneyUtilsMixin | NUI | Финансы |
| PrintReportUtilities | NUI | Печать |
| SecurityUtilitiesMixin | NUI | Безопасность |
| WizardUtilities | NUI | Мастер |
| EntityResponseValidationMixin | NUI | Валидация |
| EntityRelatedColumnsMixin | NUI | Связи |
| MultiLookupUtilitiesMixin | NUI | Lookup |
| QuickAddMixin | NUI | Быстрое добавление |
| ActivityDatesMixin | UIv2 | Даты активностей |
| OAuthAuthenticationMixin | UIv2 | OAuth |
| SystemOperationsPermissionsMixin | UIv2 | Права |
| SchemaAccessControllerMixin | SSP | Доступ (портал) |
| PortalUserInvitationMixin | SSP | Приглашения |
| SyncSettingsMixin | Exchange | Синхронизация |
| CronExpressionPageMixin | ProcessDesigner | Расписание |
| FilterModuleMixin | ProcessDesigner | Фильтры |
| MappingEditMixin | ProcessDesigner | Маппинг |
| SchemaDataBindingMixin | NUI | Data binding |

---

## Типовые сценарии

### 1. Создание простого миксина

```javascript
define("NotificationMixin", [], function() {
    Ext.define("BPMSoft.configuration.mixins.NotificationMixin", {
        alternateClassName: "BPMSoft.NotificationMixin",

        showSuccess: function(message) {
            BPMSoft.showInformation(message || "Операция выполнена успешно");
        },

        showError: function(message) {
            BPMSoft.showInformation(message || "Произошла ошибка");
        }
    });
    return BPMSoft.NotificationMixin;
});
```

### 2. Подключение миксина в страницу

```javascript
define("MyPageV2", ["NotificationMixin"], function() {
    return {
        mixins: {
            NotificationMixin: "BPMSoft.NotificationMixin"
        },
        methods: {
            onSaved: function(response) {
                this.callParent(arguments);
                if (response.success) {
                    this.showSuccess("Запись сохранена");
                }
            }
        }
    };
});
```

### 3. Вызов метода миксина из метода страницы

```javascript
methods: {
    onButtonClick: function() {
        var result = this.mixins.ValidationMixin.validate.call(this, this.get("Name"));
        if (result.isValid) {
            this.save();
        } else {
            this.showError(result.message);
        }
    }
}
```

### 4. Миксин с инициализацией

```javascript
define("CacheMixin", [], function() {
    Ext.define("BPMSoft.configuration.mixins.CacheMixin", {
        alternateClassName: "BPMSoft.CacheMixin",

        init: function(callback, scope) {
            this.set("MixinCache", {});
            Ext.callback(callback, scope);
        },

        cacheGet: function(key) {
            return this.get("MixinCache")[key];
        },

        cacheSet: function(key, value) {
            var cache = this.get("MixinCache");
            cache[key] = value;
            this.set("MixinCache", cache);
        }
    });
    return BPMSoft.CacheMixin;
});

// Подключение:
init: function() {
    this.callParent(arguments);
    this.mixins.CacheMixin.init.call(this, function() {
        this.cacheSet("startTime", new Date());
    }, this);
}
```

---

## Антипаттерны

❌ **Конфликт имён методов миксина и страницы** — перезапись без предупреждения.

```javascript
// ❌ Плохо — миксин и страница оба определяют validate(), один перезапишет другой
// Миксин:
myMethod: function() { return "mixin"; }
// Страница:
myMethod: function() { return "page"; }

// ✅ Правильно — уникальные префиксы или явный вызов
mixinValidate: function() { return "mixin"; }
```

❌ **Забыть вызвать init миксина в init страницы.**

```javascript
// ❌ Плохо — методы миксина зависят от init, но он не вызван
init: function() {
    this.callParent(arguments);
    // забыли this.mixins.CacheMixin.init.call(this);
    this.cacheGet("key"); // TypeError
}
```

❌ **Хранение состояния в closure миксина** — общее между всеми экземплярами.

```javascript
// ❌ Плохо — переменная sharedState общая для всех страниц
define("BadMixin", [], function() {
    var sharedState = {};
    Ext.define("BPMSoft.BadMixin", {
        setState: function(k, v) { sharedState[k] = v; }
    });
});

// ✅ Правильно — хранить через this.set()/this.get()
setState: function(key, value) {
    this.set("MixinState_" + key, value);
}
```

---

## Troubleshooting

| Проблема | Причина | Решение |
|----------|---------|---------|
| Метод миксина не найден | Не указан `alternateClassName` или отсутствует зависимость в `define()` | Проверить `alternateClassName` и массив зависимостей |
| Миксин не инициализируется | Не вызван `init` миксина | Добавить `this.mixins.MyMixin.init.call(this)` в `init()` страницы |
| TypeError при вызове метода | Неверный `this` (scope) | Использовать `.call(this)` / `.apply(this)` при вызове методов миксина |

**Советы по отладке:**

- `console.log(Object.keys(this.mixins))` — проверить подключённые миксины.
- `this.mixins.MyMixin` — убедиться, что объект миксина доступен (не `undefined`).
- При конфликте имён — проверить порядок миксинов в объекте `mixins`.

---

## Связанные темы

- [AMD-модули](modules.md)
- [Страницы и секции](pages-sections-details.md)
- [Утилиты](utilities.md)
