# Активности и Email

<!-- Версия: 1.0 | Обновлено: 2026-03-19 | Платформа: BPMSoft 1.9 -->
<!-- Теги: активности, email, Activity, ActivityParticipant, EmailParticipantHelper, EmailRightsManager -->

## Обзор

Активность (Activity) — универсальная сущность BPMSoft для задач, звонков, email-сообщений, встреч. Тип определяется полем `Type` (Lookup → ActivityType). Email — это Activity с `Type = EmailTypeUId`.

**Файлы исходного кода:**
- `ActivitySchema.Base.cs` — схема сущности (45+ колонок)
- `Activity.Base.cs` — EventsProcess (~760 строк бизнес-логики)
- `ActivityConsts.Base.cs` — GUID-константы
- `ActivityUtils.Base.cs` — утилиты (хеш, парсинг адресов)
- `EmailParticipantHelper.Base.cs` — управление участниками email
- `EmailRightsManager.Base.cs` — права доступа к email
- `EmailMessageHelper.Base.cs` — создание EmailMessageData
- `ActivityParticipantSchema.Base.cs` — участники активности

---

## Схема Activity — колонки

**Schema UId:** `c449d832-a4cc-4b01-b9d5-8a12c42a9f89`
**Наследует:** `BaseEntitySchema`
**PrimaryDisplayColumn:** `Title`
**PrimaryOrderColumn:** `StartDate`
**OwnerColumn:** `Owner`

### Основные колонки

| Колонка | Тип | Обязательная | Индекс | Ссылка | Значение по умолчанию |
|---------|-----|:---:|:---:|--------|----------------------|
| Title | LongText | да | да | — | — |
| StartDate | DateTime | да | да | — | CurrentDateTime |
| DueDate | DateTime | да | да | — | CurrentDateTime |
| Priority | Lookup | да | да | ActivityPriority | `ab96fa02-7fe6-df11-971b-001d60e938c6` |
| Status | Lookup | да | да | ActivityStatus | `384d4b84-58e6-df11-971b-001d60e938c6` (New) |
| ActivityCategory | Lookup | да | да | ActivityCategory | `f51c4643-58e6-df11-971b-001d60e938c6` (Task) |
| Type | Lookup | — | да | ActivityType | `fbe0acdc-cfc0-df11-b00f-001d60e938c6` |
| Author | Lookup | — | да | Contact | CurrentUserContact |
| Owner | Lookup | — | да | Contact | CurrentUserContact |
| Organizer | Lookup | — | да | Contact | CurrentUserContact |
| OwnerRole | Lookup | — | да | SysAdminUnit | — |
| Result | Lookup | — | да | ActivityResult | — |
| Account | Lookup | — | да | Account | — |
| Contact | Lookup | — | да | Contact | — |

### Колонки для Email

| Колонка | Тип | Индекс | Описание |
|---------|-----|:---:|----------|
| Sender | MediumText | да | Адрес отправителя (форматированная строка) |
| Recepient | MaxSizeText | — | Получатели (To) |
| CopyRecepient | MaxSizeText | — | Копия (CC) |
| BlindCopyRecepient | MaxSizeText | — | Скрытая копия (BCC) |
| Body | MaxSizeText | — | HTML-тело письма |
| Preview | MediumText | — | Текстовое превью (до 245 символов) |
| IsHtmlBody | Boolean | — | Флаг HTML-тела |
| SendDate | DateTime | да | Дата отправки |
| EmailSendStatus | Lookup | да | Статус отправки → EmailSendStatus |
| MessageType | Lookup | да | Тип сообщения (входящее/исходящее) |
| MailHash | ShortText | — | Хеш для дедупликации |
| IsNeedProcess | Boolean | — | Требует обработки (пустые Contact/Account) |
| SenderContact | Lookup | да | Контакт отправителя |
| HeaderProperties | MaxSizeText | — | Заголовки письма |
| IsAutoSubmitted | Boolean | — | Автоматическая отправка |
| ActivityConnection | Lookup | да | Связанная Activity (self-reference) |

### Прочие колонки

