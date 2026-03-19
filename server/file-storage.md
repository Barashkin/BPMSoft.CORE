# Работа с файлами и хранилищами файлов

<!-- Версия: 1.0 | Обновлено: 2026-03-19 | Платформа: BPMSoft 1.9 -->
<!-- Теги: файлы, File, FileRepository, IFile, загрузка, хранилище, версионность, chunked upload -->

## 1. Архитектура файловой подсистемы

### Базовая сущность File

Все файловые сущности в BPMSoft наследуют от `File` (`File_Base_BPMSoft`, UId: `556c5867-60a7-4456-aae1-a57a122bef70`), которая наследует `BaseEntity`.

**Колонки базовой сущности File:**

| Колонка | Тип | Описание |
|---------|-----|----------|
| `Name` | MediumText | Имя файла (обязательное) |
| `Notes` | MaxSizeText | Описание / комментарий |
| `Data` | Binary | Бинарные данные файла |
| `Type` | Lookup → `FileType` | Тип: файл, ссылка, ссылка на сущность |
| `Version` | Integer | Номер версии (автоинкремент при изменении) |
| `Size` | Integer | Размер файла в байтах |
| `LockedBy` | Lookup → `Contact` | Кем заблокирован |
| `LockedOn` | DateTime | Дата/время блокировки |
| `SysFileStorage` | Lookup → `SysFileContentStorage` | Хранилище контента файла |

### Типы файлов (FileType, FileConsts)

```csharp
// FileConsts.Base.cs
public static readonly Guid FileTypeUId = new Guid("529BC2F8-0EE0-DF11-971B-001D60E938C6");       // Файл
public static readonly Guid LinkTypeUId = new Guid("539BC2F8-0EE0-DF11-971B-001D60E938C6");       // Ссылка
public static readonly Guid EntityLinkTypeUId = new Guid("549bc2f8-0ee0-df11-971b-001d60e938c6"); // Ссылка на сущность
```

### Конвенция именования файловых сущностей

Для каждой сущности, к которой нужно привязать файлы, создаётся отдельная сущность-наследник `File`:

| Сущность | Файловая сущность | Lookup-колонка |
|----------|-------------------|----------------|
| `Contact` | `ContactFile` | `Contact` |
| `Account` | `AccountFile` | `Account` |
| `Activity` | `ActivityFile` | `Activity` |
| `KnowledgeBase` | `KnowledgeBaseFile` | `KnowledgeBase` |
| `Product` | `ProductFile` | `Product` |
| `Employee` | `EmployeeFile` | `Employee` |
| `Call` | `CallFile` | `Call` |

**Паттерн:** `{EntityName}File` наследует `File` и добавляет Lookup-колонку `{EntityName}` → исходная сущность (с `IsCascade = true`).

---

## 2. Типы хранилищ контента

BPMSoft поддерживает подключаемые хранилища файлового контента через абстракцию `IFile` / `IFileFactory` (namespace `BPMSoft.File.Abstractions`).

### Настроечные сущности

| Сущность | Описание |
|----------|----------|
| `SysFileContentStorage` | Справочник хранилищ контента (наследник BaseLookup) |
| `SysFileMetadataStorage` | Справочник хранилищ метаданных (наследник BaseLookup) |

### Поддерживаемые хранилища

| Хранилище | Описание | Где хранится контент |
|-----------|----------|---------------------|
| **Database (по умолчанию)** | Контент хранится в колонке `Data` (Binary/varbinary) | Таблица самой сущности |
| **File API** | Абстракция IFile, используется при `GlobalAppSettings.FeatureUseFileApi = true` | Определяется конфигурацией IFileFactory |
| **External** | Через IFileFactory можно подключить внешние хранилища | Зависит от реализации |

### Режим File API

Когда включён Feature Toggle `FeatureUseFileApi`, вся работа идёт через:

```csharp
// Ключевые абстракции (BPMSoft.File.Abstractions)
IFileFactory fileFactory = userConnection.GetFileFactory();
var fileLocator = new EntityFileLocator(entitySchemaName, recordId);
IFile file = fileFactory.Get(fileLocator);    // получить файл
IFile file = fileFactory.Create(fileLocator); // создать файл
```

