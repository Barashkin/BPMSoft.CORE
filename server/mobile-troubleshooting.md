# Mobile Troubleshooting

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: Mobile troubleshooting, sync, offline, push, manifest -->

> Диагностика мобильного приложения: manifest, sync, offline cache, UI pages,
> service calls, push и local notifications.

## Модель не появляется в мобильном приложении

Проверьте:

- `Modules` в mobile manifest;
- `CustomSchemas`;
- `ApplicationRequiredModels`;
- `ModelDataImportConfig`;
- workplace manifest, а не только base manifest;
- mobile designer converter, если настройки идут из UI.

## Данные не синхронизируются

Проверьте:

- `SyncOptions.ModelDataImportConfig`;
- `SyncFilter` и `QueryFilter`;
- macros current user/current contact;
- `SyncColumns`;
- `ExpandLookups`;
- `SyncByParentObjectWithRights`;
- page state `DataLoadingError`.

## Offline-страница показывает no connection

Проверьте:

- события `BPMSoft.SyncManager`;
- last sync date основной модели;
- state `NoConnection`;
- наличие cache manager для модели;
- export conflicts.

## Lookup или detail пустые offline

Проверьте:

- добавлен ли lookup в `SysLookupsImportConfig`;
- указаны ли lookup columns в `SyncColumns`;
- есть ли `ExpandLookups`;
- настроен ли `SyncByParentObjectWithRights` для detail;
- cache SQL не падает в custom manager.

## Service call падает

Проверьте:

- `serviceName` и `methodName`;
- URL формата `rest/{serviceName}/{methodName}`;
- JSON body в `jsonData`;
- timeout;
- `ServiceResponseParser`;
- server-side service route и `BodyStyle`.

## Push не открывает запись

Проверьте:

- payload содержит `entityName` и `recordId`;
- module не hidden в application config;
- запись существует;
- включён ли `ModelCache`;
- receiver зарегистрирован через `BPMSoft.PushNotification.setDefaultReceiver`;
- для Flutter есть `openFlutterPageByMetadata`.

## Local notification не создаётся

Проверьте:

- `ShowMobileLocalNotifications`;
- view `VwRemindings`;
- фильтр current user contact;
- `SysEntitySchemaId` Activity;
- `RemindTime` больше текущего времени;
- Android icon/title settings.

## Пользователь не видит mobile workplace

Проверьте:

- запись `SysMobileWorkplace`;
- стабильный `Code`;
- `SysRoleInMobWorkplace`;
- роль пользователя;
- syssetting `MobileApplicationMode`;
- portal/default workplace manifest.

## Связанные документы

- [Mobile overview](mobile-overview.md)
- [Mobile manifest sync](mobile-manifest-sync.md)
- [Mobile offline cache](mobile-offline-cache.md)
- [Mobile services push](mobile-services-push.md)