| Колонка | Тип | Описание |
|---------|-----|----------|
| RemindToAuthor | Boolean | Напоминание автору |
| RemindToAuthorDate | DateTime | Дата напоминания автору |
| RemindToOwner | Boolean | Напоминание ответственному |
| RemindToOwnerDate | DateTime | Дата напоминания ответственному |
| DetailedResult | MaxSizeText | Подробный результат |
| Notes | MaxSizeText | Примечания |
| Color | Color | Цвет в расписании (`#405f97`) |
| DurationInMinutes | Integer | Длительность в минутах |
| DurationInMnutesAndHours | ShortText | Длительность (текст: "2ч 30мин") |
| AllowedResult | MaxSizeText | Допустимые результаты |
| ShowInScheduler | Boolean | Показывать в расписании |
| TimeZone | Lookup | Часовой пояс |
| ErrorOnSend | LongText | Ошибка отправки |
| ProcessElementId | Guid | Элемент процесса |
| GlobalActivityID | MediumText | Глобальный ID (Exchange) |
| CallDirection | Lookup | Направление звонка |
| CreatedByInvCRM | Boolean | Создано из CRM |

---

## Справочники Activity

### ActivityType (типы)

| GUID | Код | Описание |
|------|-----|----------|
| `fbe0acdc-cfc0-df11-b00f-001d60e938c6` | — | Задача (по умолчанию) |
| `IntegrationConsts.EmailTypeId` | Email | Email |
| `IntegrationConsts.MeetingTypeId` | Task | Встреча (TaskTypeUId) |
| `e1831dec-cfc0-df11-b00f-001d60e938c6` | Call | Звонок |
| `e3831dec-cfc0-df11-b00f-001d60e938c6` | Visit | Визит |

### ActivityStatus (статусы)

Schema: `BaseCodeLookup` + колонка `Finish` (Boolean)

| GUID | Описание |
|------|----------|
| `384d4b84-58e6-df11-971b-001d60e938c6` | Новая (New) — по умолчанию |
| `394d4b84-58e6-df11-971b-001d60e938c6` | В работе (InProgress) |
| `IntegrationConsts.ActivityCompletedStatusId` | Завершена (Completed) |
| `201cfba8-58e6-df11-971b-001d60e938c6` | Отменена (Canceled) |

### ActivityCategory (категории)

| GUID | Описание |
|------|----------|
| `f51c4643-58e6-df11-971b-001d60e938c6` | Задача (Task) — по умолчанию |
| `42c74c49-58e6-df11-971b-001d60e938c6` | Встреча (Appointment) |
| `IntegrationConsts.EmailCategoryId` | Email |

### EmailSendStatus (статусы отправки)

Schema: `BaseCodeLookup`

| GUID | Описание |
|------|----------|
| `20c0c460-6107-e011-a646-16d83cab0980` | Не отправлено (NotSend) |
| `603ba6af-6107-e011-a646-16d83cab0980` | В процессе (InProgress) |
| `IntegrationConsts.EmailSentStatusId` | Отправлено (Sended) |
| `7459545a-9229-4ee7-b501-03b8a50e2b39` | Открыто (Opened) |

### MessageType (тип сообщения)

| GUID | Описание |
|------|----------|
| `7f9d1f86-f36b-1410-068c-20cf30b39373` | Входящее (Incoming) |
| `7f6d3f94-f36b-1410-068c-20cf30b39373` | Исходящее (Outgoing) |

---

## ActivityConsts — GUID-константы

