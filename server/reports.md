# Отчёты и печатные формы

<!-- Версия: 1.0 | Обновлено: 2026-03-19 | Платформа: BPMSoft 1.9 -->
<!-- Теги: отчёты, печатные формы, Word, FastReport, DevExpress, IReportEngine, PDF -->

## Обзор

BPMSoft поддерживает три типа отчётов:

| Тип | Enum | Технология | Формат вывода |
|-----|------|-----------|---------------|
| **MS Word** | `ReportType.MsWord (1)` | OpenXML, MERGEFIELD-макросы | .docx, .pdf |
| **FastReport** | `ReportType.FastReport (2)` | FastReport .NET, шаблоны .frx | .pdf |
| **DevExpress** | — | DevExpress XtraReports (legacy, NETFRAMEWORK) | .pdf, .xlsx |

**Ключевые сущности БД:**

| Сущность | Описание |
|----------|----------|
| `SysModuleReport` | Регистрация отчёта: привязка к модулю, тип, шаблон |
| `SysModuleReportTable` | Табличные части Word-отчёта (макросы, фильтры, колонки) |
| `SysModuleReportType` | Справочник типов (MS Word, FastReport) |
| `SysReportFormat` | Форматы вывода (PDF, DOCX и т.д.) |
| `SysAllowedReportFormat` | Разрешённые форматы для конкретного отчёта |
| `FastReportTemplate` | Шаблоны FastReport (XML/FRX) |
| `FastReportDataSource` | Источники данных для FastReport |
| `SysReportTemplate` | Шаблоны Word Reporting |
| `Report` / `ReportFolder` | Каталог отчётов (папки, группировка) |

---

## Архитектура

```
┌────────────────────────────────────────────────────────────┐
│                      Клиент (JS)                           │
│                                                            │
│  ReportUtilities.NUI.js ──→ ReportService (WCF)            │
│  PrintReportUtilities.NUI.js ──→ ReportService             │
│  FastReportService.FastReport.js ──→ FastReportService      │
│  ReportEngineClient.Reports.js ──→ ReportEngineService     │
│  AsyncReportNotifier.Reports.js ← ServerChannel (WebSocket)│
└─────────────────────────┬──────────────────────────────────┘
                          │ REST
┌─────────────────────────▼──────────────────────────────────┐
│                      Сервер (C#)                           │
│                                                            │
│  ReportService.NUI.cs                                      │
│    ├── CreateReport() → ReportHelper → IReportGenerator    │
│    ├── GetReportFile() → Stream                            │
│    ├── GenerateMSWordReport() → WordReportGenerator        │
│    └── GenerateDevExpressReport() → IReportGenerator       │
│                                                            │
│  FastReportService.FastReportEngine.cs                      │
│    ├── CreateReport() → ReportGenerator → PDF              │
│    ├── GetReportFile() → Stream                            │
│    ├── UploadReportTemplate() / DownloadReportTemplate()   │
│    └── FastReportTemplateProvider, DataSourceBuilder        │
│                                                            │
│  ReportEngineService.Reports.cs (новый API)                │
│    └── IReportEngine → Generate(ReportSettings)            │
│                                                            │
│  AsyncReportGenerationService.Reports.cs                   │
│    └── Асинхронная генерация через очередь                 │
└────────────────────────────────────────────────────────────┘
```

---

## IReportEngine — новый унифицированный API

```csharp
public enum ReportType : byte
{
    MsWord = 1,
    FastReport = 2
}

public interface IReportTemplateInfo
{
    Guid Id { get; }
    string Caption { get; }
    ReportType Type { get; }
    string EntitySchemaName { get; }
}

public interface IReportResult
{
    byte[] Data { get; }
    Guid RecordId { get; }
    IReportTemplateInfo ReportTemplateInfo { get; }
    string ReportExtension { get; }
}

public interface IReportEngine
{
    IEnumerable<IReportResult> Generate(ReportSettings settings);
    IReadOnlyList<IReportTemplateInfo> GetReportTemplates();
}
```

**Использование:**

