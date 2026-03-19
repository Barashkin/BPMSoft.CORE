# Схемы сущностей (Entity Schemas)

<!-- Версия: 1.0 | Обновлено: 2026-03-19 | Платформа: BPMSoft 1.9 -->
<!-- Теги: сущности, схемы, Entity, ESQ, колонки, наследование, BaseEntity, BaseLookup -->

## Обзор

Схема сущности — центральный элемент модели данных BPMSoft. Описывает структуру таблицы в БД: колонки, типы, связи, индексы, события.

**Пространство имён:** `BPMSoft.Configuration`
**Базовый класс ядра:** `BPMSoft.Core.Entities.EntitySchema`

## Иерархия наследования

```
EntitySchema (BPMSoft.Core.Entities)
    └── BaseEntitySchema [IsVirtual]
            ├── BaseLookupSchema
            │       ├── BaseCodeLookupSchema
            │       │       └── BaseHierarchicalLookupSchema
            │       ├── SysAdminUnitSchema
            │       └── SysSettingsSchema
            ├── BaseFileSchema
            ├── BaseItemInFolderSchema
            ├── Contact_Base_BPMSoftSchema
            ├── Account_Base_BPMSoftSchema
            ├── Activity_Base_BPMSoftSchema
            └── ... (715+ схем)
```

## BaseEntitySchema — базовая сущность

Все сущности наследуются от `BaseEntitySchema`. Она предоставляет стандартные колонки:

| Колонка | Тип | Описание |
|---------|-----|----------|
| `Id` | Guid (AutoGuid) | Первичный ключ |
| `CreatedOn` | DateTime | Дата создания |
| `CreatedBy` | Lookup → Contact | Кто создал |
| `ModifiedOn` | DateTime | Дата изменения |
| `ModifiedBy` | Lookup → Contact | Кто изменил |
| `ProcessListeners` | Integer | Флаги слушателей процессов |

### Ключевые методы BaseEntitySchema

```csharp
InitializeProperties()          // инициализация свойств схемы
InitializePrimaryColumn()       // настройка первичной колонки (Id)
CreateIdColumn()                // создание колонки Id
CreateCreatedOnColumn()         // создание колонки CreatedOn
CreateCreatedByColumn()         // создание колонки CreatedBy
CreateModifiedOnColumn()        // создание колонки ModifiedOn
CreateModifiedByColumn()        // создание колонки ModifiedBy
CreateEntity()                  // фабрика экземпляра Entity
CreateEventsProcess()           // фабрика процесса событий
Clone() / CloneShallow()        // клонирование схемы
```

### Специальные колонки схемы

| Свойство | Назначение |
|----------|-----------|
| `PrimaryColumn` | Первичный ключ (обычно `Id`) |
| `PrimaryDisplayColumn` | Отображаемое имя (например, `Name` или `Title`) |
| `PrimaryImageColumn` | Колонка изображения |
| `PrimaryOrderColumn` | Колонка сортировки по умолчанию |

## BaseLookupSchema — справочник

Расширяет `BaseEntitySchema` колонками:

| Колонка | Тип | Описание |
|---------|-----|----------|
| `Name` | MediumText | Название (PrimaryDisplayColumn) |
| `Description` | MediumText | Описание |

Для справочников с кодом используется `BaseCodeLookupSchema`, добавляющий колонку `Code`.

Для иерархических справочников — `BaseHierarchicalLookupSchema` (колонка `Parent`).

## Типы колонок

| DataValueType | C# тип | Описание |
|--------------|--------|----------|
| `Guid` | Guid | Уникальный идентификатор |
| `Text` / `MediumText` / `LongText` | string | Текст |
| `Integer` | int | Целое число |
| `Float` / `Money` | decimal | Дробное число / деньги |
| `DateTime` / `Date` / `Time` | DateTime | Дата/время |
| `Boolean` | bool | Логическое |
| `Lookup` | Guid (FK) | Ссылка на другую сущность |
| `Image` / `ImageLookup` | Guid | Изображение |
| `Blob` | byte[] | Бинарные данные |

## Пример: схема Contact

```csharp
public class Contact_Base_BPMSoftSchema : BaseEntitySchema
{
    // PrimaryDisplayColumn = "Name"
    // PrimaryImageColumn = "Photo"

    // Основные колонки:
    // Name, Photo, Owner, Dear, SalutationType, Gender
    // Account, DecisionRole, Type, Job, JobTitle, Department
    // BirthDate, Phone, MobilePhone, HomePhone, Skype, Email
    // Address, City, Region, Zip, Country
    // Surname, GivenName, MiddleName
    // DoNotUseEmail, DoNotUseCall, DoNotUseFax, DoNotUseSms
    // Notes, Language, Confirmed
}
```

## Пример: схема Account