```csharp
public static class ActivityConsts
{
    // Роли участников
    public static readonly Guid ActivityParticipantRoleTo   = new Guid("3A6893CE-A6E1-DF11-971B-001D60E938C6");
    public static readonly Guid ActivityParticipantRoleCc   = new Guid("3C6893CE-A6E1-DF11-971B-001D60E938C6");
    public static readonly Guid ActivityParticipantRoleBcc  = new Guid("BA1A7ADD-A6E1-DF11-971B-001D60E938C6");
    public static readonly Guid ActivityParticipantRoleFrom = new Guid("6A6390C4-A6E1-DF11-971B-001D60E938C6");

    // Типы
    public static readonly Guid EmailTypeUId = IntegrationConsts.EmailTypeId;
    public static readonly Guid TaskTypeUId  = IntegrationConsts.MeetingTypeId;
    public static readonly Guid CallTypeUId  = new Guid("E1831DEC-CFC0-DF11-B00F-001D60E938C6");

    // Статусы
    public static readonly Guid NewStatusUId        = new Guid("384D4B84-58E6-DF11-971B-001D60E938C6");
    public static readonly Guid InProgressUId       = new Guid("394D4B84-58E6-DF11-971B-001D60E938C6");
    public static readonly Guid CanceledStatusUId   = new Guid("201CFBA8-58E6-DF11-971B-001D60E938C6");

    // Email статусы
    public static readonly Guid IncomingEmailTypeId    = new Guid("7F9D1F86-F36B-1410-068C-20CF30B39373");
    public static readonly Guid OutgoingEmailTypeId    = new Guid("7F6D3F94-F36B-1410-068C-20CF30B39373");
    public static readonly Guid NotSendEmailStatusId   = new Guid("20C0C460-6107-E011-A646-16D83CAB0980");
    public static readonly Guid InProgressEmailStatusId = new Guid("603BA6AF-6107-E011-A646-16D83CAB0980");

    // Результат
    public static readonly Guid PositiveActivityResultCategoryId =
        new Guid("1D2E48F2-C5FD-417D-9551-30E71F35DF3D");

    // Ответы участников
    public static readonly Guid ParticipantResponseConfirmedId = new Guid("7098C892-34E3-4A3E-AF08-C1A139F63220");
    public static readonly Guid ParticipantResponseDeclinedId  = new Guid("CC256758-4051-4021-9C51-216E37635C46");
    public static readonly Guid ParticipantResponseInDoubtId   = new Guid("50E89724-522D-446E-BE91-12548B8C834D");
}
```

---

## ActivityParticipant — участники активности

**Schema UId:** определяется в `ActivityParticipantSchema.Base.cs`

| Колонка | Тип | Описание |
|---------|-----|----------|
| Activity | Lookup → Activity | Активность |
| Participant | Lookup → Contact | Участник (контакт) |
| Role | Lookup → ActivityParticipantRole | Роль (From/To/CC/BCC) |
| Description | LongText | Описание |
| ReadMark | Boolean | Отметка прочтения |
| InviteParticipant | Boolean | Приглашение |
| InviteResponse | Lookup → ParticipantResponse | Ответ на приглашение |

### EventsProcess участников

При сохранении/удалении участника:
- Обновление `ActivityCorrespondence` и `ModifiedOn` активности
- Установка прав доступа для Owner и отправителя
- Управление `InviteActivityParticipant`
- Удаление дубликатов
- Обновление напоминаний

---

## Серверная бизнес-логика (Activity_BaseEventsProcess)

### Жизненный цикл задачи

#### При вставке (Inserting)

```csharp
public virtual bool OnActivityInserting(ProcessExecutingContext context) {
    Guid typeId = Entity.GetTypedColumnValue<Guid>(typeColumnValueName);
    if (typeId == ActivityConsts.EmailTypeUId) {
        Entity.SetColumnValue("EmailSendStatusId", ActivityConsts.NotSendEmailStatusId);
    }
    SetEmailIsNeedProcess();
    return true;
}

public virtual void SetEmailIsNeedProcess() {
    // Если Contact и Account пусты → IsNeedProcess = true
    if (GetIsColumnValueEmpty("ContactId") && GetIsColumnValueEmpty("AccountId")) {
        Entity.SetColumnValue("IsNeedProcess", true);
    }
}
```

#### При сохранении (Saving)

```csharp
public virtual bool OnActivitySaving(ProcessExecutingContext context) {
    SaveOldValuesOnSaving();
    SetRemindDatesOnSaving();
    CalculateDurationOnSaving();
    SavingEmailOnSaving();
    SetTypeByCategoryOnSaving();
    CheckNeedAutoEmailRelation();
    InitCanGenerateAnniversaryReminding();
    return true;
}
```

**Расчёт длительности:**

```csharp
public virtual void CalculateDurationOnSaving() {
    TimeSpan duration = Entity.DueDate - Entity.StartDate;
    Entity.DurationInMinutes = (int)duration.TotalMinutes;
    Entity.DurationInMnutesAndHours =
        string.Concat((int)duration.TotalHours, Hour, duration.Minutes, Minute);
}
```

