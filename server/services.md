# WCF-сервисы конфигурации

<!-- Версия: 1.0 | Обновлено: 2026-03-19 | Платформа: BPMSoft 1.9 -->
<!-- Теги: сервисы, WCF, REST, ServiceContract, WebInvoke, ConfigurationServiceResponse -->

## Обзор

Серверная логика в BPMSoft предоставляется через WCF-сервисы с REST/JSON интерфейсом. Сервисы вызываются клиентом через `ServiceHelper`.

**Базовый URL:** `/0/rest/{ServiceName}/{MethodName}`
**Метод:** POST (почти всегда)
**Формат:** JSON

## Структура сервиса

```csharp
using System.ServiceModel;
using System.ServiceModel.Web;
using System.ServiceModel.Activation;
using System.Web;
using BPMSoft.Core;

namespace BPMSoft.Configuration
{
    [ServiceContract]
    [AspNetCompatibilityRequirements(RequirementsMode = AspNetCompatibilityRequirementsMode.Required)]
    public class MyService
    {
        private UserConnection _userConnection;

        private UserConnection UserConnection {
            get {
                return _userConnection ??
                    (_userConnection = (UserConnection)HttpContext.Current.Session["UserConnection"]);
            }
        }

        [OperationContract]
        [WebInvoke(Method = "POST",
            UriTemplate = "DoSomething",
            BodyStyle = WebMessageBodyStyle.Wrapped,
            RequestFormat = WebMessageFormat.Json,
            ResponseFormat = WebMessageFormat.Json)]
        public ConfigurationServiceResponse DoSomething(string paramName)
        {
            var response = new ConfigurationServiceResponse();
            try {
                // Бизнес-логика
            } catch (Exception e) {
                response.Exception = e;
            }
            return response;
        }
    }
}
```

## Атрибуты маршрутизации

| Атрибут | Назначение |
|---------|-----------|
| `[ServiceContract]` | Объявление WCF-контракта |
| `[OperationContract]` | Объявление метода контракта |
| `[DefaultServiceRoute]` | Маршрут по умолчанию (`/0/rest/...`) |
| `[SspServiceRoute]` | Маршрут для портала самообслуживания |
| `[WebInvoke]` | HTTP-метод, URI, формат |

## Параметры WebInvoke

```csharp
[WebInvoke(
    Method = "POST",                              // HTTP-метод
    UriTemplate = "MethodName",                   // URI-шаблон
    BodyStyle = WebMessageBodyStyle.Wrapped,       // Обёртка параметров
    RequestFormat = WebMessageFormat.Json,          // Формат запроса
    ResponseFormat = WebMessageFormat.Json          // Формат ответа
)]
```

### BodyStyle

| Значение | Описание |
|----------|----------|
| `Wrapped` | Параметры оборачиваются в JSON-объект: `{"param1": "val", "param2": "val"}` |
| `WrappedRequest` | Оборачивается только запрос |
| `Bare` | Без обёртки (один параметр = тело запроса) |

## ConfigurationServiceResponse

Стандартный DTO для ответов:

```csharp
public class ConfigurationServiceResponse : BaseResponse
{
    public bool Success { get; set; }
    public Exception Exception { get; set; }
    // Расширяется дополнительными полями
}
```

## Проверка прав

```csharp
[OperationContract]
[WebInvoke(Method = "POST", UriTemplate = "SecureMethod", ...)]
public ConfigurationServiceResponse SecureMethod()
{
    UserConnection.DBSecurityEngine.CheckCanExecuteOperation("CanManageAdministration");
    // Если нет прав — выбрасывается SecurityException
}
```

## Наследование от BaseService

Некоторые сервисы наследуют `BaseService`:

```csharp
public class AnalyticsService : BaseService, IReadOnlySessionState
{
    // BaseService предоставляет UserConnection автоматически
}
```

## Примеры сервисов из базового решения

### AdministrationService
```csharp
[ServiceContract]
[SspServiceRoute]
[DefaultServiceRoute]
public class AdministrationService
{
    // TerminateSession, GetLicenseInfo, AddUser и др.
}
```

### CalendarService
```csharp
[ServiceContract]
[DefaultServiceRoute]
public class CalendarService
{
    [OperationContract]
    [WebInvoke(Method = "POST", UriTemplate = "GetCalendarDays", ...)]
    public string GetCalendarDays(string calendarId, string startDate, string endDate) { ... }
}
```

## Вызов сервиса с клиента

```javascript
// Через ServiceHelper
BPMSoft.ServiceHelper.callService("MyService", "DoSomething", function(response) {
    if (response.Success) {
        // обработка
    }
}, { paramName: "value" }, this);

// Через Promise (async)
var result = await BPMSoft.ServiceHelper.callServiceAsync({
    serviceName: "MyService",
    methodName: "DoSomething",
    data: { paramName: "value" }
});
```

