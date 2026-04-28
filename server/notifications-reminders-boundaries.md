# Notifications Reminders Boundaries

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: Notifications, Reminding, ESN, Mobile, Activity, boundaries -->

> В платформе несколько подсистем используют слово notification. Этот документ
> отделяет NUI `Reminding` pipeline от ESN, Mobile, Activity и email.

## NUI Reminding center

Основной объект этого dive:

- entity: `Reminding`;
- job: `RemindingJob`;
- sender: `NotificationSender`;
- delivery: websocket/push handlers;
- UI: `BaseNotificationsSchema`, `RemindingsModule`, `CenterNotificationModule`.

Используйте эти документы, если проблема звучит как:

- reminder не появился в центре;
- счетчик reminder не обновился;
- popup/websocket не пришел;
- push по reminder не отправился.

## ESN notifications

ESN использует отдельные сущности и модули:

- `ESNNotification`;
- `ESNNotificationType`;
- `EsnNotificationSettings`;
- `ESNNotificationModule`;
- `ESNNotificationProvider`;
- `ESNNotificationCounter`.

ESN может участвовать в общих counters, но бизнес-смысл связан с social feed:
posts, comments, likes, mentions.

Подробнее:

- [ESN notifications and mobile feed](esn-feed-notifications-mobile.md);
- [ESN troubleshooting](esn-troubleshooting.md).

## Mobile push/local notifications

Server-side push handler:

- `PushNotificationSender`;
- `PushNotificationToken`;
- `PushNotificationHistory`;
- `PushNotificationService`.

Mobile-side обработка:

- `MobilePushNotificationReceiver.Mobile.js`;
- `MobileLocalNotificationManager.Mobile.js`;
- `BaseLocalNotificationManager.Mobile.js`.

Подробный mobile flow находится в
[Mobile services and push](mobile-services-push.md). В этом dive важна только
точка стыка: notification pipeline может вызвать push handler.

## Activity reminder fields

Activity хранит бизнес-данные reminder/source logic. NUI center доставляет уже
созданные `Reminding`.

Для Activity-логики смотрите:

- [Activity lifecycle](activity-lifecycle.md);
- [Activity Email Overview](activity-overview.md);
- [Activity troubleshooting](activity-troubleshooting.md).

Типичная ошибка диагностики: искать websocket проблему в Activity fields. Если
строка `Reminding` уже создана, дальше проверяйте `RemindingJob` и delivery.

## Email sending

Email как канал отправки письма и email reminders в панели — разные вещи.

Email sending:

- `EmailSender`;
- `ActivityEmailSender`;
- `EmailSendStatus`;
- mailbox sync.

Notification center:

- `Reminding`;
- `NotificationSender`;
- counters/popup.

Подробнее по email:

- [Activity email sending](activity-email-sending.md);
- [Activity Mailbox Sync](activity-mailbox-sync.md).

## Collision notifications

Файлы:

- `CollisionNotificationSchema.UIv2.cs`;
- `CollisionNotificationDetail.UIv2.js`;
- `CollisionNotificationPage.UIv2.js`.

Это отдельный UI-кейс блокировок/конфликтов записей. Не смешивайте его с
обычными reminders, если проблема касается record collision.

## Marketplace notifications

Файлы пакета `MkpNotifications` (`MkpInstalledAppNews*`, `SysInstalledApp`)
отвечают за новости установленных приложений/marketplace. Это не core
`Reminding` pipeline.

## Краткая матрица

| Симптом | Куда идти |
| ------- | --------- |
| Reminder не пришел по времени | `RemindingJob`, `RemindingRepository` |
| Popup не появился в web UI | `WebSocketNotificationSender`, `ClientMessageBridge` |
| Push не пришел на mobile | `PushNotificationSender`, mobile push docs |
| Mention в ESN не уведомил | ESN docs |
| Activity reminder date не создала reminder | Activity lifecycle/source logic |
| Collision dialog не появился | `CollisionNotification*` UI |