```csharp
public class Account_Base_BPMSoftSchema : BaseEntitySchema
{
    // PrimaryDisplayColumn = "Name"
    // PrimaryImageColumn = "AccountLogo"

    // Основные колонки:
    // Name, Owner, Ownership, PrimaryContact, Parent
    // Industry, Code, Type, Phone, AdditionalPhone, Fax, Web
    // Address, City, Region, Zip, Country
    // AccountCategory, EmployeesNumber, AnnualRevenue
    // Notes, AlternativeName, Email, GPSN, GPSE
}
```

## Работа с Entity (экземпляром)

```csharp
// Создание через ESQ
var esq = new EntitySchemaQuery(userConnection.EntitySchemaManager, "Contact");
esq.AddAllSchemaColumns();
var entity = esq.GetEntity(userConnection, contactId);

// Чтение значений
string name = entity.GetTypedColumnValue<string>("Name");
Guid accountId = entity.GetTypedColumnValue<Guid>("AccountId");

// Изменение
entity.SetColumnValue("Phone", "+7-999-123-4567");
entity.Save();

// Создание новой записи
var schema = userConnection.EntitySchemaManager.GetInstanceByName("Contact");
var newEntity = schema.CreateEntity(userConnection);
newEntity.SetDefColumnValues();
newEntity.SetColumnValue("Name", "Иванов Иван");
newEntity.Save();
```

## События Entity

| Событие | Когда срабатывает |
|---------|------------------|
| `Validating` | Перед валидацией |
| `Inserting` | Перед INSERT |
| `Inserted` | После INSERT |
| `Saving` | Перед сохранением (INSERT/UPDATE) |
| `Saved` | После сохранения |
| `Updating` | Перед UPDATE |
| `Updated` | После UPDATE |
| `Deleting` | Перед DELETE |
| `Deleted` | После DELETE |

См. подробнее: [event-listeners.md](event-listeners.md)

---

## Типовые сценарии

### 1. Создание новой сущности-наследника BaseLookup (справочник с Name+Description)

```csharp
// В дизайнере создаётся схема, наследующая BaseLookupSchema.
// Программно — получение и работа с экземпляром:
var schema = userConnection.EntitySchemaManager.GetInstanceByName("MyCustomLookup");
var entity = schema.CreateEntity(userConnection);
entity.SetDefColumnValues();
entity.SetColumnValue("Name", "Новый элемент справочника");
entity.SetColumnValue("Description", "Описание элемента");
entity.Save();
```

### 2. Добавление Lookup-колонки (FK на другую сущность)

```csharp
// В дизайнере добавляется колонка типа Lookup, указывающая на целевую схему.
// Чтение связанного значения через ESQ:
var esq = new EntitySchemaQuery(userConnection.EntitySchemaManager, "Contact");
esq.AddColumn("Name");
esq.AddColumn("Account.Name"); // Lookup-колонка → получение Name связанного Account
esq.Filters.Add(esq.CreateFilterWithParameters(
    FilterComparisonType.Equal, "Id", contactId));
var collection = esq.GetEntityCollection(userConnection);
if (collection.Count > 0) {
    string accountName = collection[0].GetTypedColumnValue<string>("Account_Name");
}
```

### 3. Чтение записи через ESQ с фильтром

```csharp
var esq = new EntitySchemaQuery(userConnection.EntitySchemaManager, "Contact");
esq.AddColumn("Name");
esq.AddColumn("Email");
esq.AddColumn("MobilePhone");

// Фильтр по городу
esq.Filters.Add(esq.CreateFilterWithParameters(
    FilterComparisonType.Equal, "City.Name", "Москва"));

// Фильтр по дате создания
esq.Filters.Add(esq.CreateFilterWithParameters(
    FilterComparisonType.GreaterOrEqual, "CreatedOn",
    DateTime.UtcNow.AddDays(-30)));

var contacts = esq.GetEntityCollection(userConnection);
foreach (var contact in contacts) {
    string name = contact.GetTypedColumnValue<string>("Name");
    string email = contact.GetTypedColumnValue<string>("Email");
}
```

### 4. Массовое обновление записей через Update builder

```csharp
var update = new Update(userConnection, "Contact")
    .Set("DepartmentId", Column.Parameter(newDepartmentId))
    .Where("AccountId").IsEqual(Column.Parameter(accountId))
    .And("DepartmentId").IsEqual(Column.Parameter(oldDepartmentId));
int rowsAffected = update.Execute();
```

### 5. Создание иерархического справочника (BaseHierarchicalLookup)