**Установка типа по категории:**

```csharp
public virtual void SetTypeByCategoryOnSaving() {
    Guid typeId = Entity.GetTypedColumnValue<Guid>(typeColumnValueName);
    if (typeId != Guid.Empty) return;
    Guid categoryId = Entity.GetTypedColumnValue<Guid>("ActivityCategoryId");
    // Определяет TypeId по ActivityCategory.ActivityType
}
```

#### После сохранения (Saved)

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

#### Валидация

```csharp
public virtual bool OnActivityValidating(ProcessExecutingContext context) {
    // Owner или OwnerRole обязательны
    if (GetIsOwnerNotAssigned()) {
        // Feature "UseProcessPerformerAssignment" + пустой OwnerId
    }
    return true;
}
```

### Управление участниками (не-email)

При сохранении обычной задачи/встречи Owner и Contact автоматически добавляются как участники:

```csharp
public virtual void UpdateParticipantsByOwnerContact() {
    // Если Owner изменился → удаляет старого, добавляет нового
    // Если Contact изменился → аналогично
    DeleteOldOwnerAndContactParticipants();
    // Добавляет Owner и Contact в InsertedValues
}

public virtual void CreateActivityParticipantsFromInsertedValues() {
    var insertedValues = InsertedValues as Dictionary<Guid, object>;
    if (insertedValues == null || insertedValues.Count == 0) return;
    foreach (var kvp in insertedValues) {
        // Создаёт ActivityParticipant с Participant = kvp.Key
    }
}

public virtual void AddActivityParticipantToInsertedValues(Guid participantId,
    Dictionary<string, object> participantParams, bool overrideExistingParticipant) {
    var insertedValues = (InsertedValues as Dictionary<Guid, object>)
        ?? new Dictionary<Guid, object>();
    InsertedValues = insertedValues;
    if (overrideExistingParticipant || !insertedValues.ContainsKey(participantId)) {
        insertedValues[participantId] = participantParams;
    }
}
```

---

## Email — серверная обработка

### Формирование Preview и MailHash

При сохранении email автоматически:
1. Извлекает текстовое превью из HTML-тела (до 245 символов)
2. Генерирует хеш для дедупликации

```csharp
public virtual void SavingEmailOnSaving() {
    string body = (string)Entity.GetColumnValue("Body");
    Entity.SetColumnValue("Preview", StringUtilities.GetPlainTextFromHtml(body, 245));

    if (Entity.GetColumnValue("SendDate") != null) {
        string hash = Entity.GetTypedColumnValue<string>("MailHash");
        if (string.IsNullOrEmpty(hash)) {
            hash = ActivityUtils.GetEmailHash(UserConnection,
                (string)Entity.GetColumnValue("Sender"),
                (DateTime)Entity.GetColumnValue("SendDate"),
                (string)Entity.GetColumnValue("Title"),
                body, UserConnection.CurrentUser.TimeZone);
            Entity.SetColumnValue("MailHash", hash);
        }
    }
    EmailRightsManager rightsManager = GetEmailRightsManager();
    rightsManager.SetUseDefRights(Entity);
}
```

### Управление участниками email (EmailParticipantHelper)

`EmailParticipantHelper` — специализированный класс для парсинга адресов и создания ActivityParticipant'ов.

```csharp
var helper = InitializeEmailParticipantHelper();
helper.InitializeParameters(Entity);

// Парсит Sender, Recepient, CopyRecepient, BlindCopyRecepient
// Находит Contact'ы по email-адресам
// Создаёт ActivityParticipant с ролями From/To/CC/BCC
helper.SetEmailParticipants();
```

**Ключевые методы:**
- `InitializeParameters(Entity email)` — парсинг полей email в списки адресов
- `SetEmailParticipants()` — создание/обновление участников
- `RemoveEmailParticipantByContactId(Guid contactId)` — удаление участника
- `SetEmailSenderContact()` — установка SenderContact по адресу отправителя
- `GetContactsByEmails()` — поиск контактов по email через ContactCommunication

### Права доступа к email (EmailRightsManager)