```csharp
var reportEngine = ClassFactory.Get<IReportEngine>();

// Получить список доступных шаблонов
var templates = reportEngine.GetReportTemplates();

// Генерация отчёта
var settings = new ReportSettings {
    Id = templateId,
    Filters = filters,
    IsSeparateReports = false
};
IEnumerable<IReportResult> results = reportEngine.Generate(settings);

foreach (var result in results) {
    byte[] reportBytes = result.Data;
    string extension = result.ReportExtension;  // ".pdf", ".docx"
    string caption = result.ReportTemplateInfo.Caption;
}
```

**Файл:** `IReportEngine.Base.cs`, `ReportEngine.Reports.cs`

---

## WCF-сервисы отчётов

### ReportService — MS Word / DevExpress

**URL:** `/0/rest/ReportService/{Method}`

| Метод | HTTP | Описание |
|-------|------|----------|
| `CreateReport` | POST | Генерация отчёта, возвращает ключ кеша |
| `CreateReportsList` | POST | Генерация нескольких отчётов по массиву recordIds |
| `GetReportFile/{key}` | GET | Скачивание файла отчёта по ключу |
| `GetExportToExcelKey` | POST | Экспорт в Excel |
| `GetExportToExcelData/{key}/{name}` | GET | Скачивание Excel-файла |

**Параметры CreateReport:**

```json
{
    "entitySchemaUId": "25d7c1ab-...",
    "reportSchemaUId": "...",
    "templateId": "...",
    "recordId": "...",
    "reportParameters": "{}",
    "format": "ms word"
}
```

**Серверный код:**

```csharp
// MS Word
var reportGenerator = ClassFactory.Get<IReportGenerator>("Word");
var config = new ReportGeneratorConfiguration {
    RecordId = new Guid(recordId),
    ReportTemplateId = templateId
};
ReportData reportData = reportGenerator.Generate(UserConnection, config);

// PDF-конвертация
if (format == "pdf") {
    var converter = new PdfConverter();
    reportData.Data = converter.Convert(reportData.Data);
    reportData.Format = "pdf";
}

// DevExpress (legacy, NETFRAMEWORK)
var reportGenerator = ClassFactory.Get<IReportGenerator>("DevExpress");
var config = new ReportGeneratorConfiguration {
    ReportTemplateId = reportSchemaId,
    EntitySchemaUId = entitySchemaUId,
    RecordId = recordId,
    ReportParameters = parameters
};
ReportData report = reportGenerator.Generate(UserConnection, config);
```

**Файл:** `ReportService.NUI.cs`

### FastReportService — FastReport

**URL:** `/0/rest/FastReportService/{Method}`

| Метод | HTTP | Описание |
|-------|------|----------|
| `CreateReport` | POST | Генерация PDF из FastReport-шаблона |
| `GetReportFile/{key}` | GET | Скачивание PDF |
| `DownloadReportTemplate/{templateId}` | GET | Скачивание .frx шаблона |
| `UploadReportTemplate` | POST (multipart) | Загрузка .frx шаблона |

**Параметры CreateReport:**

```json
{
    "reportTemplateId": "...",
    "reportCaption": "Мой отчёт",
    "reportSchemaName": "Contact",
    "reportFilters": "{...}"
}
```

**Серверный код:**

```csharp
var reportParameters = new Dictionary<string, object> {
    ["EsqFilters"] = new Dictionary<string, Filters> {
        [reportSchemaName] = JsonConvert.DeserializeObject<Filters>(reportFilters)
    }
};

IReportTemplateProvider templateProvider = new FastReportTemplateProvider(UserConnection);
IDataSourceBuilderResolver dataSourceResolver = new FastReportDataSourceBuilderResolver(UserConnection);
var reportGenerator = new ReportGenerator(templateProvider, dataSourceResolver);
byte[] pdfBytes = reportGenerator.Generate(templateId, reportParameters, ReportFormat.Pdf).Result;
```

**Файл:** `FastReportService.FastReportEngine.cs`

---

## MS Word отчёты — подробно

### Принцип работы

1. Шаблон `.docx` хранится в `SysModuleReport`
2. В шаблоне используются **MERGEFIELD**-макросы (поля слияния Word)
3. Табличные части настраиваются в `SysModuleReportTable` (колонки, фильтры, сортировка)
4. При генерации OpenXML заменяет макросы на реальные данные из ESQ

### Структура шаблона