**Интерфейс IFile** предоставляет:
- `file.Name` — имя файла
- `file.Length` — размер
- `file.Exists` — существует ли
- `file.Read()` → `Stream` — чтение контента
- `file.Write(stream, FileWriteOptions)` — запись (Single/First/Next/FinalPart)
- `file.Delete()` — удаление
- `file.SetAttribute(name, value)` — установка атрибутов
- `file.SetAttributes(dictionary)` — массовая установка
- `file.GetStorageType()` — тип хранилища

Колонка `SysFileStorage` в базовой сущности `File` указывает, в каком хранилище расположен контент конкретного файла.

---

## 3. Добавление файлов в хранилище

### Серверная часть — FileRepository / FileUploader

```csharp
// Способ 1: через FileRepository
var repo = new FileRepository(userConnection);
var uploadInfo = new FileEntityUploadInfo("ContactFile", fileId, "document.pdf") {
    TotalFileLength = fileBytes.Length
};
uploadInfo.Content = new MemoryStream(fileBytes);
repo.UploadFile(uploadInfo);

// Способ 2: через FileUploader (более низкоуровневый)
var uploader = ClassFactory.Get<FileUploader>(
    new ConstructorArgument("userConnection", userConnection));
uploader.UploadFile(uploadInfo);

// Способ 3: через IFile API (рекомендуемый для нового кода)
IFileFactory fileFactory = userConnection.GetFileFactory();
var fileLocator = new EntityFileLocator("ContactFile", fileId);
IFile file = fileFactory.Create(fileLocator);
file.Name = "document.pdf";
file.SetAttribute("ContactId", contactId);
using (var stream = new MemoryStream(fileBytes)) {
    file.Write(stream, FileWriteOptions.SinglePart);
}
```

### Поддержка chunked upload

Для больших файлов поддерживается загрузка по частям:

```csharp
var config = new FileUploadConfig(fileUploadInfo) {
    SetCustomColumnsFromConfig = true
};
// Первый chunk: FileWriteOptions.FirstPart
// Промежуточные: FileWriteOptions.NextPart
// Последний: FileWriteOptions.FinalPart
uploader.UploadFile(config);
```

HTTP-заголовок `Content-Range` определяет границы чанка: `bytes 0-524287/1048576`.

### Ограничение размера

Системная настройка `MaxFileSize` (в МБ) ограничивает максимальный размер загружаемого файла. При превышении бросается `MaxFileSizeExceededException`.

### WCF-сервисы загрузки

| Сервис | URL | Метод | Описание |
|--------|-----|-------|----------|
| `FileApiService` | `/0/rest/FileApiService/UploadFile` | POST | Загрузка файла (рекомендуемый) |
| `FileService` | `/0/rest/FileService/GetFile/{schemaUId}/{fileId}` | GET | Скачивание файла |

**Пример загрузки через REST (HTTP POST multipart):**

```
POST /0/rest/FileApiService/UploadFile?
    entitySchemaName=ContactFile&
    fileId=<guid>&
    fileName=document.pdf&
    parentColumnName=Contact&
    parentColumnValue=<contact-guid>&
    totalFileLength=12345&
    columnName=Data
Content-Type: multipart/form-data
```

### Программное добавление через Entity API

```csharp
var schema = userConnection.EntitySchemaManager.GetInstanceByName("ContactFile");
var entity = schema.CreateEntity(userConnection);
entity.SetDefColumnValues();
entity.SetColumnValue("Id", Guid.NewGuid());
entity.SetColumnValue("Name", "Договор.pdf");
entity.SetColumnValue("ContactId", contactId);
entity.SetColumnValue("TypeId", FileConsts.FileTypeUId);
entity.SetStreamValue("Data", new MemoryStream(fileBytes));
entity.SetColumnValue("Size", fileBytes.Length);
entity.Save();
```

---

## 4. Версионность файлов

