# Бизнес-процессы и UserTask'и

<!-- Версия: 1.0 | Обновлено: 2026-03-19 | Платформа: BPMSoft 1.9 -->
<!-- Теги: процессы, UserTask, бизнес-процесс, AddData, ReadData, ChangeData, ScriptTask -->

## Обзор

Бизнес-процессы (BP) в BPMSoft состоят из элементов: стартовых событий, UserTask'ов, ScriptTask'ов, шлюзов (Gateway) и потоков (SequenceFlow). Процессы могут быть настроены визуально в Process Designer или описаны в коде.

**Пространство имён:** `BPMSoft.Core.Process`
**Базовый класс элемента:** `ProcessUserTask`

## Архитектура процесса

```
ProcessSchema                    — описание схемы (метаданные)
    │
    ▼
Process                          — класс процесса
    ├── FlowElements             — коллекция элементов
    │   ├── StartEvent
    │   ├── UserTask1FlowElement — конкретный UserTask
    │   ├── ScriptTask1          — скриптовая задача
    │   ├── Gateway1             — шлюз
    │   └── SequenceFlow1        — поток
    └── Parameters               — параметры процесса
```

## Инициализация процесса

```csharp
public class MyProcess : Process
{
    public override void InitializeFlowElements()
    {
        FlowElements[addDataTask.SchemaElementUId] = addDataTask;
        FlowElements[readDataTask.SchemaElementUId] = readDataTask;
        // ...
    }
}
```

## Основные UserTask'и

### AddDataUserTask — добавление записи

| Параметр | Тип | Направление | Описание |
|----------|-----|-------------|----------|
| `EntitySchemaId` | Guid | Вход | Схема сущности |
| `DataSourceFilters` | string | Вход | Фильтры (сериализованные) |
| `RecordDefValues` | — | Вход | Значения колонок |
| `RecordAddMode` | enum | Вход | Режим добавления |
| `RecordId` | Guid | Выход | ID созданной записи |

```csharp
public class AddDataUserTask : ProcessUserTask
{
    public override bool InternalExecute(ProcessExecutingContext context)
    {
        // Создание записи через ESQ
        // Установка значений из RecordDefValues
        // Сохранение, возврат RecordId
    }
}
```

### ReadDataUserTask — чтение данных

| Параметр | Тип | Направление | Описание |
|----------|-----|-------------|----------|
| `DataSourceFilters` | string | Вход | Фильтры |
| `ResultType` | enum | Вход | Тип результата |
| `EntityColumnMetaPathes` | string | Вход | Колонки для чтения |
| `OrderInfo` | string | Вход | Сортировка |
| `NumberOfRecords` | int | Вход | Количество записей |
| `FunctionType` | enum | Вход | Агрегатная функция |
| `AggregationColumnName` | string | Вход | Колонка агрегации |
| `ResultEntity` | Entity | Выход | Прочитанная запись |
| `ResultEntityCollection` | Collection | Выход | Коллекция записей |
| `ResultCount` | int | Выход | Количество |
| `ResultIntegerFunction` | int | Выход | Результат Int-агрегации |
| `ResultFloatFunction` | decimal | Выход | Результат Float-агрегации |
| `ResultDateTimeFunction` | DateTime | Выход | Результат DateTime-агрегации |
| `ResultRowsCount` | int | Выход | Кол-во строк результата |
| `ResultCompositeObjectList` | List | Выход | Список композитных объектов |

### ChangeDataUserTask — изменение записей

| Параметр | Тип | Направление | Описание |
|----------|-----|-------------|----------|
| `EntitySchemaUId` | Guid | Вход | Схема сущности |
| `DataSourceFilters` | string | Вход | Фильтры (какие записи менять) |
| `RecordColumnValues` | — | Вход | Новые значения колонок |
| `IsMatchConditions` | bool | Вход | Применять условия фильтрации |

### DeleteDataUserTask — удаление записей

Аналогичен ChangeDataUserTask, но выполняет удаление.

### ActivityUserTask — создание активности

| Параметр | Тип | Описание |
|----------|-----|----------|
| `OwnerId` | Guid | Ответственный |
| `Duration` | int | Длительность |
| `StartIn` | int | Начать через (мин.) |
| `ActivityCategory` | Guid | Категория |
| `Account` | Guid | Контрагент |
| `Contact` | Guid | Контакт |
| `CurrentActivityId` | Guid | (Выход) ID созданной активности |

## Определение FlowElement в процессе

Каждый элемент процесса реализуется как вложенный класс:

```csharp
public class ChangeDataUserTask1FlowElement : ChangeDataUserTask
{
    public ChangeDataUserTask1FlowElement(
        UserConnection userConnection, MyProcess process)
        : base(userConnection)
    {
        Owner = process;
        Type = "ProcessSchemaUserTask";
        Name = "ChangeDataUserTask1";
        SchemaElementUId = new Guid("...");
        _recordColumnValues_Status = () => (Guid)(new Guid("..."));
    }
}
```

## Параметры процесса

