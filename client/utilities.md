# Утилиты и вспомогательные модули

<!-- Версия: 1.0 | Обновлено: 2026-03-19 | Платформа: BPMSoft 1.9 -->
<!-- Теги: ServiceHelper, RightUtilities, ConfigurationEnums, ConfigurationConstants, ProcessModuleUtilities -->

## ServiceHelper — вызов серверных сервисов

**Файл:** `ServiceHelper.NUI.js`

Главный инструмент клиент-серверного взаимодействия.

### Основные методы

```javascript
// Синхронный вызов с callback
BPMSoft.ServiceHelper.callService(
    "ServiceName",           // имя сервиса
    "MethodName",            // имя метода
    function(response) {     // callback
        if (response.Success) {
            // обработка результата
        }
    },
    { param1: "value" },     // данные запроса
    this                     // scope
);

// Асинхронный вызов (Promise)
var result = await BPMSoft.ServiceHelper.callServiceAsync({
    serviceName: "ServiceName",
    methodName: "MethodName",
    data: { param1: "value" }
});

// Вызов Core-сервиса
BPMSoft.ServiceHelper.callCoreService(config, callback, scope);
```

### URL-формирование

```javascript
// Получить базовый URL
var url = BPMSoft.ServiceHelper.buildConfigurationUrl("ServiceName", "MethodName");
// Результат: "/0/rest/ServiceName/MethodName"
```

### Внутренний механизм

Использует `BPMSoft.AjaxProvider.request()` для HTTP-запросов. Метод — всегда POST, формат — JSON.

## RightUtilities — проверка прав

**Файл:** `RightUtilities.NUI.js`

### Проверка прав на операцию

```javascript
var RightUtilities = require("RightUtilities");

RightUtilities.checkCanExecuteOperation({
    operation: "CanManageAdministration"
}, function(result) {
    // result = true/false
}, this);
```

### Проверка прав на схему

```javascript
RightUtilities.getSchemaOperationRightLevel("Contact", function(rightLevel) {
    var canRead = (rightLevel & RightUtilities.SchemaOperationRightLevels.CanRead) !== 0;
    var canEdit = (rightLevel & RightUtilities.SchemaOperationRightLevels.CanEdit) !== 0;
});
```

### Проверка прав на запись

```javascript
RightUtilities.getSchemaRecordRightLevel("Contact", recordId, function(rightLevel) {
    var canRead = (rightLevel & RightUtilities.RecordOperationRightLevels.CanRead) !== 0;
});
```

### Уровни прав

```javascript
SchemaOperationRightLevels: {
    None: 0,
    CanRead: 1,
    CanAppend: 2,
    CanEdit: 4,
    CanDelete: 8
}

RecordOperationRightLevels: {
    None: 0,
    CanRead: 1,
    CanEdit: 2,
    CanDelete: 4
}
```

## ConfigurationEnums — перечисления

**Файл:** `ConfigurationEnums.NUI.js`

### Основные перечисления

```javascript
BPMSoft.ConfigurationEnums = {
    GridType: {
        LISTED: "listed",       // табличный вид
        TILED: "tiled"          // плиточный вид
    },

    CardState: {
        VIEW: "view",
        EDIT: "edit",
        ADD: "add",
        COPY: "copy",
        DELETE: "delete"
    },

    CardStateV2: {
        ADD: "add",
        EDIT: "edit",
        COPY: "copy"
    },

    EntitySchemaColumnUsageType: {
        General: 0,
        Advanced: 1,
        None: 2
    },

    WorkAreaMode: {
        SECTION: 0,
        CARD: 1,
        COMBINED: 2
    }
};
```

## ConfigurationConstants — константы

**Файл:** `ConfigurationConstants.NUI.js`

### Activity (константы активностей)

