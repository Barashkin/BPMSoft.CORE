# Client Diff, Attributes And Rules

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: diff, attributes, rules, businessRules, validation -->

> Как описывать UI через `diff`, хранить состояние в `attributes` и задавать business rules/validation.

## attributes

Attributes — это колонки client view model. Они могут отражать реальные entity columns или быть virtual state.

```javascript
attributes: {
    "IsActive": {
        dataValueType: BPMSoft.DataValueType.BOOLEAN,
        type: BPMSoft.ViewModelColumnType.VIRTUAL_COLUMN,
        value: false
    },
    "ArchivalButtonMenuItems": {
        dataValueType: BPMSoft.DataValueType.COLLECTION
    }
}
```

Используйте `$AttributeName` для краткого доступа только там, где это соответствует стилю файла.

## onChange

Attribute может вызывать handler при изменении.

```javascript
AuthTypeLookup: {
    dataValueType: BPMSoft.DataValueType.LOOKUP,
    type: BPMSoft.ViewModelColumnType.VIRTUAL_COLUMN,
    onChange: "_onAuthTypeLookupChange",
    isRequired: true
}
```

## diff

`diff` декларативно меняет UI.

```javascript
diff: [
    {
        "operation": "insert",
        "name": "SyncButton",
        "parentName": "CombinedModeActionButtonsCardLeftContainer",
        "propertyName": "items",
        "values": {
            "itemType": BPMSoft.ViewItemType.BUTTON,
            "caption": { "bindTo": "Resources.Strings.SyncButtonCaption" },
            "click": { "bindTo": "startInsightSync" },
            "visible": true
        }
    }
]
```

## diff operations

| Operation | Назначение |
| --------- | ---------- |
| `insert` | добавить новый UI element |
| `merge` | изменить существующий element |
| `remove` | удалить element |
| `move` | переместить element |

Для `insert` задавайте стабильный `name`, корректный `parentName` и `propertyName`.

## rules

Ручные rules используют `BusinessRuleModule`.

```javascript
rules: {
    "ObservedSchema": {
        "BindParameterVisibleActivityCategoryToType": {
            ruleType: BusinessRuleModule.enums.RuleType.BINDPARAMETER,
            property: BusinessRuleModule.enums.Property.VISIBLE,
            conditions: []
        }
    }
}
```

## businessRules

`businessRules` часто содержит сериализованное дерево правил дизайнера.

```javascript
businessRules: /**SCHEMA_BUSINESS_RULES*/{
    "ObservedSchema": {
        "2121c474-be6a-4dcb-9e83-ae8eb5b87d66": {
            "enabled": true,
            "ruleType": 1,
            "baseAttributePatch": "ManagerName"
        }
    }
}/**SCHEMA_BUSINESS_RULES*/
```

Не редактируйте большие generated rules вручную без необходимости: лучше менять правило через designer, если оно принадлежит designer metadata.

## validation

Validation подключается через `setValidationConfig`.

```javascript
setValidationConfig: function() {
    this.callParent(arguments);
    this.addColumnValidator("Priority", this.priorityValidator);
}
```

Validator возвращает объект:

```javascript
numberIsPositiveValidator: function(value) {
    var invalidMessage = "";
    if (!Ext.isEmpty(value) && value < 1) {
        invalidMessage = this.get("Resources.Strings.NumberIsNotPositiveMessage");
    }
    return { invalidMessage: invalidMessage };
}
```

## Практические правила

- Для UI state используйте virtual attributes.
- Для вычисляемой видимости используйте binding method или business rule.
- Для сложной domain validation добавляйте server-side проверку.
- Не смешивайте generated `businessRules` и ручные `rules` без причины.
- Для `diff` избегайте duplicate `name` в одном parent scope.

## Связанные документы

- [Client AMD module anatomy](client-amd-module-anatomy.md)
- [Client page lifecycle](client-page-lifecycle.md)
- [Client troubleshooting](client-troubleshooting.md)
- [Модули](modules.md)