```
Шаблон Word (.docx)
├── Простые поля: MERGEFIELD Name, MERGEFIELD Phone
├── Табличные части: строка-шаблон с MERGEFIELD Detail.Column
├── Изображения: именованные картинки (DocProperties.Name)
└── Колонтитулы: Header/Footer с макросами
```

### Серверные классы

| Класс | Файл | Назначение |
|-------|------|------------|
| `WordReportGenerator` | `WordReportGenerator.NUI.cs` | Генератор Word-отчётов (IReportGenerator "Word") |
| `OpenXmlUtility` | `ReportService.NUI.cs` | Работа с OpenXML документом |
| `WordFieldUtility` | `ReportService.NUI.cs` | Парсинг и заполнение MERGEFIELD'ов |
| `AdditionalMacrosUtility` | `ReportService.NUI.cs` | Заполнение табличных частей |
| `WordReportUtility` | `WordReportUtility.Base.cs` | Утилиты для Word-отчётов |
| `ReportHelper` | `ReportHelper.NUI.cs` | Оркестрация генерации |

### Программная генерация Word-отчёта

```csharp
// Способ 1: через IReportGenerator
var generator = ClassFactory.Get<IReportGenerator>("Word");
var config = new ReportGeneratorConfiguration {
    RecordId = recordId,
    ReportTemplateId = sysModuleReportId
};
ReportData report = generator.Generate(userConnection, config);
// report.Data — byte[] с .docx
// report.Caption — название отчёта

// Способ 2: через WordReportUtility
var utility = new WordReportUtility(userConnection);
Guid fileId = utility.GenerateReport(templateId, recordId);
// fileId — Id записи в Report с результатом

// Способ 3: через IReportEngine (новый API)
var engine = ClassFactory.Get<IReportEngine>();
var settings = new ReportSettings { Id = templateId };
var results = engine.Generate(settings);
```

### Поддержка форматирования в MERGEFIELD

| Формат | Результат |
|--------|----------|
| `\* Upper` | ЗАГЛАВНЫЕ |
| `\* Lower` | строчные |
| `\* FirstCap` | Первая заглавная |
| `\* Caps` | Каждое Слово С Заглавной |

### Системные настройки для Word-отчётов

| Настройка | Описание |
|-----------|----------|
| `IgnorePictureAspectRatio` | Не пересчитывать пропорции изображений |
| `DisableFillingTableFieldsOutsideTables` | Не заполнять табличные макросы вне таблиц |
| `ReportDecimalSeparator` | Разделитель дробной части |
| `MoneyFieldDisplayPrecision` | Точность денежных полей (по умолчанию 2) |
| `Use7xFiltersForWordReports` | Использовать новый формат фильтров |

---

## FastReport — подробно

### Архитектура FastReport

```
FastReportTemplate (сущность)
    │ хранит XML (.frx)
    ▼
FastReportTemplateProvider → загрузка шаблона
    │
    ▼
FastReportDataSourceBuilderResolver → определение типа источника
    ├── EsqDataSourceBuilder → данные из ESQ
    └── CustomDataSourceBuilder → пользовательский провайдер
    │
    ▼
ReportGenerator → генерация PDF
```

### Источники данных FastReport

| Тип | Builder | Провайдер | Описание |
|-----|---------|-----------|----------|
| ESQ | `EsqDataSourceBuilder` | `EsqDataProvider` | Данные из EntitySchemaQuery |
| Custom | `CustomDataSourceBuilder` | `IFastReportDataSourceDataProvider` | Пользовательский код |

### Пользовательский провайдер данных

```csharp
public class MyReportDataProvider : IFastReportDataSourceDataProvider
{
    public IEnumerable<IReadOnlyDictionary<string, object>> GetData(
        UserConnection userConnection,
        IReadOnlyDictionary<string, object> parameters)
    {
        // Формируем данные для отчёта
        var result = new List<Dictionary<string, object>>();
        // ...
        return result;
    }
}
```

**Пример из базового решения:** `ContactAnniversariesReportDataProvider.FastReport.cs`

### Загрузка/выгрузка шаблона .frx

