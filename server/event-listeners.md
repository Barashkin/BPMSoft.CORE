# EventListener'ы

<!-- Версия: 1.0 | Обновлено: 2026-03-19 | Платформа: BPMSoft 1.9 -->
<!-- Теги: EventListener, события, Entity, CRUD, OnSaving, OnSaved, IAppEventListener, EventsProcess -->

## Обзор

EventListener'ы обрабатывают события в BPMSoft. Есть два типа:
1. **Entity EventListeners** — реагируют на CRUD-операции над сущностями
2. **App EventListeners** — реагируют на события жизненного цикла приложения

## Entity EventListeners

### Базовый класс

```csharp
using BPMSoft.Core.Entities.Events;

[EntityEventListener(SchemaName = "Contact")]
public class ContactEventListener : BaseEntityEventListener
{
    // Перед сохранением (INSERT или UPDATE)
    public override void OnSaving(object sender, EntityBeforeEventArgs e) { }

    // После сохранения
    public override void OnSaved(object sender, EntityAfterEventArgs e) { }

    // Перед вставкой
    public override void OnInserting(object sender, EntityBeforeEventArgs e) { }

    // После вставки
    public override void OnInserted(object sender, EntityAfterEventArgs e) { }

    // Перед обновлением
    public override void OnUpdating(object sender, EntityBeforeEventArgs e) { }

    // После обновления
    public override void OnUpdated(object sender, EntityAfterEventArgs e) { }

    // Перед удалением
    public override void OnDeleting(object sender, EntityBeforeEventArgs e) { }

    // После удаления
    public override void OnDeleted(object sender, EntityAfterEventArgs e) { }
}
```

### Регистрация

Регистрация через атрибут `[EntityEventListener(SchemaName = "...")]`. Платформа находит слушателей рефлексией.

### Доступ к данным в EventListener

```csharp
public override void OnSaving(object sender, EntityBeforeEventArgs e)
{
    var entity = (Entity)sender;
    UserConnection userConnection = entity.UserConnection;

    // Получить изменённое значение
    var newName = entity.GetTypedColumnValue<string>("Name");

    // Проверить, изменилась ли конкретная колонка
    var changedColumns = entity.GetChangedColumnValues();
    bool nameChanged = changedColumns.Any(c => c.Name == "Name");

    // Отменить операцию
    e.IsCanceled = true;
}
```

### Примеры из базового решения

#### BaseEntityOwnerEventListener
Обработка смены владельца записи:
```csharp
[EntityEventListener(SchemaName = "...")]
public class BaseEntityOwnerEventListener : BaseEntityEventListener
{
    protected virtual string OwnerColumnName => "OwnerId";

    public override void OnSaved(object sender, EntityAfterEventArgs e)
    {
        if (IsOwnerChanged()) {
            RunExecutor<EntityActivityOwnerAsyncExecutor>();
            RunExecutor<EntityProcessElementDataOwnerAsyncExecutor>();
        }
    }
}
```

#### LookupEventListener
Проверка прав при изменении справочника:
```csharp
public class LookupEventListener : BaseEntityEventListener
{
    public override void OnSaving(object sender, EntityBeforeEventArgs e)
    {
        // Проверка прав через DBSecurityEngine
    }

    public override void OnDeleting(object sender, EntityBeforeEventArgs e)
    {
        // Проверка прав на удаление
    }
}
```

## App EventListeners

### Интерфейс IAppEventListener

```csharp
using BPMSoft.Core;
using BPMSoft.Web.Common;

public class MyAppEventListener : IAppEventListener
{
    public void OnAppStart(AppEventContext context)
    {
        // Инициализация при старте приложения
        // Регистрация планировщиков, DI-сервисов и т.д.
    }

    public void OnAppEnd(AppEventContext context)
    {
        // Очистка при остановке
    }

    public void OnSessionStart(AppEventContext context)
    {
        // Начало пользовательской сессии
    }

    public void OnSessionEnd(AppEventContext context)
    {
        // Конец сессии
    }
}
```

### Альтернативный базовый класс: AppEventListenerBase

```csharp
public class NotificationEventListener : AppEventListenerBase
{
    public override void OnAppStart(AppEventContext context)
    {
        base.OnAppStart(context);
        // Регистрация через ClassFactory / DI
    }
}
```

### Примеры из базового решения

#### AnniversaryRemindingsEventListener
Планирование задач по напоминаниям:
```csharp
public class AnniversaryRemindingsEventListener : IAppEventListener
{
    public void OnAppStart(AppEventContext context)
    {
        // Регистрация Quartz-задачи для создания напоминаний
    }
}
```

#### GlobalSearchEventListener
Инициализация глобального поиска:
```csharp
public class GlobalSearchEventListener : IAppEventListener
{
    public void OnAppStart(AppEventContext context)
    {
        // Настройка индексации для глобального поиска
    }
}
```

## Таблица всех EventListener'ов базового решения

| EventListener | Тип | Схема/Назначение |
|-------------|-----|-----------------|
| BaseEntityOwnerEventListener | Entity | Смена владельца |
| BaseSysSettingsEventListener\<T\> | Entity | Актуализация системных настроек |
| LookupEventListener | Entity | Проверка прав справочников |
| ContactEventListener | Entity | Очистка кэша контакта |
| FileSecurityExcludedUriEventListener | Entity | Безопасность файлов |
| CollisionLockedRecordEventListener | Entity | Блокировка записей (коллизии) |
| AnniversaryRemindingsEventListener | App | Планировщик напоминаний |
| NotificationEventListener | App | Регистрация уведомлений |
| GlobalSearchEventListener | App | Инициализация поиска |
| EmailUserTaskAppEventListener | App | Email-задачи процессов |
| FileImportAppEventListener | App | Импорт файлов |
| FastReportAppEventListener | App | Инициализация отчётов |