## REST-клиенты (исходящие запросы)

Для вызова внешних API:

```csharp
// RestSharp
var client = new RestClient("https://api.example.com");
var request = new RestRequest("/endpoint", Method.POST);
request.AddJsonBody(data);
var response = client.Execute(request);

// IWebServiceClient (встроенный)
var client = ClassFactory.Get<IWebServiceClient>();
var response = client.GetResponseJson(url, postData);
```

## Все ключевые сервисы базового решения

| Сервис | Пакет | Назначение |
|--------|-------|-----------|
| AdministrationService | UIv2 | Управление пользователями, ролями, лицензиями |
| AnalyticsService | Platform | Аналитические данные |
| ApprovalService | — | Согласования |
| CalendarService | Calendar | Календарные операции |
| CalendarOperationService | Calendar | Операции с рабочим временем |
| CollisionControlService | — | Контроль коллизий |
| ColumnService | — | Информация о колонках |
| CommandLineService | — | Командная строка |
| CompletenessService | — | Полнота заполнения |
| ConfigurationDataService | — | Конфигурационные данные |
| ContentBuilderService | — | Конструктор контента |
| CryptographicService | — | Шифрование |
| CurrencyRateService | — | Курсы валют |
| CurrentUserService | — | Данные текущего пользователя |
| BulkDeduplicationService | Deduplication | Массовая дедупликация |
| BSSchedulerService | — | Планировщик задач |

---

## Типовые сценарии

### 1. Создание простого POST-сервиса с одним параметром

```csharp
[ServiceContract]
[AspNetCompatibilityRequirements(RequirementsMode = AspNetCompatibilityRequirementsMode.Required)]
public class ContactService
{
    private UserConnection _userConnection;
    private UserConnection UserConnection =>
        _userConnection ?? (_userConnection =
            (UserConnection)HttpContext.Current.Session["UserConnection"]);

    [OperationContract]
    [WebInvoke(Method = "POST", UriTemplate = "GetContactName",
        BodyStyle = WebMessageBodyStyle.Wrapped,
        RequestFormat = WebMessageFormat.Json,
        ResponseFormat = WebMessageFormat.Json)]
    public string GetContactName(string contactId)
    {
        var esq = new EntitySchemaQuery(UserConnection.EntitySchemaManager, "Contact");
        esq.AddColumn("Name");
        var entity = esq.GetEntity(UserConnection, Guid.Parse(contactId));
        return entity?.GetTypedColumnValue<string>("Name") ?? string.Empty;
    }
}
```

### 2. Сервис с проверкой прав (CheckCanExecuteOperation)

```csharp
[OperationContract]
[WebInvoke(Method = "POST", UriTemplate = "DeactivateUser",
    BodyStyle = WebMessageBodyStyle.Wrapped,
    RequestFormat = WebMessageFormat.Json,
    ResponseFormat = WebMessageFormat.Json)]
public ConfigurationServiceResponse DeactivateUser(Guid userId)
{
    var response = new ConfigurationServiceResponse();
    try {
        UserConnection.DBSecurityEngine.CheckCanExecuteOperation("CanManageAdministration");
        var update = new Update(UserConnection, "SysAdminUnit")
            .Set("Active", Column.Parameter(false))
            .Where("Id").IsEqual(Column.Parameter(userId));
        update.Execute();
        response.Success = true;
    } catch (Exception e) {
        response.Exception = e;
    }
    return response;
}
```

### 3. Сервис, возвращающий список записей (ESQ → JSON)

```csharp
[OperationContract]
[WebInvoke(Method = "POST", UriTemplate = "GetActiveContacts",
    BodyStyle = WebMessageBodyStyle.Wrapped,
    RequestFormat = WebMessageFormat.Json,
    ResponseFormat = WebMessageFormat.Json)]
public ConfigurationServiceResponse GetActiveContacts(string cityName)
{
    var response = new ConfigurationServiceResponse();
    try {
        var esq = new EntitySchemaQuery(UserConnection.EntitySchemaManager, "Contact");
        esq.AddColumn("Name");
        esq.AddColumn("Email");
        esq.AddColumn("Phone");
        esq.Filters.Add(esq.CreateFilterWithParameters(
            FilterComparisonType.Equal, "City.Name", cityName));
        var collection = esq.GetEntityCollection(UserConnection);
        var result = collection.Select(c => new {
            Name = c.GetTypedColumnValue<string>("Name"),
            Email = c.GetTypedColumnValue<string>("Email"),
            Phone = c.GetTypedColumnValue<string>("Phone")
        }).ToList();
        response.SetResult(result);
    } catch (Exception e) {
        response.Exception = e;
    }
    return response;
}
```

### 4. Вызов сервиса с клиента через ServiceHelper