### Механизм автоматического версионирования

Версионность реализована в `File_BaseEventsProcess.OnFileSaving()`:

```csharp
public virtual void OnFileSaving() {
    var version = Entity.GetTypedOldColumnValue<int>("Version") ?? 1;
    var increaseVersion = false;
    var changedColumns = Entity.GetChangedColumnValues();
    var fileType = Entity.GetTypedColumnValue<Guid>("TypeId");
    var dataColumn = changedColumns.FirstOrDefault(col => col.Name == "Data");

    if (fileType == FileConsts.FileTypeUId) {
        // Для файлов — версия увеличивается при изменении Data
        if (dataColumn != null) increaseVersion = true;
    } else {
        // Для ссылок — версия увеличивается при изменении Name (URL)
        var oldName = Entity.GetTypedOldColumnValue<string>("Name");
        var newName = Entity.GetTypedColumnValue<string>("Name");
        if (newName != oldName) increaseVersion = true;
    }

    if (increaseVersion)
        Entity.SetColumnValue("Version", version + 1);
    else
        Entity.SetColumnValue("Version", version);
}
```

**Правила:**
- Тип `File` (529BC2F8...): версия +1 при изменении бинарных данных (`Data`)
- Тип `Link` (539BC2F8...): версия +1 при изменении имени/URL (`Name`)
- При создании записи версия устанавливается = 1
- При сохранении также автоматически пересчитывается `Size`
- `Name` и `Notes` проходят HTML-санитизацию (`HtmlSanitizerHelper.Sanitize`)

### Получение актуальной версии документа

Поскольку контент перезаписывается «на месте» (inplace), текущая запись всегда содержит последнюю версию:

```csharp
// Получить актуальный файл — просто прочитать текущую запись
var repo = new FileRepository(userConnection);
IFileUploadInfo fileInfo = repo.LoadFile(entitySchemaUId, fileId);
// fileInfo.Content или fileInfo.File.Read() — актуальный контент
// fileInfo.TotalFileLength — размер

// Через IFile API
var locator = new EntityFileLocator("ContactFile", fileId);
IFile file = userConnection.GetFileFactory().Get(locator);
using (Stream stream = file.Read()) {
    // актуальный контент
}
```

Колонка `Version` (integer) показывает, сколько раз файл обновлялся. Старые версии **не сохраняются** в базовом механизме — хранится только текущая.

### Блокировка файла

Для предотвращения одновременного редактирования:

```csharp
var entity = schema.CreateEntity(userConnection);
entity.FetchFromDB(fileId);
entity.SetColumnValue("LockedById", userConnection.CurrentUser.ContactId);
entity.SetColumnValue("LockedOn", DateTime.UtcNow);
entity.Save();

// Снятие блокировки
entity.SetColumnValue("LockedById", null);
entity.SetColumnValue("LockedOn", null);
entity.Save();
```

---

## 5. Удаление файлов

### Стандартное удаление

```csharp
// Способ 1: через FileRepository
var repo = new FileRepository(userConnection);
repo.DeleteFile("ContactFile", fileId);
// или массовое удаление:
repo.DeleteFiles("ContactFile", new[] { fileId1, fileId2 });

// Способ 2: через Entity API
var entity = schema.CreateEntity(userConnection);
if (entity.FetchFromDB(fileId)) {
    entity.Delete();
}

// Способ 3: через IFile API
var locator = new EntityFileLocator("ContactFile", fileId);
IFile file = userConnection.GetFileFactory().Get(locator);
file.Delete();
```

### Каскадное удаление файлов при удалении сущности

`BaseEntityFileDeleteListener` (зарегистрирован на `BaseEntity`) автоматически удаляет связанные файлы при удалении записи:

1. **OnDeleting** — перед удалением сущности:
   - Находит файловую сущность по конвенции `{EntityName}File`
   - Сохраняет Id файлов в `ApplicationData`
   - Обнуляет FK-ссылки файлов (чтобы не было FK-constraint ошибки)

2. **OnDeleted** — после успешного удаления:
   - Удаляет сами файлы через `IFile.Delete()`