---

## EventsProcess — встроенные процессы событий сущностей

### Обзор

EventsProcess — более старый (по сравнению с EntityEventListener) и мощный механизм обработки событий сущностей. Реализован как **EmbeddedProcess** — встроенный бизнес-процесс, привязанный к жизненному циклу Entity. Позволяет строить цепочки ScriptTask'ов, реагирующих на события Saving/Saved/Inserting/Inserted/Deleting/Deleted.

Код EventsProcess генерируется платформой и находится в двух местах:
- **`{Entity}Schema.Base.cs`** — объявление класса, FlowElement'ы, маршрутизация событий
- **`{Entity}.Base.cs`** — бизнес-логика (partial class с virtual-методами)

### Иерархия наследования

```
BPMSoft.Core.Process.EmbeddedProcess
  └── BaseEntity_BaseEventsProcess<TEntity>        // BaseEntitySchema.Base.cs
        ├── Account_BaseEventsProcess<TEntity>      // AccountSchema.Base.cs + Account.Base.cs
        ├── Contact_BaseEventsProcess<TEntity>      // ContactSchema.Base.cs + Contact.Base.cs
        ├── Activity_BaseEventsProcess<TEntity>     // ActivitySchema.Base.cs + Activity.Base.cs
        └── Lookup_BaseEventsProcess<TEntity>       // LookupSchema.Base.cs (без бизнес-логики)
```

### Структура класса

```csharp
// Объявление в Schema-файле (ContactSchema.Base.cs)
public partial class Contact_BaseEventsProcess<TEntity>
    : BPMSoft.Configuration.BaseEntity_BaseEventsProcess<TEntity>
    where TEntity : Contact_Base_BPMSoft
{
    // FlowElement'ы — ScriptTask, StartMessage, EventSubProcess
    // InitializeFlowElements() — регистрация элементов
    // OnExecuted() — маршрутизация: какой ScriptTask после какого события
    // ThrowEvent() — маппинг событий Entity на StartMessage элементы
}

// Non-generic обёртка
public class Contact_BaseEventsProcess : Contact_BaseEventsProcess<Contact_Base_BPMSoft> { }

// Алиас (для некоторых сущностей)
public class ContactEventsProcess : Contact_BaseEventsProcess { }
```

```csharp
// Бизнес-логика в отдельном файле (Contact.Base.cs)
public partial class Contact_BaseEventsProcess<TEntity>
{
    // virtual-методы с реальной логикой
    public virtual bool SynchronizeContactAddress() { ... }
    public virtual void ChangeCareer() { ... }
    public virtual void FillSgmOrNameField() { ... }
}
```

### Механизм работы

#### 1. Маппинг событий Entity → FlowElement

При сохранении Entity платформа вызывает `ThrowEvent()`, который направляет событие в нужный StartMessage:

```csharp
public override void ThrowEvent(ProcessExecutingContext context, string message) {
    switch(message) {
        case "Contact_Base_BPMSoftSaved":
            if (ActivatedEventElements.Contains("ContactSaved")) {
                context.QueueTasks.Enqueue("ContactSaved");
            }
            break;
        case "Contact_Base_BPMSoftSaving":
            if (ActivatedEventElements.Contains("ContactSaving")) {
                context.QueueTasks.Enqueue("ContactSaving");
            }
            break;
    }
    base.ThrowEvent(context, message);
}
```

#### 2. Маршрутизация ScriptTask'ов

`OnExecuted()` определяет цепочку выполнения — после какого элемента запускается следующий:

```csharp
protected override void OnExecuted(object sender, ProcessActivityAfterEventArgs e) {
    switch (e.Context.SenderName) {
        case "ContactSaving":
            e.Context.QueueTasks.Enqueue("ContactSavingScriptTask");
            e.Context.QueueTasks.Enqueue("SynchronizeContactCommunication");
            break;
        case "ContactSaved":
            e.Context.QueueTasks.Enqueue("SynchronizeContactAddressScriptTask");
            e.Context.QueueTasks.Enqueue("UpdateCareerScriptTask");
            e.Context.QueueTasks.Enqueue("UpdateRemindings");
            break;
    }
}
```

#### 3. Выполнение ScriptTask'а

Каждый ScriptTask — делегат, вызывающий virtual-метод из partial-класса:

```csharp
public virtual bool SynchronizeContactAddressScriptTaskExecute(ProcessExecutingContext context) {
    SynchronizeContactAddress();
    return true;
}

public virtual bool UpdateCareerScriptTaskExecute(ProcessExecutingContext context) {
    if (IsCareerChanged) {
        ChangeCareer();
    }
    return true;
}
```

### BaseEntity_BaseEventsProcess — базовая логика для всех сущностей

**Файл:** `BaseEntitySchema.Base.cs`

Обрабатывает общие события для всех сущностей:

| Событие | ScriptTask | Действие |
|---------|-----------|----------|
| Saving (Update) | `BaseEntitySavingScriptTask` | Инициализация DCM, `TryProcessComplete(Updated)`, отправка локальных сообщений |
| Saved | `TryProcessCompleteScriptTask1` | `ProcessCompleteExecuting()` — завершение связанных процессов |
| Saved | `BaseEntitySavedIndexingTask` | `IndexEntity()` — индексация для глобального поиска |
| Inserted | `ScriptTaskInsertedBaseEntity` | `TryProcessComplete(Inserted)`, отправка локальных сообщений |
| Deleting | `TryProcessCompleteScriptTask2` | `TryProcessComplete(Deleted)`, отправка локальных сообщений |
| Deleted | `BaseEntityDeletedScriptTask` | `IndexEntity(Delete)` — удаление из индекса |
| Validating | `BaseEnityValidatingScriptTask` | Валидация DCM: обязательные элементы и права на стадии |

Ключевые методы:

```csharp
public virtual void TryProcessComplete(EntityChangeType changeType) {
    var processEngine = UserConnection.ProcessEngine;
    ProcessListeners = processEngine.GetProcessListeners(UserConnection, Entity, changeType);
    ProcessSchemaListeners = processEngine.GetProcessSchemaListeners(Entity, changeType);
}

public virtual void InitDcmOnEntityChanging() {
    if (!CanInitDcmForEntity()) return;
    var dcmEntityUtilities = GetDcmEntityUtilities();
    CanUseDcm = dcmEntityUtilities.GetCanEntityUseDcm(
        Entity.Schema.UId, Entity.GetChangedColumnValues());
    CancelNotEnabledDcmProcess();
}
```

### Account_BaseEventsProcess — бизнес-логика контрагента

**Файлы:** `AccountSchema.Base.cs` + `Account.Base.cs`

#### Цепочки событий

| Событие | ScriptTask'ы |
|---------|-------------|
| Saving | InitializeCommunicationSynchronizer, InitCanGenerateAnniversaryReminding |
| Saved | SynchronizeAddress, SynchronizeCommunication, SynchronizeRelationship, InitPrimaryContactAccount, GenerateRemindings |

#### Синхронизация адресов (Account → AccountAddress)

При сохранении Account синхронизирует основной адрес с таблицей AccountAddress:

```csharp
public virtual bool SynchronizeAddress() {
    var accountId = Entity.PrimaryColumnValue;
    var addressTypeId = Entity.GetTypedColumnValue<Guid>("AddressTypeId");
    var address = Entity.GetTypedColumnValue<string>("Address");
    var cityId = Entity.GetTypedColumnValue<Guid>("CityId");
    // ... regionId, countryId, zip, gpsN, gpsE

    if (isEmptyAddressTypeId && isEmptyAddress && isEmptyCityId && ...) {
        return true;
    }

    var addressESQ = new EntitySchemaQuery(UserConnection.EntitySchemaManager, "AccountAddress");
    addressESQ.Filters.Add(addressESQ.CreateFilterWithParameters(
        FilterComparisonType.Equal, "Account", accountId));
    addressESQ.Filters.Add(addressESQ.CreateFilterWithParameters(
        FilterComparisonType.Equal, "Primary", true));
    var addresses = addressESQ.GetEntityCollection(UserConnection, options);

    if (addresses.Count > 0) {
        var accountAddress = addresses[0];
        if (!accountAddress.GetTypedColumnValue<string>("Address").Equals(address)) {
            accountAddress.SetColumnValue("Address", address);
            entityChanged = true;
        }
        // ... аналогично для City, Region, Country, Zip, GPS
        if (entityChanged) accountAddress.Save();
    } else {
        var accountAddressEntity = schema.CreateEntity(UserConnection);
        accountAddressEntity.SetDefColumnValues();
        accountAddressEntity.SetColumnValue("AccountId", accountId);
        accountAddressEntity.SetColumnValue("Primary", true);
        // ... заполнение полей
        if (accountAddressEntity.Validate()) accountAddressEntity.Save();
    }
    return true;
}
```

#### Синхронизация связей (Parent → Relationship)

При изменении поля Parent синхронизирует запись в таблице Relationship:

```csharp
public virtual bool SynchronizeRelationship() {
    if (Entity.GetColumnValue("ParentId") != null || OldParentId != Guid.Empty) {
        Guid relationTypeId = GetRelationTypeId();  // из SysSettings
        Guid reverseRelationTypeId = GetReverseRelationTypeId();
        Guid accountId = Entity.GetTypedColumnValue<Guid>("Id");
        Guid parentId = Entity.GetTypedColumnValue<Guid>("ParentId");

        Select select = new Select(UserConnection)
            .Column("Id").Column("AccountAId").Column("AccountBId")
            .From("Relationship")
            .Where()
                .OpenBlock("AccountAId").IsEqual(Column.Parameter(accountId))
                .And("AccountBId").IsEqual(Column.Parameter(searchParentId))
                .CloseBlock()
            .Or()
                .OpenBlock("AccountAId").IsEqual(Column.Parameter(searchParentId))
                .And("AccountBId").IsEqual(Column.Parameter(accountId))
                .CloseBlock();

        if (removeRelationship && relationshipId != Guid.Empty) {
            new Delete(UserConnection).From("Relationship")
                .Where("Id").IsEqual(Column.Parameter(relationshipId)).Execute(executor);
        } else if (relationshipId != Guid.Empty) {
            new Update(UserConnection, "Relationship")
                .Set(parentAccountColumnName, Column.Parameter(parentId))
                .Where("Id").IsEqual(Column.Parameter(relationshipId)).Execute(executor);
        } else if (parentId != Guid.Empty) {
            new Insert(UserConnection).Into("Relationship")
                .Set("AccountBId", Column.Parameter(accountId))
                .Set("RelationTypeId", Column.Parameter(relationTypeId))
                .Set("AccountAId", Column.Parameter(parentId))
                .Set("ReverseRelationTypeId", Column.Parameter(reverseRelationTypeId))
                .Execute(executor);
        }
    }
    return true;
}
```

