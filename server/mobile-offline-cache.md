# Mobile Offline Cache

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: Mobile, offline, cache, SyncManager, ModelCache -->

> Offline/cache контур мобильного клиента: `SyncManager`, `ModelCache`,
> локальный SQL, состояния страниц и конфликты export.

## Sync state mixin

`MobileCacheSyncStateControllerMixin.Mobile.js` добавляет состояние sync на grid
pages и подписывается на события:

- `syncstart`;
- `syncfinish`;
- `syncfailed`.

Mixin хранит:

- `hasExportConflicts`;
- `autoShowNoConnectionStatusPanel`;
- `stateData`;
- `isMainModelSynchronized`.

## Page states

Контроллер переключает page state:

| State | Когда используется |
| ----- | ------------------ |
| `Default` | данные доступны |
| `DataLoading` | идёт синхронизация |
| `NoConnection` | нет соединения |
| `ServiceUnavailable` | сервис недоступен |
| `DataLoadingError` | ошибка export или конфликт |

Для offline-сценариев отображается дата последней синхронизации основной
модели.

## Model cache managers

`MobileSysAdminUnitCacheManager.Mobile.js` показывает custom cache manager:

- читает offline cache через `BPMSoft.ProxyType.Offline`;
- дочитывает online записи через `BPMSoft.ProxyType.Online`;
- строит локальный SQL через `BPMSoft.Sql.InsertBuilder`;
- пишет lookup cache через `BPMSoft.DataUtils.getLookupCachingSqls`;
- регистрируется через `BPMSoft.ModelCache.registerManagerClassName`.

## Online and offline boundary

Если данные уже есть offline, повторный cache не выполняется. Если запись связана
с текущим пользователем, manager также не делает лишнюю загрузку.

## Conflicts

`hasExportConflicts` переводит страницу в `DataLoadingError`, даже если state
пытались вернуть в `Default`. Это защищает UI от показа нормального состояния
после неуспешного export.

## Практические правила

- Подписывайтесь на `SyncManager` только на main grid, не на details.
- Показывайте last sync date при offline/no connection.
- Для lookup cache используйте стандартные SQL builders.
- Не обходите `ModelCache.registerManagerClassName` для custom manager.
- Export conflicts должны блокировать возврат в обычное состояние.

## Связанные документы

- [Mobile overview](mobile-overview.md)
- [Mobile manifest sync](mobile-manifest-sync.md)
- [Mobile troubleshooting](mobile-troubleshooting.md)
- [File Storage Overview](file-overview.md)
