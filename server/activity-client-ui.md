# Activity Client UI

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: EmailPageV2, ActivityPageV2, ShowInScheduler, IsHtmlBody, scheduler -->

> Клиентские страницы активностей и email: действия, отправка, HTML body, календарь и детали.

## EmailPageV2

`EmailPageV2` — карточка email activity. Она наследует activity behavior и подключает email-specific mixins:

- `EmailActionsMixin`;
- `ActivityDatesMixin`;
- `EmailImageMixin`;
- `EmailRelationsMixin`;
- `ExtendedHtmlEditModuleUtilities`.

## Key attributes

| Attribute | Назначение |
| --------- | ---------- |
| `IsSendButtonVisible` | видимость кнопки отправки |
| `IsReplyButtonVisible` | reply action |
| `IsForwardButtonVisible` | forward action |
| `Sender`, `SenderEnum`, `SenderEnumList` | выбор отправителя |
| `MailboxSyncSettingsCollection` | доступные ящики |
| `Recepient` | получатели |
| `ActivityCategory` | категория по типу |
| `StartDate`, `DueDate` | даты активности |

## Send/reply/forward actions

Видимость действий зависит от `Type`, `MessageType`, `EmailSendStatus` и состояния карточки. Не проверяйте только кнопку: сервер всё равно должен валидировать отправку.

## IsHtmlBody

Email UI различает HTML и plain text body. `IsHtmlBody` влияет на редактор, preview и rendering в timeline/message views.

Если текст отображается как HTML или наоборот, проверяйте `IsHtmlBody`, body content и соответствующий view.

## Scheduler

Для задач и встреч важны:

- `ShowInScheduler`;
- `StartDate`;
- `DueDate`;
- `TimeZone`;
- participant responses.

`ActivitySectionSchedulerViewModel` и страницы активности отвечают за календарный UX.

## Email files

Карточка email использует `EmailFileDetailV2`, где отключена возможность добавить link вместо файла.

## Практические правила

- Для email actions используйте existing mixins, а не прямые service calls из кнопки.
- Для sender list загружайте mailbox settings в view model state.
- Для HTML body проверяйте `IsHtmlBody` на server и client.
- Для календаря не скрывайте `ShowInScheduler` без понимания sync side effects.
- Для вложений email используйте `EmailFileDetailV2`.

## Связанные документы

- [Activity Email Overview](activity-overview.md)
- [Activity mailbox sync](activity-mailbox-sync.md)
- [Activity participants files](activity-participants-files.md)
- [Client page lifecycle](../client/client-page-lifecycle.md)