```csharp
// Схема наследует BaseHierarchicalLookupSchema — добавляется колонка Parent (Lookup на себя).
var schema = userConnection.EntitySchemaManager.GetInstanceByName("MyHierarchicalLookup");

// Создание корневого элемента
var root = schema.CreateEntity(userConnection);
root.SetDefColumnValues();
root.SetColumnValue("Name", "Корневой элемент");
root.Save();
Guid rootId = root.GetTypedColumnValue<Guid>("Id");

// Создание дочернего элемента
var child = schema.CreateEntity(userConnection);
child.SetDefColumnValues();
child.SetColumnValue("Name", "Дочерний элемент");
child.SetColumnValue("ParentId", rootId);
child.Save();
```

---

## Антипаттерны

### ❌ Использование `entity.FetchFromDB()` без проверки результата

Метод может вернуть `false`, если запись не найдена. Без проверки дальнейшая работа с пустым Entity приведёт к ошибкам.

```csharp
// ❌ Плохо
var entity = schema.CreateEntity(userConnection);
entity.FetchFromDB(recordId);
string name = entity.GetTypedColumnValue<string>("Name"); // может быть пустым

// ✅ Хорошо
var entity = schema.CreateEntity(userConnection);
if (entity.FetchFromDB(recordId)) {
    string name = entity.GetTypedColumnValue<string>("Name");
} else {
    throw new ItemNotFoundException($"Запись {recordId} не найдена");
}
```

### ❌ `AddAllSchemaColumns()` в продуктивном коде

Загрузка всех колонок создаёт лишнюю нагрузку на БД — особенно для схем с десятками колонок (Contact, Account).

```csharp
// ❌ Плохо
var esq = new EntitySchemaQuery(userConnection.EntitySchemaManager, "Contact");
esq.AddAllSchemaColumns();

// ✅ Хорошо — добавлять только нужные колонки
var esq = new EntitySchemaQuery(userConnection.EntitySchemaManager, "Contact");
esq.AddColumn("Name");
esq.AddColumn("Email");
```

### ❌ Забыть `SetDefColumnValues()` при создании новой записи

Без вызова этого метода не заполнятся значения по умолчанию (Id, CreatedOn, CreatedBy и др.).

```csharp
// ❌ Плохо
var entity = schema.CreateEntity(userConnection);
entity.SetColumnValue("Name", "Тест");
entity.Save(); // Id может быть Guid.Empty

// ✅ Хорошо
var entity = schema.CreateEntity(userConnection);
entity.SetDefColumnValues();
entity.SetColumnValue("Name", "Тест");
entity.Save();
```

### ❌ Прямые SQL-запросы вместо ESQ

Прямой SQL обходит систему прав доступа, события Entity, валидацию и аудит.

```csharp
// ❌ Плохо — прямой SQL
using (var cmd = new SqlCommand("UPDATE Contact SET Name = @name WHERE Id = @id", connection)) {
    cmd.ExecuteNonQuery();
}

// ✅ Хорошо — ESQ / Entity API
var entity = schema.CreateEntity(userConnection);
if (entity.FetchFromDB(id)) {
    entity.SetColumnValue("Name", newName);
    entity.Save();
}
```

---

## Troubleshooting

### Таблица ошибок

| Ошибка | Причина | Решение |
|--------|---------|---------|
| `EntitySchemaNotFoundException` | Схема не найдена в менеджере | Проверить имя схемы в `EntitySchemaManager`, убедиться что пакет со схемой установлен и скомпилирован |
| Колонка не найдена в Entity | Колонка не добавлена в ESQ | Убедиться, что колонка добавлена через `esq.AddColumn()` перед выполнением запроса |
| Данные не сохраняются | Ошибка валидации Entity | Вызвать `entity.Validate()` перед `Save()` и проверить `entity.ValidationMessages` |
| `InvalidObjectStateException` | Попытка сохранить Entity без изменений | Проверить, что `SetColumnValue` вызван хотя бы для одной колонки |
| Lookup-колонка возвращает `Guid.Empty` | Связанная запись не найдена или колонка не заполнена | Проверить наличие данных в связанной таблице |

### Советы по отладке

- Используйте `entity.GetChangedColumnValues()` для просмотра изменённых колонок перед сохранением.
- Включите логирование SQL через системную настройку `EnableSqlLog` для анализа генерируемых запросов.
- При ошибках `FetchFromDB` проверьте, что передаётся корректный `Guid`, а не `Guid.Empty`.

### Известные ограничения

- `AddAllSchemaColumns()` не загружает колонки из связанных таблиц — для них нужен явный `AddColumn("LinkedEntity.Column")`.
- `Entity.Save()` внутри транзакции EventListener'а может привести к deadlock при конкурентных запросах — используйте `Update` builder для массовых операций.
- ESQ не поддерживает `GROUP BY` — для агрегаций используйте `Select` builder.

---

## Связанные темы

- [EventListener'ы](event-listeners.md)
- [WCF-сервисы](services.md)
- [Базовые классы](../reference/base-classes.md)
- [Перечисления](../reference/enums-constants.md)