3. **OnDeleteFailed** — при ошибке удаления:
   - Восстанавливает FK-ссылки файлов

**Feature Toggle:** `UseBaseEntityFileDeleteListener` (должен быть включён).

### Предотвращение удаления файла программно

**Способ 1: EntityEventListener на файловую сущность**

```csharp
[EntityEventListener(SchemaName = "ContactFile")]
public class ContactFileDeleteProtector : BaseEntityEventListener
{
    public override void OnDeleting(object sender, EntityBeforeEventArgs e) {
        base.OnDeleting(sender, e);
        var entity = (Entity)sender;
        var userConnection = entity.UserConnection;

        // Проверяем условие
        bool isProtected = CheckIfFileIsProtected(entity, userConnection);
        if (isProtected) {
            // Отменяем удаление
            e.IsCanceled = true;
            // Можно бросить исключение для информирования
            throw new InvalidOperationException("Удаление этого файла запрещено");
        }
    }

    private bool CheckIfFileIsProtected(Entity entity, UserConnection uc) {
        // Логика проверки: статус документа, роль пользователя и т.д.
        return entity.GetTypedColumnValue<string>("Name").Contains("protected");
    }
}
```

**Способ 2: Через EventsProcess (в файловой сущности)**

```csharp
public partial class ContactFile_BaseEventsProcess<TEntity>
{
    public override void OnFileDeleting() {
        var fileId = Entity.PrimaryColumnValue;
        if (IsDeleteForbidden(fileId)) {
            throw new InvalidOperationException("Файл защищён от удаления");
        }
    }
}
```

**Способ 3: Через права доступа (администрирование по записям)**

```csharp
// Запретить удаление записи файла через RecordRights
var securityEngine = userConnection.DBSecurityEngine;
securityEngine.SetEntitySchemaRecordRightLevel(
    schemaName: "ContactFile",
    recordId: fileId,
    sysAdminUnitId: userId,
    operation: SchemaRecordRightLevels.CanDelete,
    rightLevel: 0  // запрет
);
```

**Способ 4: Блокировка файла**

Заблокированный файл (`LockedBy != null`) можно проверять в EventListener и запрещать удаление всем, кроме заблокировавшего пользователя.

---

## 6. Привязка файлов к сущностям

### Шаг 1: Создание файловой сущности

Для привязки файлов к своей сущности `MyEntity` нужно создать наследника `File`:

**Схема `MyEntityFile`:**

```csharp
// Наследуется от File (UId: 556c5867-60a7-4456-aae1-a57a122bef70)
public class MyEntityFileSchema : BPMSoft.Configuration.FileSchema
{
    protected override void InitializeColumns() {
        base.InitializeColumns();
        Columns.Add(CreateMyEntityColumn());
    }

    protected virtual EntitySchemaColumn CreateMyEntityColumn() {
        return new EntitySchemaColumn(this, DataValueTypeManager.GetInstanceByName("Lookup")) {
            Name = "MyEntity",
            ReferenceSchemaUId = new Guid("<MyEntity-Schema-UId>"),
            IsIndexed = true,
            IsCascade = true  // каскадное удаление
        };
    }
}
```

### Шаг 2: Регистрация детали файлов на странице карточки (JS)

```javascript
define("MyEntityPageV2", [], function() {
    return {
        entitySchemaName: "MyEntity",
        details: {
            Files: {
                schemaName: "FileDetailV2",
                entitySchemaName: "MyEntityFile",
                filter: {
                    masterColumn: "Id",
                    detailColumn: "MyEntity"
                }
            }
        },
        diff: [
            {
                "operation": "insert",
                "name": "Files",
                "values": {
                    "itemType": BPMSoft.ViewItemType.DETAIL
                },
                "parentName": "NotesAndFilesTab",
                "propertyName": "items"
            }
        ]
    };
});
```

### Шаг 3: Программное добавление файла к сущности

