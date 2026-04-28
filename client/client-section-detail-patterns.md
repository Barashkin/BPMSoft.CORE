# Client Section And Detail Patterns

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: BaseSectionV2, BaseDetailV2, BaseGridDetailV2, grid, detail -->

> Паттерны секций и деталей: actions, filters, reload, grid state и связь master-detail.

## Section

`BaseSectionV2` отвечает за список записей, фильтры, actions и режимы отображения.

```javascript
define("InsightApplicationSection", ["ProcessModuleUtilities"], function(ProcessModuleUtilities) {
    return {
        entitySchemaName: "InsightApplication",
        attributes: {},
        methods: {},
        diff: []
    };
});
```

## Section actions

Секции часто переопределяют `getSectionActions`.

```javascript
getSectionActions: function() {
    var actionMenuItems = this.callParent(arguments);
    actionMenuItems.clear();
    actionMenuItems.addItem(this.createSelectMultipleRecordsButton());
    actionMenuItems.addItem(this.getExportToExcelFileMenuItem());
    return actionMenuItems;
}
```

Сохраняйте только нужные базовые actions. Полная очистка меню должна быть осознанной.

## Section filters and reload

Паттерн фильтра с сохранением состояния:

```javascript
onCheckboxChecked: function(value) {
    this.$NeedReloadData = true;
    this.set("IsActive", value);
    this.sandbox.publish("FiltersChanged", null, [this.sandbox.id]);
    this.set("ActiveRow", null);
    this.reloadGridData();
}
```

При смене фильтра очищайте `ActiveRow`, чтобы действия не применились к старой строке.

## Detail

`BaseDetailV2` и `BaseGridDetailV2` работают внутри master page.

```javascript
define("SocialAddressDetail", [
    "ConfigurationGrid",
    "ConfigurationGridGenerator",
    "ConfigurationGridUtilities"
], function() {
    return {
        messages: {},
        mixins: {},
        attributes: {},
        methods: {},
        diff: []
    };
});
```

## Detail sandbox flow

Деталь может запросить данные у страницы и дождаться broadcast-ответа.

```javascript
onGridDataLoaded: function() {
    this.callParent(arguments);
    var socialNetworkData = this.sandbox.publish("GetSocialNetworkData");
    if (!socialNetworkData) {
        this.sandbox.subscribe("SocialNetworkDataLoaded", this.onSocialNetworkDataLoaded, this);
    } else {
        this.onSocialNetworkDataLoaded(socialNetworkData);
    }
}
```

## updateDetail и reloadGridData

Если деталь зависит от внешнего состояния, используйте `updateDetail` или `reloadGridData`.

```javascript
_updateWebhookMethodDetail: function() {
    this.updateDetail({ reloadAll: true });
}
```

`reloadGridData` обновляет collection. `updateDetail({ reloadAll: true })` полезен, когда нужно пересоздать/перечитать конфигурацию детали.

## Custom row view model

Деталь может строить строки не из обычной entity collection, а из custom object model.

```javascript
_getRowViewModel: function(rowObject) {
    return this.Ext.create("BPMSoft.BaseViewModel", {
        columns: this._getRowViewModelColumns(),
        values: this._getRowViewModelValues(rowObject)
    });
}
```

Такой паттерн уместен для дизайнеров, webhook-конструкторов и runtime collections.

## Master card save before detail add

Перед добавлением записи в деталь новая master page должна быть сохранена.

```javascript
var masterCardState = this.sandbox.publish("GetCardState", null, [this.sandbox.id]);
if (masterCardState.state === configurationEnums.CardStateV2.ADD) {
    this.sandbox.publish("SaveRecord", { isSilent: true }, [this.sandbox.id]);
}
```

## Связанные документы

- [Client Module Overview](client-module-overview.md)
- [Client sandbox messages](client-sandbox-messages.md)
- [Client service calls](client-service-calls.md)
- [Страницы, секции и детали](pages-sections-details.md)