```csharp
// Скачать шаблон
var templateProvider = new FastReportTemplateProvider(userConnection);
string frxTemplate = templateProvider.Get(templateId).Result;

// Сохранить шаблон
var entitySchema = userConnection.EntitySchemaManager.GetInstanceByName("FastReportTemplate");
var entity = entitySchema.CreateEntity(userConnection);
entity.FetchFromDB(templateId);
entity.SetColumnValue("Data", frxTemplate);
entity.Save();
```

---

## Клиентская часть (JavaScript)

### ReportUtilities — генерация из секции/карточки

**Файл:** `ReportUtilities.NUI.js`

```javascript
// Получить список отчётов для сущности
ReportUtilities.getReports({
    entitySchemaUId: "25d7c1ab-...",
    callback: function(reports) {
        // reports — коллекция SysModuleReport
    },
    scope: this
});

// Генерация отчёта (вызов ReportService.CreateReport)
ReportUtilities.generateReport({
    entitySchemaUId: entitySchemaUId,
    reportSchemaUId: reportId,
    templateId: templateId,
    recordId: activeRowId,
    format: "ms word",
    callback: function(key) {
        // Скачивание: /rest/ReportService/GetReportFile/{key}
        ReportUtilities.downloadReport(reportCaption, key);
    }
});
```

### PrintReportUtilities — печатные формы в карточках

**Файл:** `PrintReportUtilities.NUI.js`

Миксин для BasePageV2 / BaseSectionV2 — добавляет меню печатных форм:

```javascript
// В атрибутах страницы
mixins: {
    PrintReportUtilities: "BPMSoft.PrintReportUtilities"
},

// Инициализация — заполняет CardPrintMenuItems / SectionPrintMenuItems
this.initCardPrintForms();

// Типы: DevExpress (DevExpress), MS Word (ms word)
```

### FastReportService (JS) — генерация FastReport

**Файл:** `FastReportService.FastReport.js`

```javascript
var fastReportService = Ext.create("BPMSoft.FastReportService");
fastReportService.generateReport({
    reportTemplateId: templateId,
    reportCaption: "Отчёт по контактам",
    reportSchemaName: "Contact",
    reportFilters: serializedFilters
}, function(key) {
    // Скачивание: /rest/FastReportService/GetReportFile/{key}
    window.open("/0/rest/FastReportService/GetReportFile/" + key);
}, this);
```

### BaseDataView.FastReport.js — миксин для секций

Добавляет кнопки FastReport в секцию:

```javascript
// Генерация для выбранной записи
generatePrintForm: function(reportId) { ... }

// Генерация с фильтром страницы фильтров
_generateReportUsingReportFilterPage: function(config) { ... }

// Генерация по текущим фильтрам секции
_generateReportUsingSectionFilters: function(config) { ... }
```

### BaseReportFilterPage — страница фильтров FastReport

**Файл:** `BaseReportFilterPage.FastReport.js`

Модальная страница выбора записей для отчёта:

- **FormBySelected** — по выбранным записям
- **FormByFiltered** — по текущим фильтрам
- **FormByAll** — по всем записям

### ReportEngineClient — новый клиент

**Файл:** `ReportEngineClient.Reports.js`

```javascript
var client = Ext.create("BPMSoft.ReportEngineClient");
client.getReportTemplates(function(templates) {
    // templates — список IReportTemplateInfo
    // template.Type: MsWord (1), FastReport (2)
}, this);
```

### AsyncReportNotifier — асинхронная генерация

**Файл:** `AsyncReportNotifier.Reports.js`

Для больших отчётов — асинхронная генерация через серверную очередь с уведомлением через WebSocket (ServerChannel):

```javascript
// Подписка на уведомление о завершении
BPMSoft.ServerChannel.on("ReportGenerationCompleted", function(data) {
    if (data.success) {
        // Скачивание готового отчёта
        window.open(data.downloadUrl);
    }
});
```

---

## Word Reporting — дизайнер печатных форм

### JS-модули дизайнера

| Файл | Назначение |
|------|------------|
| `WordPrintablePage.WordReporting.js` | Страница настройки печатной формы |
| `WordPrintableTablePartPage.WordReporting.js` | Настройка табличных частей |
| `WordPrintablePageLoader.WordReporting.js` | Загрузчик страницы |
| `WordPrintableConverter.WordReporting.js` | Конвертация настроек |
| `FilterConverterConnector.WordReporting.js` | Конвертация фильтров |