```javascript
BPMSoft.ConfigurationConstants.Activity = {
    Type: {
        Task: "fbe0acdc-cfc0-df11-b00f-001d60e938c6",
        Email: "e2831dec-cfc0-df11-b00f-001d60e938c6",
        Call: "e1831dec-cfc0-df11-b00f-001d60e938c6"
    },
    Status: {
        NotStarted: "384d4b84-58e6-df11-971b-001d60e938c6",
        InProgress: "394d4b84-58e6-df11-971b-001d60e938c6",
        Done: "4bdbb88f-58e6-df11-971b-001d60e938c6",
        Cancelled: "201cfba8-58e6-df11-971b-001d60e938c6"
    },
    ActivityCategory: {
        DoNot: "f51c4643-58e6-df11-971b-001d60e938c6"
    },
    ParticipantRole: {
        Responsible: "53fc4a92-b0ea-e111-96c4-00165d094c12",
        Participant: "34b9a615-b0ea-e111-96c4-00165d094c12"
    }
};
```

### CommunicationTypes

```javascript
BPMSoft.ConfigurationConstants.CommunicationType = {
    Phone: "6a3fb10c-67cc-df11-9b2a-001d60e938c6",
    Email: "ee1c85c3-cfcb-df11-9b2a-001d60e938c6",
    Skype: "...",
    Facebook: "...",
    LinkedIn: "...",
    Twitter: "...",
    Web: "...",
    Fax: "...",
    MobilePhone: "d4a2dc80-30ca-df11-9b2a-001d60e938c6"
};
```

### AddressTypes

```javascript
BPMSoft.ConfigurationConstants.AddressType = {
    Home: "...",
    Legal: "...",
    Actual: "...",
    Delivery: "..."
};
```

## GridUtilities — работа с гридом

**Файл:** `GridUtilities.NUI.js`

```javascript
// Загрузка данных в грид
this.loadGridData();

// Перезагрузка
this.reloadGridData();

// Получить выбранную запись
var activeRow = this.get("ActiveRow");
var gridData = this.get("GridData");
var selectedItem = gridData.get(activeRow);
```

## NetworkUtilities — сеть

**Файл:** `NetworkUtilities.NUI.js`

Обёртки для HTTP-запросов, проверка соединения.

## EmailUtilitiesV2 — email

**Файл:** `EmailUtilitiesV2.UIv2.js`

Утилиты для работы с email: формирование, отправка, шаблоны.

## TimezoneUtils — часовые пояса

**Файл:** `TimezoneUtils.UIv2.js`

Конвертация дат между часовыми поясами.

## ProcessModuleUtilities — процессы

**Файл:** `ProcessModuleUtilities.NUI.js`

Запуск и управление бизнес-процессами с клиента:

```javascript
// Запуск процесса
BPMSoft.ProcessModuleUtilities.executeProcess({
    sysProcessName: "MyProcess",
    parameters: {
        ContactId: contactId
    },
    callback: function() {
        // процесс запущен
    },
    scope: this
});
```

## ChangeLogUtilities — журнал изменений

**Файл:** `ChangeLogUtilities.NUI.js`

Просмотр истории изменений записи.

## TagUtilitiesV2 — теги

**Файл:** `TagUtilitiesV2.NUI.js`

Работа с тегами записей.

## MaskHelper — маска загрузки

**Файл:** `MaskHelper.NUI.js`

```javascript
// Показать маску
var maskId = BPMSoft.Mask.show();

// Скрыть
BPMSoft.Mask.hide(maskId);
```

---

## Типовые сценарии

### 1. Вызов WCF-сервиса через ServiceHelper

```javascript
var config = {
    serviceName: "MyConfigurationService",
    methodName: "GetData",
    data: {
        entityName: "Contact",
        recordId: this.get("Id")
    }
};
BPMSoft.ServiceHelper.callService(config.serviceName, config.methodName,
    function(response) {
        if (response && response.GetDataResult) {
            var result = response.GetDataResult;
            this.set("ServiceData", result);
        }
    }, config.data, this);
```

### 2. Проверка прав на операцию

```javascript
var RightUtilities = require("RightUtilities");
RightUtilities.checkCanExecuteOperation({
    operation: "CanExportGrid"
}, function(result) {
    this.set("CanExport", result);
    if (!result) {
        this.showInformationDialog("Нет прав на экспорт");
    }
}, this);
```

### 3. Проверка прав на запись