```csharp
public class EmailRightsManager {
    // Отключает UseDefRights для email
    public void SetUseDefRights(Entity activity);

    // Устанавливает права на запись по mailbox
    public void SetRecordRightsFromMailbox(Entity activity, Guid mailboxId);

    // Устанавливает права автора
    public void SetAuthorRights(Entity activity);
}
```

При сохранении входящего email даёт полные права отправителю и владельцу:

```csharp
public virtual void SetActivityParticipantRightsOnSaved() {
    if (Entity.GetTypedColumnValue<Guid>("EmailSendStatusId")
        != ActivityConsts.IncomingEmailTypeId) return;

    // Ищет SysAdminUnit по email отправителя через ContactCommunication
    var esq = new EntitySchemaQuery(UserConnection.EntitySchemaManager, "SysAdminUnit");
    esq.Filters.Add(esq.CreateFilterWithParameters(
        FilterComparisonType.Equal,
        "[ContactCommunication:Contact:Contact].Number", SenderEmail));
    // → SetEntitySchemaRecordRightLevel(adminUnitId, SchemaRecordRightLevels.All)

    // Аналогично для Owner
}
```

### EmailMessageData

Создаётся при вставке email для хранения метаданных синхронизации:

| Колонка | Тип | Описание |
|---------|-----|----------|
| Activity | Lookup → Activity | Связанная активность |
| Owner | Lookup → Contact | Владелец |
| Role | Lookup | Роль |
| Headers | MaxSizeText | MIME-заголовки |
| IsNeedProcess | Boolean | Требует обработки |
| MailboxSyncSettings | Lookup | Настройки почтового ящика |
| MessageId | ShortText | Message-ID заголовка |
| InReplyTo | ShortText | In-Reply-To заголовка |
| ParentMessage | Lookup (self) | Родительское сообщение |
| ConversationId | ShortText | ID цепочки переписки |
| SendDate | DateTime | Дата отправки |

**EmailMessageHelper** создаёт запись при вставке Activity типа Email:

```csharp
public void CreateEmailMessage(Entity activity, Guid mailboxId) {
    // Создаёт EmailMessageData
    // Заполняет MessageId, Headers, MailboxSyncSettings
}

public void OnEmailMessageDataInserted(Entity emailMessageData) {
    // Установка прав, обработка цепочки переписки
}
```

### AutoEmailRelation

При сохранении email автоматически привязывает контрагента/контакт по адресам получателей:

```csharp
public virtual void AutoEmailRelationProceed() {
    if (!IsNeedAutoEmailRelation) return;
    ActivityUtils.SetEmailRelations(UserConnection, Entity);
}

public virtual void CheckNeedAutoEmailRelation() {
    // Проверяет изменение Title, Sender, Recepient
    var changedColumns = Entity.GetChangedColumnValues();
    IsNeedAutoEmailRelation = changedColumns.Any(col =>
        col.Name == "Title" || col.Name == "Sender" || col.Name == "Recepient");
}
```

---

## ActivityUtils — утилиты

```csharp
public static class ActivityUtils {
    // Хеш email для дедупликации
    public static string GetEmailHash(UserConnection uc, string sender,
        DateTime sendDate, string subject, string body, TimeZoneInfo tz);

    // Автопривязка email к Account/Contact
    public static void SetEmailRelations(UserConnection uc, Entity activity);

    // Парсинг email-адресов
    public static string ExtractEmailAddress(string address);  // "Name <a@b.com>" → "a@b.com"

    // Получение email отправителя
    public static string GetSenderEmail(Entity entity);

    // Поиск дублей email
    public static List<Guid> GetExistingEmaisIds(UserConnection uc,
        string sender, DateTime sendDate, string subject, string body, TimeZoneInfo tz);

    // Обрезка заголовка
    public static string FixActivityTitle(string value, UserConnection uc,
        int maxLength = 256, string replacer = "...");

    // Роли участников
    public static Dictionary<string, Guid> GetParticipantsRoles(UserConnection uc);

    // Кеш активностей
    public static void ClearActivityCache(UserConnection uc);
}
```

---

## Клиентская часть (JavaScript)

### Архитектура страниц