### Серверная часть дизайнера

| Файл | Назначение |
|------|------------|
| `WordReportingDesignService.WordReporting.cs` | WCF-сервис дизайнера |
| `WordReportingDesignWorker.WordReporting.cs` | Логика сохранения/загрузки шаблонов |
| `EntityFilterConverterService.WordReporting.cs` | Конвертация фильтров |
| `SysReportTemplate` | Хранение шаблонов Word Reporting |

---

## Программный запуск отчёта с сервера

### Способ 1: IReportEngine (рекомендуемый)

```csharp
var reportEngine = ClassFactory.Get<IReportEngine>();
var settings = new ReportSettings {
    Id = reportTemplateId,
    Filters = new Filters {
        FilterType = FilterType.FilterGroup,
        Items = new Dictionary<string, Filter> {
            ["PrimaryFilter"] = new Filter {
                FilterType = FilterType.CompareFilter,
                ComparisonType = FilterComparisonType.Equal,
                LeftExpression = new BaseExpression {
                    ExpressionType = EntitySchemaQueryExpressionType.SchemaColumn,
                    ColumnPath = "Id"
                },
                RightExpression = new BaseExpression {
                    ExpressionType = EntitySchemaQueryExpressionType.Parameter,
                    Parameter = new Parameter {
                        DataValueType = DataValueType.Guid,
                        Value = recordId.ToString()
                    }
                }
            }
        }
    }
};
var results = reportEngine.Generate(settings);
byte[] reportBytes = results.First().Data;
```

### Способ 2: Прямой вызов IReportGenerator

```csharp
// Word
var generator = ClassFactory.Get<IReportGenerator>("Word");
var config = new ReportGeneratorConfiguration {
    RecordId = recordId,
    ReportTemplateId = templateId
};
ReportData data = generator.Generate(userConnection, config);

// DevExpress
var generator = ClassFactory.Get<IReportGenerator>("DevExpress");
var config = new ReportGeneratorConfiguration {
    ReportTemplateId = reportSchemaId,
    EntitySchemaUId = entitySchemaUId,
    RecordId = recordId,
    ReportParameters = new Dictionary<string, object> { ... }
};
ReportData data = generator.Generate(userConnection, config);
```

### Способ 3: FastReport программно

```csharp
var templateProvider = new FastReportTemplateProvider(userConnection);
var dataSourceResolver = new FastReportDataSourceBuilderResolver(userConnection);
var generator = new ReportGenerator(templateProvider, dataSourceResolver);

var parameters = new Dictionary<string, object> {
    ["EsqFilters"] = new Dictionary<string, Filters> {
        ["Contact"] = contactFilters
    }
};

byte[] pdfBytes = generator.Generate(templateId, parameters, ReportFormat.Pdf).Result;
```

---

## Программный запуск отчёта с клиента (JS)

### Вызов MS Word отчёта

```javascript
require(["ReportUtilities"], function(ReportUtilities) {
    var serviceUrl = BPMSoft.workspaceBaseUrl + "/rest/ReportService/CreateReport";
    BPMSoft.AjaxProvider.request({
        url: serviceUrl,
        jsonData: {
            entitySchemaUId: "25d7c1ab-1de0-4501-b402-02e0e5a72d6e",
            reportSchemaUId: "",
            templateId: templateId,
            recordId: recordId,
            reportParameters: "{}",
            format: "ms word"
        },
        callback: function(request, success, response) {
            var key = BPMSoft.decode(response.responseText);
            window.open(BPMSoft.workspaceBaseUrl
                + "/rest/ReportService/GetReportFile/" + key);
        }
    });
});
```

### Вызов FastReport

```javascript
require(["FastReportService"], function() {
    var service = Ext.create("BPMSoft.FastReportService");
    service.generateReport({
        reportTemplateId: templateId,
        reportCaption: "Мой FastReport",
        reportSchemaName: "Contact",
        reportFilters: BPMSoft.encode(filtersConfig)
    }, function(sessionKey) {
        window.open(BPMSoft.workspaceBaseUrl
            + "/rest/FastReportService/GetReportFile/" + sessionKey);
    }, this);
});
```

### Вызов через PrintReportUtilities (из карточки)

