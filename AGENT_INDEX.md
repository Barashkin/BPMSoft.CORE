# AGENT_INDEX — карта документации для агента

**Назначение:** быстрый выбор файла документации. Все пути относительно `Base/docs/`. Для деталей открывай указанный файл.

---

## Документы (путь | описание | теги)

| Путь | Описание | Теги |
|------|----------|------|
| INDEX.md | Оглавление, Getting Started, задача→файл, точки входа | index, onboarding, навигация |
| extended/INDEX.md | Оглавление расширенного руководства: задачи, календарь, файлы, Quartz, email | расширенное, примеры |
| extended/activities-tasks.md | Задачи: создание, статус, назначение, закрытие (ActivityConsts, ActivityUserTask) | задачи, Activity, статус |
| extended/calendar.md | Календарь: рабочие дни, AddWorkingDays, GetBusinessTime, CalendarServiceUtils | календарь, рабочие дни |
| extended/files.md | Файлы: FileRepository, IFile, загрузка, удаление | файлы, FileRepository |
| extended/quartz.md | Quartz: ProcessJob, ClassJob, активация/деактивация, RescheduleJob | Quartz, планировщик |
| extended/email.md | Email: IEmailSender, создание активности-письма | email, IEmailSender |
| architecture/platform-overview.md | Архитектура: сервер/клиент, пакеты, UserConnection, жизненный цикл запроса, точки расширения | архитектура, UserConnection, пакеты |
| architecture/naming-conventions.md | Именование файлов/классов, замещение (override), суффиксы пакетов | именование, конвенции, override |
| server/entity-schemas.md | Схемы сущностей: BaseEntity, BaseLookup, колонки, ESQ, Entity API | сущности, ESQ, колонки, наследование |
| server/event-listeners.md | Entity/App EventListener, OnSaving/OnSaved, EventsProcess | EventListener, события, CRUD |
| server/services.md | WCF-сервисы: ServiceContract, WebInvoke, REST, проверка прав | WCF, REST, сервисы |
| server/processes.md | Бизнес-процессы: AddData, ReadData, ChangeData, ScriptTask | процессы, UserTask, BPM |
| server/activity-email.md | Activity, Email: участники, статусы, EmailParticipantHelper, печать | активность, email |
| server/scheduler-quartz.md | Quartz: AppScheduler, IJobExecutor, cron, фоновые задачи | планировщик, Quartz, cron |
| server/reports.md | Отчёты: Word, FastReport, IReportEngine, печатные формы | отчёты, Word, FastReport, PDF |
| server/file-storage.md | Файлы: FileRepository, IFile, загрузка, версионность, привязка к сущности | файлы, загрузка, хранилище |
| client/modules.md | AMD-модули: define, attributes, messages, sandbox, diff, жизненный цикл | AMD, модули, diff, sandbox |
| client/pages-sections-details.md | BasePageV2, BaseSectionV2, BaseDetailV2, MiniPage | страница, секция, деталь |
| client/mixins.md | Миксины: определение, подключение, ключевые миксины | миксины, переиспользование |
| client/utilities.md | ServiceHelper, RightUtilities, ConfigurationEnums, ProcessModuleUtilities | ServiceHelper, права, вызов сервиса |
| reference/entity-catalog.md | Каталог 715 схем сущностей (списки по категориям) | каталог, сущности |
| reference/base-classes.md | Иерархии: EntitySchema, Entity, EventListener, сервисы, клиентские классы | иерархия, базовые классы |
| reference/enums-constants.md | DataValueType, ConfigurationEnums, ConfigurationConstants, права | перечисления, константы, GUID |

---

## Задача → файл (кратко)

создать сущность, колонка, ESQ → server/entity-schemas.md  
событие сохранения, EventListener, OnSaving → server/event-listeners.md  
REST-сервис, WCF, вызов с клиента → server/services.md  
страница карточки, деталь, BasePageV2 → client/pages-sections-details.md  
ServiceHelper, права (клиент) → client/utilities.md  
бизнес-процесс, UserTask, ScriptTask → server/processes.md  
отчёт, печатная форма, Word, FastReport → server/reports.md  
файлы, загрузка, FileRepository → server/file-storage.md  
планировщик, Quartz, фоновая задача → server/scheduler-quartz.md  
активность, email, участники → server/activity-email.md  
AMD, модуль, diff, sandbox → client/modules.md  
миксин → client/mixins.md  
именование, конвенции, override → architecture/naming-conventions.md  
архитектура, UserConnection, пакеты → architecture/platform-overview.md  
каталог схем, 715 сущностей → reference/entity-catalog.md  
иерархия классов → reference/base-classes.md  
перечисления, константы, DataValueType → reference/enums-constants.md  
задачи по типам, создание/закрытие активности, статус → extended/activities-tasks.md  
календарь, рабочие дни, AddWorkingDays → extended/calendar.md  
Quartz типы заданий, активация/деактивация, RescheduleJob → extended/quartz.md  
отправка email, IEmailSender → extended/email.md  
файлы FileRepository, IFile → extended/files.md  
расширенное руководство (оглавление) → extended/INDEX.md  

---

## Класс/компонент → файл

BaseEntitySchema, BaseLookupSchema, Entity, ESQ → server/entity-schemas.md  
BaseEntityEventListener, EventsProcess → server/event-listeners.md  
BasePageV2, BaseSectionV2, BaseDetailV2 → client/pages-sections-details.md  
ServiceHelper, RightUtilities → client/utilities.md  
AppScheduler, IJobExecutor → server/scheduler-quartz.md  
IReportEngine, ReportService → server/reports.md  
FileRepository, IFile → server/file-storage.md  
Activity, EmailParticipantHelper → server/activity-email.md  
ProcessUserTask, AddDataUserTask → server/processes.md  
ConfigurationEnums, ConfigurationConstants → reference/enums-constants.md  
CalendarServiceUtils, AddBusinessDays, CalendarUtility → extended/calendar.md  
EmailSender, IEmailSender → extended/email.md  