```csharp
public void AttachFileToEntity(UserConnection userConnection, 
    Guid entityId, string fileName, byte[] fileData) 
{
    // 1. Создать запись в файловой сущности
    var schema = userConnection.EntitySchemaManager.GetInstanceByName("MyEntityFile");
    var fileEntity = schema.CreateEntity(userConnection);
    fileEntity.SetDefColumnValues();
    
    var fileId = Guid.NewGuid();
    fileEntity.SetColumnValue("Id", fileId);
    fileEntity.SetColumnValue("Name", fileName);
    fileEntity.SetColumnValue("MyEntityId", entityId);  // привязка к сущности
    fileEntity.SetColumnValue("TypeId", FileConsts.FileTypeUId);
    fileEntity.SetStreamValue("Data", new MemoryStream(fileData));
    fileEntity.SetColumnValue("Size", fileData.Length);
    fileEntity.Save();
}
```

**Через IFile API:**

```csharp
public void AttachFileViaApi(UserConnection userConnection,
    Guid entityId, string fileName, byte[] fileData)
{
    var fileId = Guid.NewGuid();
    var locator = new EntityFileLocator("MyEntityFile", fileId);
    IFileFactory factory = userConnection.GetFileFactory();
    IFile file = factory.Create(locator);
    file.Name = fileName;
    file.SetAttribute("MyEntityId", entityId);
    
    using (var stream = new MemoryStream(fileData)) {
        file.Write(stream, FileWriteOptions.SinglePart);
    }
}
```

### Добавление ссылки (вместо файла)

```csharp
fileEntity.SetColumnValue("Name", "https://example.com/document.pdf");
fileEntity.SetColumnValue("TypeId", FileConsts.LinkTypeUId);  // тип = ссылка
// Data не заполняется
fileEntity.Save();
```

### Клиентский JS — загрузка файла из карточки

```javascript
// FileDetailV2 автоматически обрабатывает Drag & Drop и кнопку "Добавить файл"
// Внутренне вызывает FileApiService/UploadFile

// Программная загрузка файла с клиента:
var url = BPMSoft.workspaceBaseUrl + "/rest/FileApiService/UploadFile";
var formData = new FormData();
formData.append("files", fileBlob, "document.pdf");
var queryParams = BPMSoft.QueryStringBuilder.build({
    entitySchemaName: "MyEntityFile",
    fileId: BPMSoft.generateGUID(),
    fileName: "document.pdf",
    parentColumnName: "MyEntity",
    parentColumnValue: entityId,
    totalFileLength: fileBlob.size,
    columnName: "Data"
});
Ext.Ajax.request({
    url: url + "?" + queryParams,
    rawData: formData,
    callback: function(options, success, response) { }
});
```

### Скачивание файла с клиента

```javascript
// URL для скачивания
var downloadUrl = BPMSoft.workspaceBaseUrl 
    + "/rest/FileService/GetFile/" 
    + entitySchemaUId + "/" + fileId;
window.open(downloadUrl);
```

---

## Таблица файлов исходного кода

### Серверная часть

| Файл | Пакет | Назначение |
|------|-------|------------|
| `FileSchema.Base.cs` | Base | Базовая схема File (колонки, наследование) |
| `File.Base.cs` | Base | EventsProcess: OnFileSaving (версия, размер, санитизация) |
| `FileConsts.Base.cs` | Base | Константы: FileTypeUId, LinkTypeUId, EntityLinkTypeUId |
| `FileRepository.Base.cs` | Base | Репозиторий: LoadFile, UploadFile, DeleteFile(s) |
| `FileLoader.Base.cs` | Base | Загрузка файла (DB / FileAPI) |
| `FileUploader.Base.cs` | Base | Сохранение файла (DB / FileAPI / chunked) |
| `FileUploadInfo.Base.cs` | Base | Парсинг HTTP-запроса загрузки |
| `FileEntityUploadInfo.Base.cs` | Base | Upload info для файловых сущностей |
| `FileUploadConfig.Base.cs` | Base | Конфигурация загрузки (chunk, maxSize) |
| `FileApiService.NUI.cs` | NUI | WCF: UploadFile |
| `FileServices.NUI.cs` | NUI | WCF: GetFile (скачивание) |
| `BaseEntityFileDeleteListener.Base.cs` | Base | Каскадное удаление файлов при удалении сущности |
| `FileSecurityExcludedUriEventListener.Base.cs` | Base | Безопасность файлов |
| `SysFileContentStorageSchema.Base.cs` | Base | Справочник хранилищ контента |
| `SysFileMetadataStorageSchema.Base.cs` | Base | Справочник хранилищ метаданных |
| `IEntityFileCopier.Base.cs` | Base | Интерфейс копирования файлов между сущностями |
| `AttachmentFileLoader.Base.cs` | Base | Загрузчик вложений |

