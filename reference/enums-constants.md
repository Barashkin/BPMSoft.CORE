# Перечисления и константы конфигурации

<!-- Версия: 1.0 | Обновлено: 2026-03-19 | Платформа: BPMSoft 1.9 -->
<!-- Теги: перечисления, константы, DataValueType, ConfigurationEnums, ConfigurationConstants, GUID, права -->

## DataValueType — типы данных

Используются в `attributes` модулей и для описания колонок:

| Значение | Описание | C# эквивалент |
|----------|----------|---------------|
| `TEXT` | Строка | string |
| `SHORT_TEXT` | Короткая строка (до 50) | string |
| `MEDIUM_TEXT` | Средняя строка (до 250) | string |
| `LONG_TEXT` | Длинная строка (до 500) | string |
| `MAXSIZE_TEXT` | Неограниченный текст | string |
| `INTEGER` | Целое число | int |
| `FLOAT` | Дробное число | decimal |
| `MONEY` | Денежная сумма | decimal |
| `BOOLEAN` | Логическое | bool |
| `DATE_TIME` | Дата и время | DateTime |
| `DATE` | Только дата | DateTime |
| `TIME` | Только время | DateTime |
| `LOOKUP` | Справочник (FK) | Guid |
| `ENUM` | Перечисление | Guid |
| `GUID` | Уникальный идентификатор | Guid |
| `BLOB` | Бинарные данные | byte[] |
| `IMAGE` | Изображение | Guid |
| `IMAGELOOKUP` | Справочник изображений | Guid |
| `COLLECTION` | Коллекция | — |
| `CUSTOM_OBJECT` | Произвольный объект | object |
| `COLOR` | Цвет | string |
| `MAPPING` | Маппинг (процессы) | — |

## ConfigurationEnums

### CardStateV2 — состояния карточки

```javascript
{
    ADD: "add",     // создание новой записи
    EDIT: "edit",   // редактирование
    COPY: "copy"    // копирование
}
```

### GridType — типы грида

```javascript
{
    LISTED: "listed",   // табличный (колонки)
    TILED: "tiled"      // плиточный (карточки)
}
```

### WorkAreaMode — режимы рабочей области

```javascript
{
    SECTION: 0,     // только список
    CARD: 1,        // только карточка
    COMBINED: 2     // список + карточка
}
```

### EntitySchemaColumnUsageType — использование колонки

```javascript
{
    General: 0,     // основная
    Advanced: 1,    // дополнительная
    None: 2         // не используется
}
```

### MapsModuleMode — режимы карт

```javascript
{
    POINTS: "points",
    ROUTE: "route",
    ROUTE_GEOLOCATION: "routeGeolocation"
}
```

## ConfigurationConstants

### Activity — константы активностей

#### Типы активностей
| Константа | GUID | Описание |
|-----------|------|----------|
| `Type.Task` | `fbe0acdc-cfc0-df11-b00f-001d60e938c6` | Задача |
| `Type.Email` | `e2831dec-cfc0-df11-b00f-001d60e938c6` | Email |
| `Type.Call` | `e1831dec-cfc0-df11-b00f-001d60e938c6` | Звонок |

#### Статусы активностей
| Константа | GUID | Описание |
|-----------|------|----------|
| `Status.NotStarted` | `384d4b84-58e6-df11-971b-001d60e938c6` | Не начата |
| `Status.InProgress` | `394d4b84-58e6-df11-971b-001d60e938c6` | В работе |
| `Status.Done` | `4bdbb88f-58e6-df11-971b-001d60e938c6` | Завершена |
| `Status.Cancelled` | `201cfba8-58e6-df11-971b-001d60e938c6` | Отменена |

#### Категории активностей
| Константа | Описание |
|-----------|----------|
| `ActivityCategory.DoNot` | Не выполнять |

#### Роли участников
| Константа | Описание |
|-----------|----------|
| `ParticipantRole.Responsible` | Ответственный |
| `ParticipantRole.Participant` | Участник |

### CommunicationType — типы коммуникаций

| Константа | GUID | Описание |
|-----------|------|----------|
| `Phone` | `6a3fb10c-67cc-df11-9b2a-001d60e938c6` | Телефон |
| `MobilePhone` | `d4a2dc80-30ca-df11-9b2a-001d60e938c6` | Мобильный |
| `Email` | `ee1c85c3-cfcb-df11-9b2a-001d60e938c6` | Email |
| `Skype` | — | Skype |
| `Facebook` | — | Facebook |
| `LinkedIn` | — | LinkedIn |
| `Twitter` | — | Twitter |
| `Web` | — | Веб-сайт |
| `Fax` | — | Факс |

### AddressType — типы адресов

| Константа | Описание |
|-----------|----------|
| `Home` | Домашний |
| `Legal` | Юридический |
| `Actual` | Фактический |
| `Delivery` | Адрес доставки |

## ViewItemType — типы UI-элементов

| Тип | Описание |
|-----|----------|
| `BUTTON` | Кнопка |
| `LABEL` | Текстовая метка |
| `CONTAINER` | Контейнер |
| `GRID_LAYOUT` | Сетка (строки × колонки) |
| `MODEL_ITEM` | Поле модели (авто-виджет) |
| `MODULE` | Встроенный модуль |
| `DETAIL` | Деталь |
| `TAB_PANEL` | Панель вкладок |
| `COLOR_BUTTON` | Кнопка цвета |
| `RADIO_GROUP` | Группа радиокнопок |
| `DESIGN_ITEM` | Элемент дизайнера |
| `HYPERLINK` | Гиперссылка |
| `INFORMATION_BUTTON` | Информационная кнопка (i) |
| `TIP` | Подсказка |
| `COMPONENT` | Компонент |
| `MENU_SEPARATOR` | Разделитель меню |

## ContentType — типы контента полей

| Тип | Описание |
|-----|----------|
| `ENUM` | Выпадающий список |
| `LOOKUP` | Справочник |
| `SHORT_TEXT` | Короткое текстовое поле |
| `LONG_TEXT` | Многострочное поле |
| `RICH_TEXT` | Richtext-редактор |
| `SEARCHABLE_TEXT` | Поле с поиском |

## MessageMode — режимы сообщений sandbox

| Режим | Описание |
|-------|----------|
| `PTP` | Point-to-Point — один получатель |
| `BROADCAST` | Рассылка — все подписчики |

## MessageDirectionType — направления сообщений

| Направление | Описание |
|-------------|----------|
| `PUBLISH` | Модуль отправляет сообщение |
| `SUBSCRIBE` | Модуль принимает сообщение |
| `BIDIRECTIONAL` | Модуль и отправляет, и принимает |

## SchemaOperationRightLevels — права на схему

| Уровень | Значение | Описание |
|---------|----------|----------|
| `None` | 0 | Нет прав |
| `CanRead` | 1 | Чтение |
| `CanAppend` | 2 | Добавление |
| `CanEdit` | 4 | Редактирование |
| `CanDelete` | 8 | Удаление |

Используются как битовые флаги: `CanRead | CanEdit = 5`.

## RecordOperationRightLevels — права на запись

| Уровень | Значение | Описание |
|---------|----------|----------|
| `None` | 0 | Нет прав |
| `CanRead` | 1 | Чтение |
| `CanEdit` | 2 | Редактирование |
| `CanDelete` | 4 | Удаление |

---

## Связанные темы

- [Схемы сущностей](../server/entity-schemas.md)
- [AMD-модули](../client/modules.md)
- [Утилиты](../client/utilities.md)
- [Базовые классы](base-classes.md)