```javascript
// Callback-стиль
BPMSoft.ServiceHelper.callService("ContactService", "GetContactName",
    function(response) {
        if (response.GetContactNameResult) {
            this.set("ContactName", response.GetContactNameResult);
        }
    },
    { contactId: this.get("Id") },
    this
);

// Async/await-стиль
const response = await BPMSoft.ServiceHelper.callServiceAsync({
    serviceName: "ContactService",
    methodName: "GetActiveContacts",
    data: { cityName: "Москва" }
});
if (response.Success) {
    console.log(response.Result);
}
```

---

## Антипаттерны

### ❌ Не оборачивать логику в try/catch

Необработанное исключение вернёт клиенту HTTP 500 без полезной информации.

```csharp
// ❌ Плохо
[OperationContract]
[WebInvoke(Method = "POST", UriTemplate = "Process", ...)]
public ConfigurationServiceResponse Process(string data)
{
    var response = new ConfigurationServiceResponse();
    DoSomethingDangerous(data); // при исключении — 500 без деталей
    return response;
}

// ✅ Хорошо
[OperationContract]
[WebInvoke(Method = "POST", UriTemplate = "Process", ...)]
public ConfigurationServiceResponse Process(string data)
{
    var response = new ConfigurationServiceResponse();
    try {
        DoSomethingDangerous(data);
    } catch (Exception e) {
        response.Exception = e;
    }
    return response;
}
```

### ❌ Передавать UserConnection через параметр сервиса

UserConnection — серверный объект, привязанный к сессии. Передача извне — дыра в безопасности.

```csharp
// ❌ Плохо
public ConfigurationServiceResponse DoWork(string userConnectionId) { ... }

// ✅ Хорошо — получать из сессии
private UserConnection UserConnection =>
    (UserConnection)HttpContext.Current.Session["UserConnection"];
```

### ❌ Использовать GET для операций, изменяющих данные

GET-запросы кэшируются браузерами и прокси, могут повторяться при навигации.

```csharp
// ❌ Плохо
[WebInvoke(Method = "GET", UriTemplate = "DeleteRecord?id={id}", ...)]
public void DeleteRecord(string id) { ... }

// ✅ Хорошо
[WebInvoke(Method = "POST", UriTemplate = "DeleteRecord", ...)]
public ConfigurationServiceResponse DeleteRecord(Guid recordId) { ... }
```

### ❌ Забыть атрибут [AspNetCompatibilityRequirements]

Без этого атрибута `HttpContext.Current.Session` вернёт `null`, и `UserConnection` будет недоступен.

```csharp
// ❌ Плохо
[ServiceContract]
public class MyService { ... } // Session = null

// ✅ Хорошо
[ServiceContract]
[AspNetCompatibilityRequirements(RequirementsMode = AspNetCompatibilityRequirementsMode.Required)]
public class MyService { ... }
```

---

## Troubleshooting

### Таблица ошибок

| Ошибка | Причина | Решение |
|--------|---------|---------|
| `404 Not Found` | Отсутствует `[ServiceContract]` или `[DefaultServiceRoute]` | Добавить оба атрибута к классу сервиса |
| `UserConnection is null` | Нет `[AspNetCompatibilityRequirements]` или вызов вне сессии | Добавить атрибут, убедиться что клиент аутентифицирован |
| `405 Method Not Allowed` | Несоответствие HTTP-метода в `[WebInvoke]` и запросе | Проверить `Method` в атрибуте (`POST` vs `GET`) |
| Параметры приходят `null` | Неверный `BodyStyle` или формат JSON | Для нескольких параметров — `Wrapped`, для одного — `Bare`; проверить `Content-Type: application/json` |
| `SerializationException` | Тип ответа не сериализуется в JSON | Использовать простые типы или `DataContract`-классы |
| `SecurityException` | Нет прав на операцию | Проверить `SysOperationGrantee` для нужной операции |

### Советы по отладке

- Используйте Fiddler/Postman для тестирования запросов к `/0/rest/{Service}/{Method}`.
- Проверяйте `Content-Type: application/json` в заголовках запроса.
- При `BodyStyle = Wrapped` параметры оборачиваются в JSON-объект: `{"paramName": "value"}`.
- Логируйте ошибки через `_log.Error()` или `BPMSoft.Core.Log.LogManager`.

### Известные ограничения

- WCF-сервисы BPMSoft не поддерживают потоковую передачу (streaming).
- Максимальный размер запроса ограничен конфигурацией IIS (`maxRequestLength`).
- `SspServiceRoute` доступен только для портальных пользователей — для внутренних используйте `DefaultServiceRoute`.

---

## Связанные темы

- [Утилиты (ServiceHelper)](../client/utilities.md)
- [Архитектура](../architecture/platform-overview.md)
- [EventListener'ы](event-listeners.md)
- [Перечисления](../reference/enums-constants.md)
