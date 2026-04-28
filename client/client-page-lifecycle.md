# Client Page Lifecycle

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: BasePageV2, lifecycle, init, onEntityInitialized, save, validation -->

> Lifecycle карточки BPMSoft: инициализация, загрузка entity, validation, save и закрытие.

## Базовая цепочка

```text
define()
  -> init()
  -> subscribeSandboxEvents()
  -> onEntityInitialized()
  -> render diff
  -> user actions
  -> asyncValidate() / save()
  -> onSaved()
  -> destroy()
```

Фактический порядок зависит от базового класса и operation mode, но эти hooks встречаются чаще всего.

## init

`init` подходит для начальной настройки client state, подписок и загрузки справочных данных.

```javascript
init: function(callback, scope) {
    this.callParent([function() {
        this.initSocialPage();
        callback.call(scope);
    }, this]);
}
```

Если базовый метод принимает callback, сохраняйте callback-chain.

## subscribeSandboxEvents

Подписки на sandbox лучше держать отдельно от основной инициализации.

```javascript
subscribeSandboxEvents: function() {
    this.callParent(arguments);
    this.sandbox.subscribe("GetSocialNetworkData", this.getSocialNetworkData, this);
}
```

Подробно см. [Client sandbox messages](client-sandbox-messages.md).

## onEntityInitialized

`onEntityInitialized` вызывается после загрузки данных entity.

```javascript
onEntityInitialized: function() {
    this.callParent(arguments);
    this.loadSocialProfileInfo();
}
```

Здесь уместно:

- читать значения колонок;
- инициализировать dependent UI state;
- загрузить дополнительные данные;
- обновить видимость кнопок;
- подготовить детали.

## entityColumnChanged

`entityColumnChanged` реагирует на изменение колонок.

```javascript
entityColumnChanged: function(columnName, columnValue) {
    this.callParent(arguments);
    this.resetPatterns(columnName, columnValue);
    this.reloadColors();
}
```

Не выполняйте здесь тяжёлые запросы без debounce/throttle или явной необходимости.

## save и validation

Перед сохранением можно добавить validators через `setValidationConfig`.

```javascript
setValidationConfig: function() {
    this.callParent(arguments);
    this.addColumnValidator("Priority", this.priorityValidator);
}
```

Validator возвращает объект с `invalidMessage`.

```javascript
priorityValidator: function(value) {
    var invalidMessage = "";
    if (!Ext.isEmpty(value) && value < 1) {
        invalidMessage = this.get("Resources.Strings.NumberIsNotPositiveMessage");
    }
    return { invalidMessage: invalidMessage };
}
```

## onSaved

`onSaved` используется для реакции после успешного сохранения.

```javascript
onSaved: function() {
    this.callParent(arguments);
    this.onCloseClick();
}
```

Не дублируйте server-side validation на клиенте как единственный барьер: клиентская проверка нужна для UX, серверная — для инвариантов.

## Переопределение базовой страницы

Некоторые пакеты расширяют саму `BasePageV2`.

```javascript
define("BasePageV2", ["WSFieldManagementMixin"], function(WSFieldManagementMixin) {
    return {
        mixins: {
            WSFieldManagementMixin: "BPMSoft.WSFieldManagementMixin"
        },
        methods: {
            save: function() {
                if (this.checkPatternsBeforeSave()) {
                    this.callParent(arguments);
                }
            }
        }
    };
});
```

Такой паттерн имеет широкий blast radius: изменения затрагивают все страницы, наследующие `BasePageV2`.

## Связанные документы

- [Client Module Overview](client-module-overview.md)
- [Client sandbox messages](client-sandbox-messages.md)
- [Client diff, attributes and rules](client-diff-attributes-rules.md)
- [Страницы, секции и детали](pages-sections-details.md)