#### Синхронизация коммуникаций (CommunicationSynchronizer)

```csharp
public virtual void InitializeCommunicationSynchronizer() {
    var communicationColumns = new Dictionary<string, Guid> {
        {"Web", new Guid(CommunicationTypeConsts.WebId)},
        {"Fax", new Guid(CommunicationTypeConsts.FaxId)},
        {"Phone", new Guid(CommunicationTypeConsts.MainPhoneId)},
        {"AdditionalPhone", new Guid(CommunicationTypeConsts.AdditionalPhoneId)},
        {"Email", new Guid(CommunicationTypeConsts.EmailId)}
    };
    var helper = GetCommunicationSynchronizer();
    helper.InitializeCommunicationItems(communicationColumns);
}

public virtual bool SynchronizeCommunication() {
    var helper = GetCommunicationSynchronizer();
    helper.SynchronizeCommunications();
    return true;
}
```

#### Привязка PrimaryContact

```csharp
public virtual void InitPrimaryContactAccount() {
    object primaryContactId = Entity.GetColumnValue("PrimaryContactId");
    if (primaryContactId == null) return;
    EntitySchema contactSchema = UserConnection.EntitySchemaManager.GetInstanceByName("Contact");
    Entity primaryContact = contactSchema.CreateEntity(UserConnection);
    if (!primaryContact.FetchFromDB(primaryContactId)
        || primaryContact.GetColumnValue("AccountId") != null) return;
    primaryContact.SetColumnValue("AccountId", Entity.PrimaryColumnValue);
    primaryContact.Save();
}
```

#### Напоминания о годовщинах

```csharp
public virtual void InitCanGenerateAnniversaryReminding() {
    bool isNew = Entity.StoringState == StoringObjectState.New;
    bool isPrimaryContactNotEmpty =
        Entity.GetTypedColumnValue<Guid>("PrimaryContactId").IsNotEmpty();
    var columns = GetAnniversaryDependentColumns();  // ["PrimaryContactId", "OwnerId"]
    var changedColumns = Entity.GetChangedColumnValues();
    bool anniversaryColumnsChanged = changedColumns.Any(col => columns.Contains(col.Name));
    CanGenerateAnniversaryReminding =
        (isPrimaryContactNotEmpty || !isNew) && anniversaryColumnsChanged;
}

public virtual void GenerateRemindings() {
    if (!CanGenerateAnniversaryReminding) return;
    Guid id = Entity.GetTypedColumnValue<Guid>("Id");
    var remindingsGenerator = new AccountAnniversaryReminding(UserConnection, id);
    remindingsGenerator.Options = GetRemindingOptions();
    remindingsGenerator.GenerateActualRemindings();
}
```

### Contact_BaseEventsProcess — бизнес-логика контакта

**Файлы:** `ContactSchema.Base.cs` + `Contact.Base.cs`

#### Цепочки событий

| Событие | ScriptTask'ы |
|---------|-------------|
| Saving | ContactSavingScriptTask (CheckIsCareerChanged, FillSgmOrNameField, InitializeCommunicationSynchronizer, InitCanGenerateAnniversaryReminding) |
| Saved | SynchronizeContactAddress, SynchronizeContactCommunication, UpdateCareer, SynchronizeName, UpdateRemindings, SynchronizeAnniversary |
| Deleting | Нет собственных (базовая обработка) |
| Deleted | DeleteRemindings |

#### Синхронизация имени (SGM / Name)

При изменении частей имени автоматически пересчитывает поля:

```csharp
public virtual void FillSgmOrNameField() {
    IEnumerable<EntityColumnValue> changedColumns = Entity.GetChangedColumnValues();
    if (NamePartColumnChanged(changedColumns, "Name")) {
        SetSgm(Entity as Contact);   // Name → Surname + GivenName + MiddleName
    } else if (
        NamePartColumnChanged(changedColumns, "Surname") ||
        NamePartColumnChanged(changedColumns, "GivenName") ||
        NamePartColumnChanged(changedColumns, "MiddleName")) {
        SetName(Entity as Contact);   // Surname + GivenName + MiddleName → Name
    }
}

public virtual IContactFieldConverter GetContactConverter() {
    return ContactUtilities.GetContactConverter(UserConnection);
}
```

#### Управление карьерой (ContactCareer)

При изменении полей Account, Department, Job, DecisionRole, JobTitle автоматически создаёт/обновляет записи в ContactCareer:

```csharp
public virtual void CheckIsCareerChanged() {
    var accountId = Entity.GetTypedColumnValue<Guid>("AccountId");
    var departmentId = Entity.GetTypedColumnValue<Guid>("DepartmentId");
    var jobId = Entity.GetTypedColumnValue<Guid>("JobId");
    var decisionRoleId = Entity.GetTypedColumnValue<Guid>("DecisionRoleId");
    var jobTitle = Entity.GetTypedColumnValue<string>("JobTitle");
    var accountOldId = Entity.GetTypedOldColumnValue<Guid>("AccountId");
    // ...
    var careerIsChanged = accountId != accountOldId || departmentId != departmentOldId || ...;
    // Логика: старое заполнено → Insert новой записи
    //         старое пусто → Update текущей
    //         все новые пусты → Delete (закрытие)
}

public virtual void ChangeCareer() {
    var careerSchema = UserConnection.EntitySchemaManager.GetInstanceByName("ContactCareer");
    var careerEntity = careerSchema.CreateEntity(UserConnection);
    if (NeedInsertCareer) {
        UpdateOldCareer();                      // Primary=false для старых записей
        FillCareerDefaultValues(careerEntity);  // Current=true, StartDate=Now
        FillCareerEntity(careerEntity);         // Account, Department, Job, JobTitle
        careerEntity.Save();
    } else if (NeedUpdateCareer) {
        // Поиск последней Primary-карьеры через ESQ → обновление
    } else if (NeedDeleteCareer) {
        UpdateOldCareer();                      // Закрытие текущей карьеры
    }
}

public virtual void CloseCurrentJob() {
    var update = new Update(UserConnection, "ContactCareer");
    update.Set("Current", Column.Parameter(false));
    update.Set("DueDate", Column.Parameter(DateTime.Now));
    update.Where("ContactId").IsEqual(Column.Parameter(Entity.PrimaryColumnValue));
    update.And("Current").IsEqual(Column.Parameter(true));
    update.And("Primary").IsEqual(Column.Parameter(true));
    update.Execute();
}
```

#### Коммуникации контакта

```csharp
public virtual void InitializeCommunicationSynchronizer() {
    var communicationColumns = new Dictionary<string, Guid> {
        {"Email", new Guid(CommunicationTypeConsts.EmailId)},
        {"Skype", new Guid(CommunicationTypeConsts.SkypeId)},
        {"HomePhone", new Guid(CommunicationTypeConsts.HomePhoneId)},
        {"MobilePhone", new Guid(CommunicationTypeConsts.MobilePhoneId)},
        {"Phone", new Guid(CommunicationTypeConsts.WorkPhoneId)}
    };
    var helper = GetCommunicationSynchronizer();
    helper.InitializeCommunicationItems(communicationColumns);
}

public virtual void CreateCommunication(UserConnection userConnection, EntitySchema schema,
    string typeId, Guid primaryEntityId, string number, string socialMediaId) {
    var communication = schema.CreateEntity(userConnection);
    communication.SetDefColumnValues();
    communication.SetColumnValue("CommunicationTypeId", Guid.Parse(typeId));
    communication.SetColumnValue("ContactId", primaryEntityId);
    communication.SetColumnValue("Number", number);
    if (!socialMediaId.IsNullOrEmpty()) {
        communication.SetColumnValue("SocialMediaId", socialMediaId);
    }
    communication.Save();
}
```

#### Обновление возраста

```csharp
protected virtual bool IsNeedUpdateAge {
    get {
        if (_isNeedUpdateAge == null) {
            _isNeedUpdateAge = (bool)SysSettings.GetValue(UserConnection, "ActualizeAge");
        }
        return (bool)_isNeedUpdateAge;
    }
}

protected virtual bool IsNotNeededToCalculateAge() {
    var birthdate = Entity.GetTypedColumnValue<DateTime>("BirthDate");
    return !IsNeedUpdateAge || !BirthDateColumnChanged()
        || birthdate.Equals(DateTime.MinValue);
}
```

### Activity_BaseEventsProcess — бизнес-логика активности

**Файлы:** `ActivitySchema.Base.cs` + `Activity.Base.cs`

Самый объёмный EventsProcess (~760 строк логики). Управляет участниками, email-обработкой, правами, напоминаниями.

#### Цепочки событий

| Событие | ScriptTask'ы |
|---------|-------------|
| Saving | OnActivitySaving (SaveOldValues, SetRemindDates, CalculateDuration, SavingEmail, SetTypeByCategory, CheckNeedAutoEmailRelation, InitCanGenerateAnniversaryReminding) |
| Saved | OnActivitySaved (SetParticipantRights, EmailParticipants / UpdateParticipantsByOwnerContact, AutoEmailRelation, CreateParticipantsFromInsertedValues) |
| Inserting | OnActivityInserting (EmailSendStatus=NotSend, SetEmailIsNeedProcess) |
| Inserted | OnActivityInserted (права автора, EmailMessage) |
| Deleting | ActivityDeleting |
| Updated | SynchronizeSubjectRemindingOwner, SynchronizeSubjectRemindingAuthor |
| Validating | OnActivityValidating (Owner или OwnerRole обязательны) |

#### Обработка сохранения — OnActivitySaving

```csharp
public virtual bool OnActivitySaving(ProcessExecutingContext context) {
    SaveOldValuesOnSaving();          // Запоминаем старые Owner/Contact
    SetRemindDatesOnSaving();         // Корректировка дат напоминаний при смене StartDate
    CalculateDurationOnSaving();      // DurationInMinutes, DurationInMnutesAndHours
    SavingEmailOnSaving();            // Preview из HTML, MailHash, права email
    SetTypeByCategoryOnSaving();      // TypeId по ActivityCategory
    CheckNeedAutoEmailRelation();     // Флаг автосвязи
    InitCanGenerateAnniversaryReminding();
    return true;
}

public virtual void CalculateDurationOnSaving() {
    TimeSpan duration = Entity.DueDate - Entity.StartDate;
    Entity.DurationInMinutes = (int)duration.TotalMinutes;
    Entity.DurationInMnutesAndHours =
        string.Concat((int)duration.TotalHours, Hour, duration.Minutes, Minute);
}
```

#### Обработка после сохранения — OnActivitySaved