```
ActivityPageV2.UIv2.js          — карточка задачи/встречи
    ├── Mixins: ActivityDatesMixin, ActivityTimezoneMixin
    ├── Details: Files, ActivityParticipant, EntityConnections, EmailDetailV2
    └── Tabs: GeneralInfo, Participants, Files/Notes, Email

EmailPageV2.UIv2.js             — карточка email (Activity с Type=Email)
    ├── Mixins: EmailActionsMixin, ActivityDatesMixin, EmailImageMixin,
    │          EmailRelationsMixin, ExtendedHtmlEditModuleUtilities
    ├── Details: EmailFileDetailV2, EmailEntityConnectionsDetailV2, RelatedEmails
    └── Tabs: EmailMessage, GeneralInfo, Attachments

ActivitySectionV2.NUI.js        — секция (реестр + расписание)
    ├── Mixins: GoogleIntegrationUtils
    ├── Фильтр: исключает Type=Email
    └── Кнопки: Open, Copy, Delete + Send/Reply/ReplyAll/Forward для email

EmailMessagePublisherPage.*.js  — публикация email из Actions Dashboard
    ├── Mixins: MacrosUtilities, EmailActionsMixin, EmailImageMixin
    └── Действия: Send, Template, Macros
```

### ActivityPageV2 — карточка задачи

**Файл:** `ActivityPageV2.UIv2.js`

**Ключевые атрибуты:**

| Атрибут | Тип | Описание |
|---------|-----|----------|
| Author | LOOKUP (required) | Автор |
| Status | LOOKUP (required) | Статус |
| StartDate, DueDate | DATE_TIME | Период |
| RemindToAuthor, RemindToOwner | BOOLEAN | Флаги напоминаний |
| ActivityCategory | LOOKUP | Категория |
| Result | LOOKUP | Результат |
| Owner, OwnerRole | LOOKUP | Ответственный / роль |
| Participants | CUSTOM_OBJECT | Коллекция участников |
| TimeZone | LOOKUP | Часовой пояс |

**Детали:**

| Деталь | Schema | Связь |
|--------|--------|-------|
| Files | ActivityFile | Activity = Id |
| ActivityParticipant | ActivityParticipant | Activity = Id |
| EntityConnections | EntityConnection | — |
| EmailDetailV2 | Activity | ActivityConnection, Type=Email |

**Методы:**
- `onEntityInitialized` — инициализация, установка значений из расписания
- `validate` / `validateDueDate` — DueDate >= StartDate
- `activityResultValidator` — проверка обязательности результата при финальном статусе
- `setRemindDates` — автоустановка дат напоминаний
- `onStartDateChanged` / `onDueDateChanged` — коррекция дат
- `onStatusChanged` — логика при смене статуса
- `resultButtonClick` — обработка выбора результата
- `insertParticipants` — добавление участников при сохранении
- `emailDetailFilter` — фильтр для детали связанных email

### EmailPageV2 — карточка email

**Файл:** `EmailPageV2.UIv2.js`

**Дополнительные атрибуты:**

| Атрибут | Тип | Описание |
|---------|-----|----------|
| SenderEnum | ENUM | Выбранный почтовый ящик отправителя |
| Signature, UseSignature | TEXT / BOOLEAN | Подпись |
| PlainTextMode | BOOLEAN | Режим текста без разметки |
| IsSendButtonVisible | BOOLEAN | Видимость кнопки «Отправить» |
| IsReplyButtonVisible | BOOLEAN | Видимость «Ответить» |
| IsForwardButtonVisible | BOOLEAN | Видимость «Переслать» |
| MailboxSyncSettingsCollection | COLLECTION | Доступные почтовые ящики |
| EmailSendStatus | LOOKUP | Статус отправки |

**Методы:**
- `sendEmail` — отправка email
- `replyEmail` / `replyAllEmail` / `forwardEmail` — ответ / пересылка
- `checkSenderBeforeSend` — проверка отправителя перед отправкой
- `loadSenders` — загрузка доступных почтовых ящиков
- `setDefaultSenderEnum` — установка ящика по умолчанию
- `getEmailBodyForReply` — формирование тела для ответа
- `getTitleForReply` — добавление "Re:" / "Fwd:" к теме
- `addAttachmentsWithForwardOrReply` — копирование вложений
- `deleteDraft` — удаление черновика
- `onOpenEmailTemplate` — выбор шаблона email
- `macrosServiceCallback` — вставка макросов

