# Работа с календарём

<!-- Версия: 1.0 | Обновлено: 2026-03-19 | Платформа: BPMSoft 1.9 -->
<!-- Теги: календарь, рабочие дни, CalendarServiceUtils, AddWorkingDays, GetBusinessDays -->

Учёт рабочего времени ведётся по календарю (Calendar). Ключевые классы: `CalendarServiceUtils`, процессы `AddBusinessDays`, `GetBusinessDays`, `GetBusinessTime`, WCF `CalendarOperationService` / `CalendarUtility`.

## Проверка: рабочий или нерабочий день

Логика реализована в `CalendarServiceUtils.CalendarService.cs`: выходные определяются по календарю (DayOfWeek + DayOff), для конкретной даты используется внутренний метод `IsDayOff(DateTime date)`.

**Использование CalendarServiceUtils:**

```csharp
// CalendarServiceUtils — конструктор принимает UserConnection
var calendarUtils = new CalendarServiceUtils(UserConnection);

// Добавление рабочих дней: возвращает дату через numberOfDays рабочих дней
DateTime endDate = calendarUtils.AddWorkingDays(startDate, numberOfDays, calendarId);

// Количество рабочих дней в интервале
int workingDays = calendarUtils.GetWorkingDays(startDate, endDate, calendarId);

// Количество рабочих минут в интервале
int workingMinutes = calendarUtils.GetWorkingMinutes(startDate, endDate, calendarId);
```

Проверка «рабочий/нерабочий» внутри `AddWorkingDays` и `GetWorkingDays` основана на:
- выходных днях недели календаря (`GetWeekends()` — DayOfWeek + DayInCalendar + DayType.IsWeekend);
- праздничных и сокращённых днях (`GetDaysOff()` — сущность DayOff по CalendarId).

Прямого публичного метода «IsWorkingDay(DateTime)» в API нет — он используется внутри (private `IsDayOff`, логика в `GetWorkingDays` через `IsWorkingDay(timeIntervals, day)`). Для проверки одной даты можно:
- вычислить `GetWorkingDays(date, date, calendarId)` — вернёт 1, если день рабочий, 0 если выходной;
- либо использовать `CalendarUtility` (см. ниже), если доступен.

## Получение даты от указанной с добавлением рабочих дней

**Серверный код (рекомендуемый способ):**

```csharp
// AddBusinessDays.CalendarService.cs — процесс в платформе
var calendarUtils = new CalendarServiceUtils(UserConnection);
if (DateStart == null || NumberDays <= 0 || CalendarId == Guid.Empty)
    throw new ArgumentException(InvalidInputParameters);
DateEnd = calendarUtils.AddWorkingDays(DateStart, NumberDays, CalendarId);
```

**Прямой вызов без процесса:**

```csharp
var calendarUtils = new CalendarServiceUtils(UserConnection);
DateTime startDate = DateTime.Today;
int numberOfWorkingDays = 5;
Guid calendarId = ...; // Id календаря (например, календарь организации)
DateTime endDate = calendarUtils.AddWorkingDays(startDate, numberOfWorkingDays, calendarId);
```

## Добавление времени по календарю (рабочие часы/минуты)

**CalendarOperationService** (помечен Obsolete, но доступен): добавление единиц времени к дате с учётом рабочих интервалов календаря.

```csharp
// CalendarOperationService.Calendar.cs
// Add(calendarId, date, timeUnit, value) — возвращает новую дату
var utility = new CalendarUtility(calendarId, UserConnection);
DateTime newDate = utility.Add(date, TimeUnit.Hour, 8);
```

**GetBusinessTime** (процесс): возвращает количество рабочих минут и часов между двумя датами.

```csharp
// GetBusinessTime.CalendarService.cs
NumberMinutes = calendarUtils.GetWorkingMinutes(DateStart, DateEnd, CalendarId);
NumberHours = (decimal)TimeSpan.FromMinutes(NumberMinutes).TotalHours;
```

## Примеры из платформы

| Сценарий | Файл |
|----------|------|
| Добавление N рабочих дней к дате | `AddBusinessDays.CalendarService.cs` — InternalExecute |
| Подсчёт рабочих дней в интервале | `GetBusinessDays.CalendarService.cs` — InternalExecute |
| Подсчёт рабочих минут/часов | `GetBusinessTime.CalendarService.cs` — InternalExecute |
| Реализация AddWorkingDays, GetWorkingDays, GetWorkingMinutes, IsDayOff | `CalendarServiceUtils.CalendarService.cs` |
| Добавление единиц времени по календарю (WCF) | `CalendarOperationService.Calendar.cs` — Add; `CalendarUtility.Calendar.cs` |

---

**Связанные документы:** [Расширенное руководство — оглавление](INDEX.md)