### Файловые сущности базового решения

| Схема | Файл | Привязана к |
|-------|------|-------------|
| `ContactFile` | `ContactFileSchema.Base.cs` | Contact |
| `AccountFile` | `AccountFileSchema.Base.cs` | Account |
| `ActivityFile` | `ActivityFileSchema.Base.cs` | Activity |
| `KnowledgeBaseFile` | `KnowledgeBaseFileSchema.Base.cs` | KnowledgeBase |
| `ProductFile` | `ProductFileSchema.Base.cs` | Product |
| `EmployeeFile` | `EmployeeFileSchema.Base.cs` | Employee |
| `CallFile` | `CallFileSchema.Base.cs` | Call |
| `EmailTemplateFile` | `EmailTemplateFileSchema.Base.cs` | EmailTemplate |
| `MailboxSettingsFile` | `MailboxSettingsFileSchema.Base.cs` | MailboxSettings |
| `SysProcessFile` | `SysProcessFileSchema.Base.cs` | SysProcess |

### Клиентская часть

| Файл | Пакет | Назначение |
|------|-------|------------|
| `FileDetailV2.UIv2.js` | UIv2 | Деталь файлов для карточек |
| `ConfigurationFileApi.NUI.js` | NUI | API работы с файлами с клиента |
| `PrintableProcessModule.NUI.js` | NUI | Работа с файлами в процессах |
| `FileViewerSchema.UIv2.js` | UIv2 | Просмотр файлов |
| `FileViewerViewModel.UIv2.js` | UIv2 | ViewModel просмотра файлов |
| `FileSearchRowSchema.GlobalSearch.js` | GlobalSearch | Файлы в глобальном поиске |
| `FileTimelineItemView.Timeline.js` | Timeline | Файлы в Timeline |
| `MobileFileService.Mobile.js` | Mobile | Файлы в мобильном приложении |

### Системные настройки

| Настройка | Описание |
|-----------|----------|
| `MaxFileSize` | Максимальный размер файла (МБ, 0 = без ограничений) |
| `FileChunkBufferSize` | Размер chunk при чтении (по умолчанию из FileConstants.DefaultFileChunkBufferSize) |
| `FeatureUseFileApi` | Feature toggle: использовать IFile API вместо прямой записи в DB |
| `UseBaseEntityFileDeleteListener` | Feature toggle: каскадное удаление файлов |
| `UseContentStreamOnFileLoad` | Feature toggle: потоковое чтение при загрузке |

---

## Типовые сценарии

### 1. Загрузка файла на сервер через FileRepository

```csharp
var repo = new FileRepository(userConnection);
var fileId = Guid.NewGuid();
var uploadInfo = new FileEntityUploadInfo("ContactFile", fileId, "document.pdf") {
    TotalFileLength = fileBytes.Length
};
uploadInfo.Content = new MemoryStream(fileBytes);
repo.UploadFile(uploadInfo);
```

### 2. Скачивание файла через REST

```javascript
var downloadUrl = BPMSoft.workspaceBaseUrl
    + "/rest/FileService/GetFile/"
    + entitySchemaUId + "/" + fileId;
window.open(downloadUrl);
```

Серверная сторона:

```csharp
var locator = new EntityFileLocator("ContactFile", fileId);
IFile file = userConnection.GetFileFactory().Get(locator);
using (Stream stream = file.Read()) {
    // передать stream в HTTP-ответ
}
```

