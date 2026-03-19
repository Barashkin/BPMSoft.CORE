# Архитектура платформы BPMSoft

<!-- Версия: 1.0 | Обновлено: 2026-03-19 | Платформа: BPMSoft 1.9 -->
<!-- Теги: архитектура, обзор, UserConnection, пакеты, клиент-сервер -->

## Общая структура

BPMSoft — платформа low-code для построения CRM и BPM-решений. Архитектура разделена на серверную (C#/.NET) и клиентскую (JavaScript/ExtJS) части.

```
┌─────────────────────────────────────────────┐
│              Клиент (Browser)               │
│  ┌────────┐ ┌─────────┐ ┌───────────────┐  │
│  │ Pages  │ │Sections │ │   Details      │  │
│  └───┬────┘ └────┬────┘ └──────┬────────┘  │
│      └───────────┼─────────────┘            │
│           ┌──────┴──────┐                   │
│           │  AMD Modules│                   │
│           │  (RequireJS)│                   │
│           └──────┬──────┘                   │
│           ┌──────┴──────┐                   │
│           │  BPMSoft.js │                   │
│           │  (Core SDK) │                   │
│           └──────┬──────┘                   │
├──────────────────┼──────────────────────────┤
│         REST/WCF │ JSON                     │
├──────────────────┼──────────────────────────┤
│              Сервер (.NET)                  │
│  ┌────────────┐ ┌────────────┐              │
│  │ WCF Services│ │ EventListeners│           │
│  └─────┬──────┘ └─────┬──────┘              │
│        └──────┬───────┘                     │
│        ┌──────┴──────┐                      │
│        │   ESQ / ORM  │                     │
│        └──────┬──────┘                      │
│        ┌──────┴──────┐                      │
│        │Entity Schemas│                     │
│        └──────┬──────┘                      │
│        ┌──────┴──────┐                      │
│        │  Database    │                     │
│        └─────────────┘                      │
└─────────────────────────────────────────────┘
```

## Пакетная система

Код организован в **пакеты** (packages). Каждый пакет — модуль функциональности, который может зависеть от других пакетов.

Файлы именуются по конвенции: `ИмяКласса.Пакет.расширение`

Пример: `AccountSchema.Base.cs` — схема Account из пакета Base.

### Иерархия пакетов (основные)

```
Base                    — ядро: сущности, утилиты, базовые классы
├── NUI                 — основной UI-фреймворк (страницы, секции, детали)
│   ├── UIv2            — расширенный UI
│   ├── SSP             — портал самообслуживания
│   └── CTIBase         — интеграция с телефонией
├── ProcessDesigner     — дизайнер бизнес-процессов
├── FileImport          — импорт файлов
├── Deduplication       — дедупликация
├── OmnichannelMessaging — омниканальные коммуникации
├── ML                  — машинное обучение
├── Calendar            — календарь и рабочее время
├── ESN                 — корпоративная соц. сеть
├── GlobalSearch        — глобальный поиск
└── ContentBuilder      — конструктор контента
```

## Серверная часть

### Ключевые компоненты

| Компонент | Назначение | Пространство имён |
|-----------|-----------|-------------------|
| **Entity Schema** | Описание структуры данных (таблица БД) | `BPMSoft.Configuration` |
| **Entity** | Экземпляр записи сущности | `BPMSoft.Core.Entities` |
| **EntitySchemaQuery (ESQ)** | ORM-запросы к данным | `BPMSoft.Core.Entities` |
| **EventListener** | Обработка событий сущностей/приложения | `BPMSoft.Core.Entities.Events` |
| **Service** | WCF-сервисы (REST API) | `BPMSoft.Configuration` |
| **Process/UserTask** | Элементы бизнес-процессов | `BPMSoft.Core.Process` |
| **UserConnection** | Контекст текущего пользователя | `BPMSoft.Core` |

### UserConnection

Центральный объект контекста. Доступен везде на сервере:

```csharp
// В сервисе
UserConnection userConnection = (UserConnection)HttpContext.Current.Session["UserConnection"];

// В EventListener
UserConnection userConnection = entity.UserConnection;

// В процессе
UserConnection userConnection = Get<ProcessSchemaUserConnection>("UserConnection");
```

Предоставляет:
- `DBSecurityEngine` — проверка прав доступа
- `SessionData` — данные сессии
- `CurrentUser` — текущий пользователь
- `SystemValueManager` — системные значения
- `AppConnection` — подключение к приложению

## Клиентская часть

### Ключевые компоненты

| Компонент | Назначение |
|-----------|-----------|
| **AMD Module** | Единица кода (define/require через RequireJS) |
| **Page (BasePageV2)** | Страница карточки записи |
| **Section (BaseSectionV2)** | Раздел (список + карточка) |
| **Detail (BaseDetailV2)** | Деталь — вложенный список на странице |
| **Mixin** | Переиспользуемый набор методов |
| **Sandbox** | Шина сообщений между модулями |
| **diff** | Декларативное описание UI-изменений |

### Объект BPMSoft

Глобальный объект платформы на клиенте:

```javascript
BPMSoft.DataValueType    // типы данных
BPMSoft.MessageMode      // PTP, BROADCAST
BPMSoft.MessageDirectionType  // PUBLISH, SUBSCRIBE, BIDIRECTIONAL
BPMSoft.AjaxProvider     // HTTP-запросы
BPMSoft.utils            // утилиты
```

## Взаимодействие клиент-сервер

```
[Клиент]                         [Сервер]
ServiceHelper.callService() ──→ [ServiceContract] WCF Service
       ↑                              │
   JSON response              UserConnection + ESQ
       └──────────────────────────────┘
```

URL паттерн: `/0/rest/{ServiceName}/{MethodName}` (POST, JSON).

## Жизненный цикл запроса

Путь HTTP-запроса от браузера до базы данных и обратно:

```
1. Клиент: ServiceHelper.callService("ServiceName", "MethodName", callback, data)
       │
       ▼
2. HTTP POST /0/rest/{ServiceName}/{MethodName}
   Content-Type: application/json
       │
       ▼
3. WCF Routing → находит [ServiceContract] по URL
       │
       ▼
4. ServiceContract: метод сервиса получает управление
   UserConnection = (UserConnection)HttpContext.Current.Session["UserConnection"]
       │
       ▼
5. Бизнес-логика: ESQ / Entity для работы с данными
   var esq = new EntitySchemaQuery(userConnection.EntitySchemaManager, "Contact");
       │
       ▼
6. Database: SQL-запрос с учётом прав доступа (DBSecurityEngine)
       │
       ▼
7. Результат → Entity/EntityCollection → сериализация в JSON
       │
       ▼
8. HTTP Response (JSON) → клиентский callback
```

Пример полного цикла:

```csharp
// Сервер: сервис
[ServiceContract]
[AspNetCompatibilityRequirements(RequirementsMode = AspNetCompatibilityRequirementsMode.Required)]
public class ContactService : BaseService
{
    [OperationContract]
    [WebInvoke(Method = "POST", UriTemplate = "GetContactName",
        BodyStyle = WebMessageBodyStyle.Wrapped, ResponseFormat = WebMessageFormat.Json)]
    public string GetContactName(Guid contactId) {
        var esq = new EntitySchemaQuery(UserConnection.EntitySchemaManager, "Contact");
        esq.AddColumn("Name");
        var entity = esq.GetEntity(UserConnection, contactId);
        return entity?.GetTypedColumnValue<string>("Name") ?? string.Empty;
    }
}
```

```javascript
// Клиент: вызов
BPMSoft.AjaxProvider.request({
    url: BPMSoft.workspaceBaseUrl + "/rest/ContactService/GetContactName",
    jsonData: { contactId: "00000000-0000-0000-0000-000000000001" },
    callback: function(request, success, response) {
        var result = BPMSoft.decode(response.responseText);
        console.log("Contact name:", result.GetContactNameResult);
    }
});
```

## Точки расширения

Места, где разработчики могут расширить платформу:

| Точка расширения | Слой | Назначение |
|-----------------|------|-----------|
| **EntityEventListener** | Сервер | Обработка событий CRUD-операций над сущностями (`OnInserting`, `OnSaving`, `OnDeleting` и др.) |
| **AppEventListener** | Сервер | Обработка событий жизненного цикла приложения (`OnAppStart`, `OnAppEnd`, `OnSessionStart`) |
| **WCF Services** | Сервер | Создание REST API-эндпоинтов через `[ServiceContract]` + `[OperationContract]` |
| **EventsProcess** | Сервер | Бизнес-процессы, привязанные к событиям сущностей (сигналы) |
| **AMD module override (замещение)** | Клиент | Замещение клиентского модуля в дочернем пакете — платформа загружает последнюю версию по цепочке зависимостей |
| **Mixin injection** | Клиент | Внедрение переиспользуемой логики в модули через `mixins` в `define` |
| **diff merge/remove** | Клиент | Изменение UI через массив `diff`: добавление (`insert`), изменение (`merge`), удаление (`remove`) элементов |

Пример замещения AMD-модуля:

```javascript
// ContactPageV2 в кастомном пакете замещает базовый модуль
define("ContactPageV2", [], function() {
    return {
        entitySchemaName: "Contact",
        diff: [
            {
                "operation": "merge",
                "name": "Name",
                "values": { "enabled": false }
            }
        ],
        methods: {
            onEntityInitialized: function() {
                this.callParent(arguments);
                // кастомная логика
            }
        }
    };
});
```

---

## Типовые сценарии

### 1. Получение UserConnection в разных контекстах

```csharp
// В WCF-сервисе (наследник BaseService)
public class MyService : BaseService
{
    public string DoWork() {
        // BaseService предоставляет свойство UserConnection
        var uc = UserConnection;
        return uc.CurrentUser.ContactName;
    }
}

// В EntityEventListener
[EntityEventListener(SchemaName = "Contact")]
public class ContactEvtListener : BaseEntityEventListener
{
    public override void OnSaving(object sender, EntityBeforeEventArgs e) {
        var entity = (Entity)sender;
        var uc = entity.UserConnection;
    }
}

// В бизнес-процессе (ScriptTask)
var uc = Get<UserConnection>("UserConnection");
var esq = new EntitySchemaQuery(uc.EntitySchemaManager, "Account");
```

### 2. Определение зависимостей пакетов

При создании нового пакета необходимо правильно указать зависимости:

```
MyCustomPackage
├── зависит от: Base, NUI, UIv2
├── файлы:
│   ├── AccountPageV2.MyCustomPackage.js   ← замещает страницу из UIv2
│   └── MyService.MyCustomPackage.cs       ← новый сервис
└── descriptor.json:
    {
      "Descriptor": {
        "DependsOn": ["Base", "NUI", "UIv2"]
      }
    }
```

Порядок загрузки пакетов определяется графом зависимостей. Если пакет A зависит от B, все схемы из B загружаются раньше A.

### 3. Вызов серверного метода с клиента

```javascript
// Используем ServiceHelper — предпочтительный способ
define("MyModule", ["ServiceHelper"], function(ServiceHelper) {
    return {
        methods: {
            callMyService: function() {
                ServiceHelper.callService(
                    "MyService",         // имя сервиса
                    "GetData",           // имя метода
                    function(response) { // callback
                        var result = response.GetDataResult;
                        this.set("MyAttribute", result);
                    },
                    { id: this.get("Id") }, // параметры
                    this                    // scope
                );
            }
        }
    };
});
```

### 4. Создание ESQ-запроса с фильтрами

```csharp
var esq = new EntitySchemaQuery(userConnection.EntitySchemaManager, "Contact");
var nameCol = esq.AddColumn("Name");
esq.AddColumn("Account.Name");
esq.Filters.Add(esq.CreateFilterWithParameters(
    FilterComparisonType.Equal, "City.Name", "Москва"));
var collection = esq.GetEntityCollection(userConnection);
foreach (var entity in collection) {
    var name = entity.GetTypedColumnValue<string>(nameCol.Name);
}
```

---

## Антипаттерны

### Хранение UserConnection в статических полях

```csharp
// НЕПРАВИЛЬНО — UserConnection привязан к сессии конкретного пользователя
public static class MyHelper
{
    private static UserConnection _uc; // утечка между потоками/сессиями

    public static void Init(UserConnection uc) {
        _uc = uc; // другой пользователь получит чужой контекст
    }
}
```

**Почему опасно:** UserConnection содержит данные сессии, права текущего пользователя. Статическое хранение приводит к утечке контекста между запросами разных пользователей и нарушению потокобезопасности.

**Правильно:** передавать UserConnection как параметр метода.

### Обращение к HttpContext.Current вне WCF-контекста

```csharp
// НЕПРАВИЛЬНО — в EventListener/Process нет HTTP-контекста
[EntityEventListener(SchemaName = "Contact")]
public class ContactListener : BaseEntityEventListener
{
    public override void OnSaving(object sender, EntityBeforeEventArgs e) {
        // HttpContext.Current == null здесь!
        var uc = (UserConnection)HttpContext.Current.Session["UserConnection"];
    }
}
```

**Почему опасно:** EventListener может вызываться из фонового процесса, где нет HTTP-контекста. Результат — `NullReferenceException`.

**Правильно:** использовать `entity.UserConnection`.

### Прямые SQL-запросы вместо ESQ

```csharp
// НЕПРАВИЛЬНО — обход системы прав и событий
using (var command = userConnection.EnsureDBConnection().CreateCommand()) {
    command.CommandText = "UPDATE Contact SET Name = 'Test' WHERE Id = @id";
    // нет проверки прав, нет срабатывания EventListener, нет аудита
}
```

**Почему опасно:** ESQ обеспечивает проверку прав (`DBSecurityEngine`), срабатывание событий (`EventListener`), аудит и логирование. Прямой SQL всё это обходит.

**Правильно:** использовать ESQ или Entity для операций с данными.

---

## Troubleshooting

### Типичные ошибки

| Ошибка | Причина | Решение |
|--------|---------|---------|
| `UserConnection = null` | Нет активной сессии или неправильный контекст получения (например, `HttpContext.Current` в EventListener) | Проверить источник UserConnection: в сервисе — `BaseService.UserConnection`, в EventListener — `entity.UserConnection`, в процессе — `Get<UserConnection>("UserConnection")` |
| `404` на `/0/rest/{Service}/{Method}` | Сервис не зарегистрирован: отсутствуют атрибуты `[ServiceContract]`, `[OperationContract]`, `[WebInvoke]` или не указан `[AspNetCompatibilityRequirements]` | Проверить наличие всех атрибутов на классе и методе; убедиться, что сервис скомпилирован в пакете |
| Изменения в серверном коде не применяются | Кэш компиляции или пакет не перекомпилирован | Перекомпилировать пакет: Конфигурация → Действия → Компилировать всё / компилировать изменённые пакеты. Очистить Redis-кэш при необходимости |
| `AjaxProvider` возвращает HTML вместо JSON | Сессия истекла, сервер перенаправляет на страницу логина | Проверить авторизацию; в callback проверять `success` и `response.status` |
| `The service '...' is not registered` | Класс сервиса не унаследован от `BaseService` или сборка не загружена | Убедиться в наследовании от `BaseService`, проверить зависимости пакета |

### Советы по отладке

- **Серверные логи:** `...\BPMSoft\Logs\Common.log` — ошибки серверной части.
- **Браузер DevTools → Network:** просмотр запросов к `/0/rest/` и `/0/dataservice/` — тела запросов и ответов.
- **Отладка C#:** подключить Visual Studio к процессу `w3wp.exe` (IIS) или `BPMSoft.WebHost.exe`.
- **Отладка JS:** точки останова в DevTools → Sources, поиск модуля по имени в `configuration/`.
- **ESQ Debug:** `esq.GetSelectQuery(userConnection).GetSqlText()` — получить SQL-текст для анализа.

### Известные ограничения

- Максимальный размер JSON-запроса ограничен настройками WCF (`maxReceivedMessageSize`).
- ESQ не поддерживает `GROUP BY` / агрегацию нескольких колонок напрямую — используйте `Select` из `BPMSoft.Core.DB`.
- Замещение AMD-модуля полностью перезаписывает модуль — нельзя «частично» заместить, нужно повторить всю структуру `define`.

---

## Связанные темы

- [Схемы сущностей (Entity Schemas)](../server/entity-schemas.md)
- [WCF-сервисы](../server/services.md)
- [Обработчики событий (EventListeners)](../server/event-listeners.md)
- [Клиентские AMD-модули](../client/modules.md)
- [Конвенции именования](naming-conventions.md)