```csharp
public virtual bool OnActivitySaved(ProcessExecutingContext context) {
    SetActivityParticipantRightsOnSaved();
    Guid typeId = Entity.GetTypedColumnValue<Guid>(typeColumnValueName);

    if (typeId == ActivityConsts.EmailTypeUId) {
        InitializeEmailParticipantHelper().InitializeParameters(Entity);
        AutoEmailRelationProceed();
        InitializeEmailParticipantHelper().SetEmailParticipants();
    } else {
        UpdateParticipantsByOwnerContact();
        AutoEmailRelationProceed();
        CreateActivityParticipantsFromInsertedValues();
    }
    return true;
}
```

#### Права на email

```csharp
public virtual void SetActivityParticipantRightsOnSaved() {
    Guid author = Entity.GetTypedColumnValue<Guid>("AuthorId");
    Guid owner = Entity.GetTypedColumnValue<Guid>("OwnerId");
    if (Entity.GetTypedColumnValue<Guid>("EmailSendStatusId")
        != ActivityConsts.IncomingEmailTypeId) return;

    // SysAdminUnit отправителя по email → полные права на запись
    var esq = new EntitySchemaQuery(UserConnection.EntitySchemaManager, "SysAdminUnit");
    esq.Filters.Add(esq.CreateFilterWithParameters(
        FilterComparisonType.Equal,
        "[ContactCommunication:Contact:Contact].Number", SenderEmail));
    EntityCollection entities = esq.GetEntityCollection(UserConnection);
    if (entities.Count > 0) {
        Guid adminUnitId = entities.First.Value.PrimaryColumnValue;
        UserConnection.DBSecurityEngine.SetEntitySchemaRecordRightLevel(
            adminUnitId, Entity.Schema,
            Entity.PrimaryColumnValue, SchemaRecordRightLevels.All);
    }
}
```

#### Работа с участниками email

```csharp
public virtual Guid FindEmailSendStatusByCode(string emailSendStatusCode) {
    var esq = new EntitySchemaQuery(UserConnection.EntitySchemaManager, "EmailSendStatus") {
        Cache = UserConnection.ApplicationCache,
        CacheItemName = $"EmailSendStatus_GetByCode_{emailSendStatusCode}"
    };
    esq.Filters.Add(esq.CreateFilterWithParameters(
        FilterComparisonType.Equal, "Code", emailSendStatusCode));
    EntityCollection entityCollection = esq.GetEntityCollection(UserConnection);
    return entityCollection.Count > 0
        ? entityCollection[0].PrimaryColumnValue
        : Guid.Empty;
}

public virtual bool DoCollectEmailParticipants() {
    Guid typeId = Entity.GetTypedColumnValue<Guid>(typeColumnValueName);
    return typeId == ActivityConsts.EmailTypeUId;
}
```

#### Формирование email Preview и MailHash

```csharp
public virtual void SavingEmailOnSaving() {
    // ...
    string body = (string)Entity.GetColumnValue("Body");
    Entity.SetColumnValue("Preview",
        StringUtilities.GetPlainTextFromHtml(body, 245));

    if (Entity.GetColumnValue("SendDate") != null) {
        string hash = Entity.GetTypedColumnValue<string>("MailHash");
        if (string.IsNullOrEmpty(hash)) {
            string title = (string)Entity.GetColumnValue("Title");
            DateTime sendDate = (DateTime)Entity.GetColumnValue("SendDate");
            hash = ActivityUtils.GetEmailHash(UserConnection,
                (string)Entity.GetColumnValue("Sender"),
                sendDate, title, body,
                UserConnection.CurrentUser.TimeZone);
            Entity.SetColumnValue("MailHash", hash);
        }
    }
    EmailRightsManager rightsManager = GetEmailRightsManager();
    rightsManager.SetUseDefRights(Entity);
}
```

### Сводная таблица EventsProcess базового решения

| Сущность | Файл логики | Кол-во методов | Ключевые области логики |
|----------|------------|----------------|------------------------|
| **BaseEntity** | `BaseEntitySchema.Base.cs` | 12 | ProcessComplete, DCM, индексация, валидация |
| **Account** | `Account.Base.cs` | 14 | Адреса, коммуникации, связи (Relationship), PrimaryContact, напоминания |
| **Contact** | `Contact.Base.cs` | 24 | SGM/Name, карьера (ContactCareer), адреса, коммуникации, возраст, напоминания |
| **Activity** | `Activity.Base.cs` | 40+ | Email-участники, права, Preview/MailHash, длительность, напоминания, AutoEmailRelation |
| **Lookup** | `LookupSchema.Base.cs` | 0 | Нет собственной логики (только базовая) |

### Паттерны для разработчиков

#### Доступ к данным в EventsProcess

```csharp
// Текущее значение
Entity.GetTypedColumnValue<Guid>("AccountId")
Entity.GetTypedColumnValue<string>("Name")

// Старое значение (до изменения)
Entity.GetTypedOldColumnValue<Guid>("AccountId")

// Проверка изменённых колонок
IEnumerable<EntityColumnValue> changed = Entity.GetChangedColumnValues();
bool nameChanged = changed.Any(col => col.Name == "Name");

// Состояние записи
Entity.StoringState == StoringObjectState.New     // вставка
Entity.StoringState == StoringObjectState.Changed  // обновление
Entity.StoringState == StoringObjectState.Deleted  // удаление

// Первичный ключ
Entity.PrimaryColumnValue
```

#### Работа с ESQ в EventsProcess