```csharp
// Объявление через ProcessSchemaParameter
new ProcessSchemaParameter {
    Name = "ContactId",
    Direction = ProcessSchemaParameterDirection.Input,
    DataValueType = DataValueTypeManager.GetInstanceByName("Guid"),
    Tag = "ContactId"
};

// Чтение/запись в процессе
Guid contactId = Get<Guid>("ContactId");
Set<Guid>("ResultId", newId);
```

## Фильтры в процессах

Фильтры передаются как сериализованный JSON (часто сжатый):

```csharp
// Применение фильтров к ESQ
ProcessUserTaskUtilities.SpecifyESQFilters(
    userConnection, esq, entity, dataSourceFilters);
```

## ScriptTask

Произвольный C#-код в процессе:

```csharp
// В дизайнере процессов задаётся тело метода:
bool ScriptTask1Execute(ProcessExecutingContext context)
{
    var contactId = Get<Guid>("ContactId");
    // произвольная логика
    return true;
}
```

## Вспомогательные классы

| Класс | Назначение |
|-------|-----------|
| `ProcessUserTaskUtilities` | Применение фильтров ESQ, маппинг колонок |
| `ActivityUserTaskHelper` | Помощник для ActivityUserTask |
| `BaseEmailUserTaskMacrosHelper` | Макросы email-шаблонов |
| `EntityColumnMappingValues` | Маппинг колонок (metaPath → значение) |

## ProcessSchemaParameter — метаданные

```csharp
[DesignModeProperty]  // Видимость в дизайнере
public ProcessSchemaParameter {
    Name,
    Direction,           // Input, Output, InOut
    DataValueType,       // Guid, Text, Integer, ...
    Tag,
    IsRequired,
    DefaultValue
}
```

---

## Типовые сценарии

### 1. Программный запуск процесса с параметрами

```csharp
var processEngine = userConnection.ProcessEngine;
var processSchema = userConnection.ProcessSchemaManager
    .GetInstanceByName("MyBusinessProcess");
var parameters = new Dictionary<string, string> {
    { "ContactId", contactId.ToString() },
    { "Amount", "1000" }
};
processEngine.RunProcess("MyBusinessProcess", parameters);
```

### 2. Чтение данных через ReadDataUserTask

```csharp
public class ReadContactFlowElement : ReadDataUserTask
{
    public ReadContactFlowElement(UserConnection userConnection, MyProcess process)
        : base(userConnection)
    {
        Owner = process;
        Name = "ReadContact";
        EntitySchemaUId = new Guid("16be3651-8fe2-4159-8dd0-a803d4683dd3"); // Contact
        ResultType = 0; // Entity
        EntityColumnMetaPathes = "Name;Email;Phone";
    }
}

// Получение результата после выполнения
Entity contact = readContactElement.ResultEntity;
string name = contact.GetTypedColumnValue<string>("Name");
```

### 3. ScriptTask с произвольной логикой

```csharp
bool ScriptTask1Execute(ProcessExecutingContext context)
{
    var contactId = Get<Guid>("ContactId");
    var esq = new EntitySchemaQuery(UserConnection.EntitySchemaManager, "Contact");
    esq.AddColumn("Name");
    esq.Filters.Add(esq.CreateFilterWithParameters(
        FilterComparisonType.Equal, "Id", contactId));
    var entity = esq.GetEntityCollection(UserConnection).FirstOrDefault();
    if (entity != null) {
        Set<string>("ContactName", entity.GetTypedColumnValue<string>("Name"));
    }
    return true;
}
```

---

## Антипаттерны

| ❌ Неправильно | ✅ Правильно |
|---------------|-------------|
| Тяжёлая логика в ScriptTask (сложно отлаживать, нет IntelliSense) | Выносить в отдельный класс-хелпер, ScriptTask вызывает один метод |
| Не проверять результат ReadDataUserTask — `ResultEntity` может быть `null` | Всегда проверять `ResultRowsCount > 0` перед обращением к `ResultEntity` |
| Жёстко зашитые GUID в процессах (не переносятся между средами) | Использовать `SysSettings`, Lookup'ы или параметры процесса для передачи GUID |

---

## Troubleshooting

| Ошибка / Симптом | Причина | Решение |
|-----------------|---------|---------|
| Процесс не запускается | Нет прав на запуск у пользователя | Проверить `SysProcessElementLog`, выдать права через администрирование процессов |
| Параметр не передаётся в процесс | Неверное свойство `Direction` параметра | Убедиться что направление = `Input` (или `InOut`) для входящих параметров |
| ScriptTask не компилируется | Отсутствуют `using`-директивы или ссылки на сборки | Добавить необходимые `using` в свойствах ScriptTask, проверить зависимости пакета |

**Советы по отладке:**
- Журнал процессов: `SysProcessLog` / `SysProcessElementLog`
- Включить детальное логирование: системная настройка `EnableProcessPerformanceLog`
- Для отладки ScriptTask использовать `UserConnection.ProcessEngine.Log.Info(...)` или вынести логику в класс с обычной отладкой

---

## Связанные темы

- [EventListener'ы](event-listeners.md)
- [Схемы сущностей](entity-schemas.md)
- [Планировщик](scheduler-quartz.md)