```javascript
// В methods страницы карточки:
generateReport: function(reportConfig) {
    var reportUtilities = this.Ext.create("BPMSoft.ReportUtilities");
    reportUtilities.generateReport({
        entitySchemaUId: this.entitySchema.uId,
        reportSchemaUId: reportConfig.reportSchemaUId,
        templateId: reportConfig.templateId,
        recordId: this.get("Id"),
        format: reportConfig.format || "ms word"
    });
}
```

---

## Таблица файлов по темам

### Серверная часть

| Файл | Пакет | Назначение |
|------|-------|------------|
| `IReportEngine.Base.cs` | Base | Интерфейс IReportEngine, ReportType, ReportSettings |
| `ReportEngine.Reports.cs` | Reports | Реализация IReportEngine |
| `ReportEngineService.Reports.cs` | Reports | WCF-сервис для IReportEngine |
| `ReportService.NUI.cs` | NUI | WCF ReportService (Word, DevExpress, Excel) |
| `ReportHelper.NUI.cs` | NUI | Оркестрация генерации |
| `WordReportGenerator.NUI.cs` | NUI | IReportGenerator "Word" |
| `IReportGenerator.NUI.cs` | NUI | Интерфейс IReportGenerator |
| `ReportGeneratorConfiguration.NUI.cs` | NUI | Конфигурация генерации |
| `FastReportService.FastReportEngine.cs` | FastReportEngine | WCF FastReportService |
| `FastReportTemplateProvider.FastReportEngine.cs` | FastReportEngine | Загрузка .frx шаблонов |
| `FastReportDataSourceBuilderResolver.FastReportEngine.cs` | FastReportEngine | Резолвер источников данных |
| `EsqDataSourceBuilder.FastReportEngine.cs` | FastReportEngine | ESQ-источник для FastReport |
| `CustomDataSourceBuilder.FastReportEngine.cs` | FastReportEngine | Кастомный источник |
| `FastReportAppEventListener.FastReportEngine.cs` | FastReportEngine | Инициализация при старте |
| `WordReportUtility.Base.cs` | Base | Утилиты Word-отчётов |
| `IAsyncReportGenerator.Reports.cs` | Reports | Асинхронная генерация |
| `PdfAsyncReportGenerator.Reports.cs` | Reports | Асинхронная генерация PDF |
| `AsyncReportGenerationService.Reports.cs` | Reports | Сервис асинхронной генерации |

### Клиентская часть

| Файл | Пакет | Назначение |
|------|-------|------------|
| `ReportUtilities.NUI.js` | NUI | Генерация Word/DevExpress отчётов |
| `PrintReportUtilities.NUI.js` | NUI | Миксин печатных форм для страниц |
| `PrintableProcessModule.NUI.js` | NUI | Печать из процессов |
| `FastReportService.FastReport.js` | FastReport | Клиент FastReportService |
| `BaseReportFilterPage.FastReport.js` | FastReport | Страница фильтров FastReport |
| `SimpleReportFilterPage.FastReport.js` | FastReport | Простая страница фильтров |
| `BaseDataView.FastReport.js` | FastReport | Миксин для секций (кнопки FastReport) |
| `BasePageV2.FastReport.js` | FastReport | Миксин для карточек (FastReport) |
| `ReportEngineClient.Reports.js` | Reports | Клиент IReportEngine |
| `AsyncReportNotifier.Reports.js` | Reports | Уведомления об асинхронной генерации |
| `ReportStorage.Reports.js` | Reports | Хранение ID таймаутов |
| `WordPrintablePage.WordReporting.js` | WordReporting | Дизайнер Word-печатных форм |
| `WordPrintableTablePartPage.WordReporting.js` | WordReporting | Настройка табличных частей |

---

## Типовые сценарии

### 1. Генерация Word-отчёта по записи

```csharp
var generator = ClassFactory.Get<IReportGenerator>("Word");
var config = new ReportGeneratorConfiguration {
    RecordId = contactId,
    ReportTemplateId = sysModuleReportId
};
ReportData report = generator.Generate(userConnection, config);
byte[] docxBytes = report.Data;
string caption = report.Caption;
```

### 2. Генерация FastReport PDF