```csharp
var esq = new EntitySchemaQuery(UserConnection.EntitySchemaManager, "ContactCareer");
esq.AddAllSchemaColumns();
esq.Filters.Add(esq.CreateFilterWithParameters(
    FilterComparisonType.Equal, "Contact", Entity.PrimaryColumnValue));
var collection = esq.GetEntityCollection(UserConnection);
```

#### Работа с SQL-билдером

```csharp
var update = new Update(UserConnection, "ContactCareer")
    .Set("Current", Column.Parameter(false))
    .Set("DueDate", Column.Parameter(DateTime.Now))
    .Where("ContactId").IsEqual(Column.Parameter(Entity.PrimaryColumnValue))
    .And("Current").IsEqual(Column.Parameter(true));
update.Execute();
```

#### CommunicationSynchronizer

```csharp
var communicationColumns = new Dictionary<string, Guid> {
    {"Phone", new Guid(CommunicationTypeConsts.MainPhoneId)},
    {"Email", new Guid(CommunicationTypeConsts.EmailId)}
};
var helper = ClassFactory.Get<CommunicationSynchronizer>(
    new ConstructorArgument("userConnection", UserConnection),
    new ConstructorArgument("entity", Entity));
helper.InitializeCommunicationItems(communicationColumns);
helper.SynchronizeCommunications();
```

#### Системные настройки

```csharp
var value = (bool)SysSettings.GetValue(UserConnection, "ActualizeAge");
var relationTypeId = (Guid)SysSettings.GetValue(UserConnection, "ParentAccountRelationType");
```

---

## Типовые сценарии

### 1. Валидация данных перед сохранением (OnSaving + e.IsCanceled)

```csharp
[EntityEventListener(SchemaName = "Order")]
public class OrderValidationEventListener : BaseEntityEventListener
{
    public override void OnSaving(object sender, EntityBeforeEventArgs e)
    {
        var entity = (Entity)sender;
        decimal amount = entity.GetTypedColumnValue<decimal>("Amount");
        if (amount <= 0) {
            e.IsCanceled = true;
            throw new ValidationException("Сумма заказа должна быть больше нуля");
        }
    }
}
```

### 2. Автозаполнение полей при создании записи (OnInserting)

```csharp
[EntityEventListener(SchemaName = "Activity")]
public class ActivityAutoFillEventListener : BaseEntityEventListener
{
    public override void OnInserting(object sender, EntityBeforeEventArgs e)
    {
        var entity = (Entity)sender;
        var userConnection = entity.UserConnection;
        if (entity.GetTypedColumnValue<Guid>("OwnerId") == Guid.Empty) {
            entity.SetColumnValue("OwnerId", userConnection.CurrentUser.ContactId);
        }
        if (entity.GetTypedColumnValue<DateTime>("StartDate") == DateTime.MinValue) {
            entity.SetColumnValue("StartDate", DateTime.UtcNow);
        }
    }
}
```

### 3. Каскадное обновление связанных записей после сохранения (OnSaved)

```csharp
[EntityEventListener(SchemaName = "Account")]
public class AccountCascadeEventListener : BaseEntityEventListener
{
    public override void OnSaved(object sender, EntityAfterEventArgs e)
    {
        var entity = (Entity)sender;
        var userConnection = entity.UserConnection;
        var changedColumns = entity.GetChangedColumnValues();
        bool cityChanged = changedColumns.Any(c => c.Name == "CityId");
        if (!cityChanged) return;

        Guid newCityId = entity.GetTypedColumnValue<Guid>("CityId");
        var update = new Update(userConnection, "Contact")
            .Set("CityId", Column.Parameter(newCityId))
            .Where("AccountId").IsEqual(Column.Parameter(entity.PrimaryColumnValue));
        update.Execute();
    }
}
```

### 4. Регистрация Quartz-задачи при старте приложения (IAppEventListener.OnAppStart)

```csharp
public class DataCleanupAppEventListener : IAppEventListener
{
    public void OnAppStart(AppEventContext context)
    {
        var userConnection = context.GetUserConnection();
        var scheduler = ClassFactory.Get<IAppSchedulerWraper>();
        scheduler.ScheduleImmediateProcessJob(
            "DataCleanupJob", "CleanupGroup",
            "CleanupExpiredRecordsProcess",
            context.Application["AppConnection"] as AppConnection,
            new Dictionary<string, object>());
    }

    public void OnAppEnd(AppEventContext context) { }
    public void OnSessionStart(AppEventContext context) { }
    public void OnSessionEnd(AppEventContext context) { }
}
```

### 5. Проверка изменения конкретной колонки (GetChangedColumnValues)

```csharp
[EntityEventListener(SchemaName = "Contact")]
public class ContactStatusChangeEventListener : BaseEntityEventListener
{
    public override void OnSaving(object sender, EntityBeforeEventArgs e)
    {
        var entity = (Entity)sender;
        var changedColumns = entity.GetChangedColumnValues();
        var statusChanged = changedColumns.FirstOrDefault(c => c.Name == "StatusId");
        if (statusChanged == null) return;

        Guid oldStatusId = (Guid)(statusChanged.OldValue ?? Guid.Empty);
        Guid newStatusId = entity.GetTypedColumnValue<Guid>("StatusId");

        if (oldStatusId != Guid.Empty && newStatusId != oldStatusId) {
            entity.SetColumnValue("StatusChangeDate", DateTime.UtcNow);
        }
    }
}
```

---

## Антипаттерны

### ❌ Длительные операции в OnSaving/OnInserting

Before-события выполняются внутри транзакции. Длительные операции блокируют запись и увеличивают время отклика.

