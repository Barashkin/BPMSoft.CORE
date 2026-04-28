# Mobile Services And Push

<!-- Версия: 1.1 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: MobileServiceHelper, push, local notification, service calls, Reminding -->

> Вызовы серверных сервисов из мобильного клиента, push receiver и локальные
> напоминания.

## MobileServiceHelper

`MobileServiceHelper.Mobile.js` определяет `BPMSoft.ServiceHelper`.

URL строится как:

```javascript
"rest/" + serviceName + "/" + methodName
```

`issueRequest`:

- использует `POST`;
- кладёт body в `jsonData`;
- задаёт timeout `BPMSoft.core.enums.WebRequestTimeout.Ajax`;
- отправляет запрос через `BPMSoft.RequestManager`;
- success возвращает decoded JSON;
- failure разбирает через `BPMSoft.ServiceResponseParser`.

## Push receiver

`MobilePushNotificationReceiver.Mobile.js` наследуется от
`BPMSoft.nativeApi.BasePushNotificationReceiver` и регистрируется как default
receiver.

Основной flow при tap:

1. Записать analytics event.
2. Если это visa и включён `UseMobileFlutterApprovals`, открыть Flutter screen.
3. Проверить `entityName` и `recordId`.
4. Проверить, доступен ли module в application config.
5. Проверить существование записи.
6. При необходимости синхронизировать модель в cache.
7. Открыть Flutter edit page или legacy preview page.

## Cache sync from push

Перед открытием записи receiver вызывает `synchronizeToCacheIfNeeded(modelName)`.
Если включён `ModelCache` и manager является `SynchronizableCacheManager`,
запускается `synchronizeToCache`.

## Local notifications

`MobileLocalNotificationManager.Mobile.js` работает с `VwRemindings` и Activity.

Он:

- загружает reminders для current user contact;
- фильтрует по `SysEntitySchemaId = Activity`;
- создаёт local notification;
- при клике открывает Activity preview page;
- при clear удаляет reminder record.

## Push storage on server

Серверные схемы:

- `PushNotificationServiceSchema.NUI.cs`;
- `PushNotificationTokenSchema.NUI.cs`.
- `PushNotificationHistorySchema.NUI.cs`.

Они относятся к настройке provider, хранению device tokens и защите от
повторной отправки push.

## Связь с notification center

NUI notification pipeline может отправлять push через
`PushNotificationSender.NUI.cs`, если включены features:

- `UseMobilePushNotifications`;
- `SendPushByNotifications`.

При отправке reminder push получает `entityName`, `recordId`, `messageId` и
`remindTime`. Mobile receiver затем открывает связанную запись.

## Практические правила

- В mobile service calls используйте `BPMSoft.ServiceHelper.issueRequest`.
- На failure отдавайте пользователю parsed exception, а не raw response.
- Push должен проверять наличие module и записи до открытия страницы.
- Перед открытием записи из push синхронизируйте cache, если он включён.
- Local notifications должны удалять обработанные reminders.

## Связанные документы

- [Mobile overview](mobile-overview.md)
- [Mobile offline cache](mobile-offline-cache.md)
- [Services Overview](services-overview.md)
- [Activity Email Overview](activity-overview.md)
- [Notifications Reminders Overview](notifications-reminders-overview.md)