```csharp
var templateProvider = new FastReportTemplateProvider(userConnection);
var dataSourceResolver = new FastReportDataSourceBuilderResolver(userConnection);
var generator = new ReportGenerator(templateProvider, dataSourceResolver);

var parameters = new Dictionary<string, object> {
    ["EsqFilters"] = new Dictionary<string, Filters> {
        ["Contact"] = contactFilters
    }
};

byte[] pdfBytes = generator.Generate(templateId, parameters, ReportFormat.Pdf).Result;
```

### 3. Вызов отчёта с клиента (JavaScript)

```javascript
require(["ReportUtilities"], function(ReportUtilities) {
    BPMSoft.AjaxProvider.request({
        url: BPMSoft.workspaceBaseUrl + "/rest/ReportService/CreateReport",
        jsonData: {
            entitySchemaUId: entitySchemaUId,
            reportSchemaUId: "",
            templateId: templateId,
            recordId: activeRowId,
            reportParameters: "{}",
            format: "ms word"
        },
        callback: function(request, success, response) {
            var key = BPMSoft.decode(response.responseText);
            window.open(BPMSoft.workspaceBaseUrl
                + "/rest/ReportService/GetReportFile/" + key);
        }
    });
});
```

### 4. Создание пользовательского провайдера данных для FastReport

```csharp
public class SalesReportDataProvider : IFastReportDataSourceDataProvider
{
    public IEnumerable<IReadOnlyDictionary<string, object>> GetData(
        UserConnection userConnection,
        IReadOnlyDictionary<string, object> parameters)
    {
        var esq = new EntitySchemaQuery(userConnection.EntitySchemaManager, "Order");
        esq.AddColumn("Number");
        esq.AddColumn("Amount");
        esq.AddColumn("Contact.Name");
        if (parameters.TryGetValue("EsqFilters", out var filtersObj)) {
            // применить фильтры
        }
        var collection = esq.GetEntityCollection(userConnection);
        return collection.Select(e => new Dictionary<string, object> {
            ["Number"] = e.GetTypedColumnValue<string>("Number"),
            ["Amount"] = e.GetTypedColumnValue<decimal>("Amount"),
            ["ContactName"] = e.GetTypedColumnValue<string>("Contact_Name")
        });
    }
}
```

---

## Антипаттерны

| ❌ Неправильно | ✅ Правильно |
|---------------|-------------|
| Генерация отчёта синхронно для большого объёма данных — timeout и блокировка потока | Использовать `AsyncReportGenerationService` / `AsyncReportNotifier` для тяжёлых отчётов |
| Хранение шаблона Word/FRX в коде или файловой системе | Хранить в `SysModuleReport` (Word) / `FastReportTemplate` (FastReport) — централизованное управление |
| Игнорирование параметра `format` (передача "ms word" вместо "pdf" или наоборот) | Явно указывать нужный формат; проверять `SysAllowedReportFormat` для доступных форматов |

---

## Troubleshooting

| Ошибка / Симптом | Причина | Решение |
|-----------------|---------|---------|
| Пустой Word-отчёт | MERGEFIELD-макросы в шаблоне не совпадают с колонками, или фильтр не возвращает данных | Проверить имена макросов в `.docx`, проверить фильтры в `SysModuleReportTable` |
| FastReport ошибка генерации | Ошибка в `.frx` шаблоне или несовпадение DataSource | Скачать шаблон через `DownloadReportTemplate`, открыть в FastReport Designer, проверить привязки данных |
| Ошибка PDF-конвертации | Не установлен или не зарегистрирован `PdfConverter` | Проверить наличие библиотеки конвертации; для Word-отчётов проверить `LibreOffice`/`Aspose` |
| Отчёт генерируется слишком долго | Большой объём данных или неоптимальные фильтры | Оптимизировать ESQ-фильтры, использовать асинхронную генерацию через `AsyncReportGenerationService` |

**Советы по отладке:**
- Word-шаблон: открыть в Word, включить отображение кодов полей (Alt+F9) для проверки MERGEFIELD
- FastReport: использовать FastReport Designer для визуальной отладки шаблонов
- Логи: проверить серверный лог на ошибки `ReportService` / `FastReportService`

---

## Связанные темы

- [WCF-сервисы](services.md)
- [Утилиты (клиент)](../client/utilities.md)
- [Схемы сущностей](entity-schemas.md)