```csharp
// ❌ Плохо — HTTP-вызов в OnSaving блокирует транзакцию
public override void OnSaving(object sender, EntityBeforeEventArgs e)
{
    var client = new RestClient("https://external-api.com");
    var response = client.Execute(new RestRequest("/notify", Method.POST)); // 2-5 сек
}

// ✅ Хорошо — перенести в OnSaved или асинхронную задачу
public override void OnSaved(object sender, EntityAfterEventArgs e)
{
    var entity = (Entity)sender;
    AsyncNotificationHelper.EnqueueNotification(entity.PrimaryColumnValue);
}
```

### ❌ Бесконечная рекурсия: EventListener изменяет ту же сущность

Изменение Entity внутри EventListener'а вызывает повторное срабатывание того же слушателя.

```csharp
// ❌ Плохо — бесконечный цикл
public override void OnSaved(object sender, EntityAfterEventArgs e)
{
    var entity = (Entity)sender;
    entity.SetColumnValue("ModifiedOn", DateTime.UtcNow);
    entity.Save(); // → снова OnSaved → снова Save → ...
}

// ✅ Хорошо — использовать Update builder (не триггерит EventListener)
// или проверять конкретные изменённые колонки
public override void OnSaved(object sender, EntityAfterEventArgs e)
{
    var entity = (Entity)sender;
    var changed = entity.GetChangedColumnValues();
    if (!changed.Any(c => c.Name == "StatusId")) return;

    var update = new Update(entity.UserConnection, entity.SchemaName)
        .Set("ProcessedOn", Column.Parameter(DateTime.UtcNow))
        .Where("Id").IsEqual(Column.Parameter(entity.PrimaryColumnValue));
    update.Execute();
}
```

### ❌ Обращение к GetTypedOldColumnValue в OnInserted

При вставке новой записи старых значений не существует — результат будет `default`.

```csharp
// ❌ Плохо
public override void OnInserted(object sender, EntityAfterEventArgs e)
{
    var entity = (Entity)sender;
    Guid oldOwner = entity.GetTypedOldColumnValue<Guid>("OwnerId"); // всегда Guid.Empty
}

// ✅ Хорошо — использовать только в Update-событиях (OnSaving, OnUpdating, OnSaved, OnUpdated)
public override void OnUpdated(object sender, EntityAfterEventArgs e)
{
    var entity = (Entity)sender;
    Guid oldOwner = entity.GetTypedOldColumnValue<Guid>("OwnerId");
    Guid newOwner = entity.GetTypedColumnValue<Guid>("OwnerId");
}
```

### ❌ Бросать необработанное исключение в OnSaved

В After-событиях запись уже сохранена. Исключение не откатит данные, но сломает пользовательский интерфейс.

```csharp
// ❌ Плохо
public override void OnSaved(object sender, EntityAfterEventArgs e)
{
    throw new Exception("Что-то пошло не так"); // данные уже в БД, UI получит ошибку
}

// ✅ Хорошо — обрабатывать ошибки и логировать
public override void OnSaved(object sender, EntityAfterEventArgs e)
{
    try {
        PerformPostSaveLogic((Entity)sender);
    } catch (Exception ex) {
        var log = LogManager.GetLogger("MyEventListener");
        log.Error("Ошибка в OnSaved для записи " +
            ((Entity)sender).PrimaryColumnValue, ex);
    }
}
```

---

## Troubleshooting

### Таблица ошибок

| Ошибка | Причина | Решение |
|--------|---------|---------|
| EventListener не срабатывает | Неверное имя схемы в атрибуте | Проверить `[EntityEventListener(SchemaName = "...")]` — имя должно совпадать с `Name` схемы, а не `Caption` |
| EventListener срабатывает дважды | Дублирование в разных пакетах | Проверить, нет ли одноимённого слушателя в замещающем пакете |
| `e.IsCanceled = true` не отменяет операцию | Используется в After-событии | `IsCanceled` работает только в Before-событиях: `OnSaving`, `OnInserting`, `OnDeleting` |
| AppEventListener не вызывается | Неполная реализация интерфейса | Реализовать все 4 метода `IAppEventListener`: `OnAppStart`, `OnAppEnd`, `OnSessionStart`, `OnSessionEnd` |
| `NullReferenceException` при получении `UserConnection` | Обращение к Entity до инициализации | Получать `UserConnection` через `((Entity)sender).UserConnection` |
| `StackOverflowException` | Рекурсивный вызов Save в EventListener | Использовать `Update` builder или проверять изменённые колонки перед Save |

### Советы по отладке

- Добавляйте логирование в начало каждого обработчика: `LogManager.GetLogger("MyListener").Debug("OnSaving triggered for " + entity.PrimaryColumnValue)`.
- Используйте `entity.GetChangedColumnValues()` для определения, какие колонки реально изменились.
- Для отладки AppEventListener проверяйте логи при перезапуске пула приложений в IIS.

### Известные ограничения

- `EntityEventListener` не срабатывает при массовых операциях через `Insert`/`Update`/`Delete` builder — только при работе через Entity API.
- В Before-событиях нельзя выполнять асинхронные операции (`async/await`) — транзакция завершится до их окончания.
- `OnDeleting` не предоставляет доступ к данным удаляемой записи — читайте их заранее или используйте `OnDeleted` с предварительным кэшированием.

---

## Связанные темы

- [Схемы сущностей](entity-schemas.md)
- [WCF-сервисы](services.md)
- [Планировщик Quartz](scheduler-quartz.md)
- [Базовые классы](../reference/base-classes.md)