### ActivitySectionV2 — секция

**Файл:** `ActivitySectionV2.NUI.js`

- Поддерживает два режима: реестр (grid) и расписание (scheduler)
- По умолчанию **исключает email** из реестра (фильтр `NotEmailFilter`)
- Не показывает EditPages для Email и Call в dropdown «Добавить»
- Подписывается на `GetIsVisibleEmailPageButtons` для отображения кнопок Send/Reply/Forward
- Методы расписания: `initScheduleGridData`, `loadSchedulerDataView`

### EmailMessagePublisherPage — публикация email

**Файл:** `EmailMessagePublisherPage.EmailMessagePublisher.js`

Используется в Actions Dashboard для быстрой отправки email из карточки:
- `getPublishData` — формирует данные для публикации
- `loadEmailData` — загрузка данных из email-запроса
- `loadSenders` / `setDefaultSenderEnum` — выбор почтового ящика
- `setDefaultRecepient` — автозаполнение получателя из карточки
- `onTemplateButtonClick` — выбор email-шаблона
- `onMacroButtonClicked` — вставка макроса
- `onImagePasted` — вставка изображений

### Ключевые миксины для email

| Миксин | Файл | Назначение |
|--------|------|------------|
| EmailActionsMixin | `EmailActionsMixin.NUI.js` | Отправка, ответ, пересылка |
| EmailRelationsMixin | `EmailRelationsMixin.UIv2.js` | Связи email с сущностями |
| EmailsSearchMixin | `EmailsSearchMixin.EmailsSearch.js` | Поиск получателей через Elasticsearch |
| EmailImageMixin | — | Вставка изображений в тело |
| ActivityDatesMixin | `ActivityDatesMixin.UIv2.js` | Управление датами активности |
| ActivityTimezoneMixin | `ActivityTimezoneMixin.UIv2.js` | Часовые пояса |

---

## Диаграмма обработки email

```
[Пользователь нажимает "Отправить"]
    │
    ▼
EmailPageV2.sendEmail()
    │ → checkSenderBeforeSend()
    │ → save()
    │
    ▼
[Серверная сторона — Activity EventsProcess]
    │
    ├── OnActivityInserting (если новый)
    │   └── EmailSendStatus = NotSend
    │   └── SetEmailIsNeedProcess()
    │
    ├── OnActivitySaving
    │   ├── CalculateDurationOnSaving()
    │   ├── SavingEmailOnSaving()
    │   │   ├── Preview = PlainTextFromHtml(Body, 245)
    │   │   ├── MailHash = GetEmailHash(...)
    │   │   └── EmailRightsManager.SetUseDefRights()
    │   ├── SetTypeByCategoryOnSaving()
    │   └── CheckNeedAutoEmailRelation()
    │
    ├── OnActivitySaved
    │   ├── SetActivityParticipantRightsOnSaved()
    │   ├── EmailParticipantHelper.InitializeParameters(Entity)
    │   ├── AutoEmailRelationProceed()  → SetEmailRelations()
    │   └── EmailParticipantHelper.SetEmailParticipants()
    │       ├── Парсинг Sender → From (ActivityParticipant)
    │       ├── Парсинг Recepient → To (ActivityParticipant)
    │       ├── Парсинг CopyRecepient → CC (ActivityParticipant)
    │       └── Парсинг BlindCopyRecepient → BCC (ActivityParticipant)
    │
    └── OnActivityInserted
        ├── Права автора
        └── EmailMessageHelper.CreateEmailMessage()
            └── EmailMessageData (MessageId, Headers, MailboxSyncSettings)
```

---

## Типовые сценарии

### 1. Создание задачи программно

```csharp
var schema = userConnection.EntitySchemaManager.GetInstanceByName("Activity");
var activity = schema.CreateEntity(userConnection);
activity.SetDefColumnValues();
activity.SetColumnValue("Id", Guid.NewGuid());
activity.SetColumnValue("Title", "Позвонить клиенту");
activity.SetColumnValue("StartDate", DateTime.UtcNow);
activity.SetColumnValue("DueDate", DateTime.UtcNow.AddHours(1));
activity.SetColumnValue("StatusId", ActivityConsts.NewStatusUId);
activity.SetColumnValue("OwnerId", userConnection.CurrentUser.ContactId);
activity.SetColumnValue("TypeId", ActivityConsts.TaskTypeUId);
activity.Save();
```