### 3. Привязка файловой сущности к своей entity

```csharp
// Шаг 1: создать схему MyEntityFile (наследник File) с Lookup-колонкой MyEntity
// Шаг 2: программное добавление файла
var schema = userConnection.EntitySchemaManager.GetInstanceByName("MyEntityFile");
var fileEntity = schema.CreateEntity(userConnection);
fileEntity.SetDefColumnValues();
fileEntity.SetColumnValue("Id", Guid.NewGuid());
fileEntity.SetColumnValue("Name", "Приложение.pdf");
fileEntity.SetColumnValue("MyEntityId", entityId);
fileEntity.SetColumnValue("TypeId", FileConsts.FileTypeUId);
fileEntity.SetStreamValue("Data", new MemoryStream(fileBytes));
fileEntity.SetColumnValue("Size", fileBytes.Length);
fileEntity.Save();
```

### 4. Chunked upload большого файла

```csharp
int chunkSize = 512 * 1024; // 512 KB
int totalLength = fileBytes.Length;

for (int offset = 0; offset < totalLength; offset += chunkSize) {
    int length = Math.Min(chunkSize, totalLength - offset);
    var chunk = new byte[length];
    Array.Copy(fileBytes, offset, chunk, 0, length);

    var uploadInfo = new FileEntityUploadInfo("ContactFile", fileId, "bigfile.zip") {
        TotalFileLength = totalLength,
        Content = new MemoryStream(chunk)
    };

    FileWriteOptions writeOption;
    if (offset == 0)
        writeOption = FileWriteOptions.FirstPart;
    else if (offset + length >= totalLength)
        writeOption = FileWriteOptions.FinalPart;
    else
        writeOption = FileWriteOptions.NextPart;

    var config = new FileUploadConfig(uploadInfo) {
        SetCustomColumnsFromConfig = true
    };
    uploader.UploadFile(config);
}
```

---

## Антипаттерны

| ❌ Неправильно | ✅ Правильно |
|---------------|-------------|
| Забыть `SetColumnValue("TypeId", FileConsts.FileTypeUId)` при создании файла — файл будет без типа, что нарушит логику версионирования | Всегда устанавливать `TypeId` при программном создании файловой записи |
| Не проверять `MaxFileSize` перед загрузкой — получите `MaxFileSizeExceededException` | Проверять размер файла до загрузки: `SysSettings.GetValue<int>(uc, "MaxFileSize")` |
| Читать весь файл в `byte[]` для больших файлов — `OutOfMemoryException` | Использовать потоковое чтение через `IFile.Read()` и обрабатывать данные чанками |

---

## Troubleshooting

| Ошибка / Симптом | Причина | Решение |
|-----------------|---------|---------|
| `MaxFileSizeExceededException` | Размер файла превышает системную настройку `MaxFileSize` | Увеличить `MaxFileSize` в системных настройках (значение в МБ, 0 = без ограничений) |
| Файл не привязан к записи | Не заполнена FK-колонка `{Entity}Id` при создании | Проверить что `SetColumnValue("{Entity}Id", parentId)` вызывается при создании записи файла |
| Версия файла не увеличивается | Файл имеет тип `Link` — версия растёт только при изменении `Name` | Для файлов типа `File` версия увеличивается при изменении `Data`; для `Link` — при изменении `Name` |
| Файл не удаляется каскадно | Feature toggle `UseBaseEntityFileDeleteListener` выключен | Включить feature toggle или добавить `IsCascade = true` на FK-колонку файловой сущности |

**Советы по отладке:**
- Проверить `SysFileStorage` — указывает на хранилище контента конкретного файла
- `LockedBy != null` означает что файл заблокирован для редактирования
- При проблемах с IFile API проверить `GlobalAppSettings.FeatureUseFileApi`

---

## Связанные темы

- [Схемы сущностей](entity-schemas.md)
- [EventListener'ы](event-listeners.md)
- [WCF-сервисы](services.md)
- [Страницы (FileDetailV2)](../client/pages-sections-details.md)