```javascript
var RightUtilities = require("RightUtilities");
var recordId = this.get("Id");
RightUtilities.getSchemaRecordRightLevel("Contact", recordId, function(rightLevel) {
    var canEdit = (rightLevel & RightUtilities.RecordOperationRightLevels.CanEdit) !== 0;
    this.set("IsEditable", canEdit);
}, this);
```

### 4. Запуск бизнес-процесса с клиента

```javascript
BPMSoft.ProcessModuleUtilities.executeProcess({
    sysProcessName: "SendNotificationProcess",
    parameters: {
        ContactId: this.get("Id"),
        Message: "Уведомление отправлено"
    },
    callback: function() {
        this.showInformationDialog("Процесс запущен");
    },
    scope: this
});
```

### 5. Показ/скрытие маски загрузки

```javascript
onLoadData: function() {
    var maskId = BPMSoft.Mask.show({
        caption: "Загрузка данных..."
    });
    BPMSoft.ServiceHelper.callService("MyService", "LoadData",
        function(response) {
            BPMSoft.Mask.hide(maskId);
            if (response && response.Success) {
                this.processData(response.Result);
            }
        }.bind(this), {}, this);
}
```

---

## Антипаттерны

❌ **Синхронные HTTP-запросы** — блокируют UI.

```javascript
// ❌ Плохо — XMLHttpRequest в синхронном режиме
var xhr = new XMLHttpRequest();
xhr.open("GET", url, false);
xhr.send();

// ✅ Правильно — через ServiceHelper (асинхронно)
BPMSoft.ServiceHelper.callService("ServiceName", "Method", callback, data, this);
```

❌ **Не проверять response.Success после callService.**

```javascript
// ❌ Плохо — сразу используем данные без проверки
BPMSoft.ServiceHelper.callService("Svc", "Method", function(response) {
    this.set("Data", response.Result);
}, {}, this);

// ✅ Правильно — проверяем успешность
BPMSoft.ServiceHelper.callService("Svc", "Method", function(response) {
    if (response && response.Success) {
        this.set("Data", response.Result);
    } else {
        this.showInformationDialog("Ошибка: " + (response.ErrorInfo || "неизвестная"));
    }
}, {}, this);
```

❌ **Жёстко зашитые URL сервисов вместо ServiceHelper.**

```javascript
// ❌ Плохо
fetch("/0/rest/MyService/GetData", { method: "POST", body: JSON.stringify(data) });

// ✅ Правильно
BPMSoft.ServiceHelper.callService("MyService", "GetData", callback, data, scope);
```

❌ **Забыть скрыть маску загрузки в callback ошибки.**

```javascript
// ❌ Плохо — при ошибке маска остаётся навсегда
var maskId = BPMSoft.Mask.show();
this.callService(function(response) {
    BPMSoft.Mask.hide(maskId);
    this.processData(response);
});

// ✅ Правильно — скрываем маску в любом случае
var maskId = BPMSoft.Mask.show();
this.callService(function(response) {
    BPMSoft.Mask.hide(maskId);
    if (response.Success) {
        this.processData(response);
    }
}, function(error) {
    BPMSoft.Mask.hide(maskId);
    this.showError(error);
});
```

---

## Troubleshooting

| Проблема | Причина | Решение |
|----------|---------|---------|
| `callService` возвращает пустой ответ | Неверное имя сервиса или метода (регистрозависимы) | Проверить точное имя сервиса/метода, сверить с `[OperationContract]` |
| Права всегда `false` | Операция не привязана к роли | Проверить `SysAdminOperation` и привязку к роли в разделе «Администрирование» |
| Маска загрузки не исчезает | Забыт `Mask.hide()` в error callback | Добавить `BPMSoft.Mask.hide(maskId)` во все ветки callback |

**Советы по отладке:**

- DevTools → Network → фильтр `rest/` — отследить запросы и ответы сервисов.
- `BPMSoft.ServiceHelper.buildConfigurationUrl("Svc", "Method")` — проверить формируемый URL.
- При ошибке 403 — проверить `SysAdminOperation` и `SysAdminOperationGrantee`.

---

## Связанные темы

- [WCF-сервисы](../server/services.md)
- [AMD-модули](modules.md)
- [Страницы и секции](pages-sections-details.md)
- [Перечисления и константы](../reference/enums-constants.md)