### 2. Отправка email через Activity

```csharp
var schema = userConnection.EntitySchemaManager.GetInstanceByName("Activity");
var email = schema.CreateEntity(userConnection);
email.SetDefColumnValues();
email.SetColumnValue("Id", Guid.NewGuid());
email.SetColumnValue("Title", "Тема письма");
email.SetColumnValue("Body", "<html><body>Текст письма</body></html>");
email.SetColumnValue("IsHtmlBody", true);
email.SetColumnValue("TypeId", ActivityConsts.EmailTypeUId);
email.SetColumnValue("Sender", "user@company.com");
email.SetColumnValue("Recepient", "client@example.com");
email.SetColumnValue("StartDate", DateTime.UtcNow);
email.SetColumnValue("DueDate", DateTime.UtcNow);
email.SetColumnValue("EmailSendStatusId", ActivityConsts.NotSendEmailStatusId);
email.SetColumnValue("MessageTypeId",
    new Guid("7F6D3F94-F36B-1410-068C-20CF30B39373")); // Исходящее
email.Save();
```

### 3. Получение участников активности

```csharp
var esq = new EntitySchemaQuery(userConnection.EntitySchemaManager, "ActivityParticipant");
esq.AddColumn("Participant.Name");
esq.AddColumn("Role.Name");
esq.Filters.Add(esq.CreateFilterWithParameters(
    FilterComparisonType.Equal, "Activity", activityId));
var participants = esq.GetEntityCollection(userConnection);
foreach (var p in participants) {
    string name = p.GetTypedColumnValue<string>("Participant_Name");
    string role = p.GetTypedColumnValue<string>("Role_Name");
}
```

### 4. Работа со статусами

```csharp
var entity = schema.CreateEntity(userConnection);
if (entity.FetchFromDB(activityId)) {
    entity.SetColumnValue("StatusId", ActivityConsts.InProgressUId);
    entity.Save();
}

// Завершение с результатом
entity.SetColumnValue("StatusId", IntegrationConsts.ActivityCompletedStatusId);
entity.SetColumnValue("ResultId", ActivityConsts.PositiveActivityResultCategoryId);
entity.Save();
```

---

## Антипаттерны

| ❌ Неправильно | ✅ Правильно |
|---------------|-------------|
| Создание Activity без обязательных полей (Title, StartDate, DueDate, Status) — приведёт к ошибке сохранения | Всегда заполнять обязательные поля или вызывать `SetDefColumnValues()` |
| Ручное создание ActivityParticipant вместо `EmailParticipantHelper` — дублирование логики парсинга адресов | Использовать `EmailParticipantHelper.SetEmailParticipants()` для email |
| Изменение полей email (Body, Recepient) после отправки — может нарушить цепочку переписки и MailHash | Для коррекции создавать новый email (Forward/Reply) |

---

## Troubleshooting

| Ошибка / Симптом | Причина | Решение |
|-----------------|---------|---------|
| Email не отправляется | `EmailSendStatus` не установлен или настройки MailboxSyncSettings некорректны | Проверить `EmailSendStatusId`, наличие записи в `MailboxSyncSettings` и подключение к SMTP |
| Участники email не создаются | Тип Activity ≠ `EmailTypeUId` | Убедиться что `TypeId = ActivityConsts.EmailTypeUId` перед сохранением |
| Preview пустой | `Body` не содержит HTML или не заполнен | Поле `Body` должно содержать HTML-разметку; Preview формируется автоматически из Body (до 245 символов) |
| `MailHash` не генерируется | `SendDate` пустое | Заполнить `SendDate` — хеш генерируется только при наличии даты отправки |

**Советы по отладке:**
- Проверить `ErrorOnSend` — содержит текст ошибки отправки
- `IsNeedProcess = true` означает, что Contact/Account не привязаны к email
- Журнал синхронизации: таблица `EmailMessageData`

---

## Связанные темы

- [EventListener'ы](event-listeners.md)
- [Схемы сущностей](entity-schemas.md)
- [Перечисления](../reference/enums-constants.md)
