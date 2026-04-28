# OCC Channel Integrations

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: OCC, channel, telegram, vk, facebook, instagram, line, teams, skype, max -->

> Матрица интеграционных каналов OCC, кроме WhatsApp MFMS/Edna. Документ показывает, какой client view и какой server method используются, какие поля реально требуются и куда они сохраняются в `BPMSoftOCCChannel`.

## Обзор

Большинство каналов OCC подключаются по одному паттерну:

1. client-side `BPMSoftOCC*ChannelView` собирает параметры;
1. вызывает `BPMSoftOCCAddChannelService.Add*Channel(...)`;
1. сервис строит JSON для внешнего connector endpoint;
1. при успехе создаётся/обновляется запись `BPMSoftOCCChannel`.

Общая инфраструктура:

- SysSettings `BPMSoftOCCServices` - шаблон URL connector service;
- SysSettings `BPMSoftOCCOperatoHost` - host для построения webhook/base URL;
- SysSettings `BPMSoftOCCOperatorAppId` - app/client id для connector payload.

## Общие поля `BPMSoftOCCChannel`

В зависимости от канала сервис пишет комбинацию следующих колонок:

- `Id`
- `Name`
- `ConfigurationId`
- `Weight`
- `TypeId`
- `Token`
- `InternalId`
- `ClientId`
- `ClientSecret`
- `SiteCode`
- `WidgetVersion`

Практическое правило:

- `Token` чаще всего хранит access token / bot token;
- `InternalId` - group/page/phone/environment id;
- `ClientId` и `ClientSecret` - app credentials;
- `SiteCode` используется как дополнительное внешнее id у Instagram.

## Матрица каналов

| Канал | Client view | Service method | Connector endpoint | Основные входные поля | Что сохраняется в `BPMSoftOCCChannel` |
| ----- | ----- | ----- | ----- | ----- | ----- |
| Telegram | `BPMSoftOCCTelegramChannelView` | `AddTelegramChannel` | `telegram/api/v1/webhook` | `name`, `token`, `weight`, `id` | `Token` |
| VK | `BPMSoftOCCVKChannelView` | `AddVKChannel` | `vk/api/v1/webhook` | `name`, `token`, `weight`, `internalId`, `id` | `Token`, `InternalId` |
| VK Wall | `BPMSoftOCCVKWallChannelView` | `AddVKWallChannel` | `vkwall/api/v1/webhook` | `name`, `token`, `weight`, `internalId`, `id` | `Token`, `InternalId` |
| Facebook | `BPMSoftOCCFBChannelView` | `AddFBChannel` | `fb/api/v1/webhook/fb` | `name`, `token`, `weight`, `internalId`, `id` | `Token`, `InternalId`, channel `Id = external id` |
| Facebook Messenger | `BPMSoftOCCFBMChannelView` | `AddFBMChannel` | `fb/api/v1/webhook/fbm` | `name`, `token`, `weight`, `internalId`, `id` | `Token`, `InternalId`, channel `Id = external id` |
| Instagram | `BPMSoftOCCInstagramChannelView` | `AddInstagramChannel` | `instagram/api/v1/webhook` | `name`, `token`, `weight`, `internalId`, `instagramInternalId`, `id` | `Token`, `InternalId`, `SiteCode` |
| Skype | `BPMSoftOCCSkypeChannelView` | `AddSkypeChannel` | `skype/api/v1/webhook` | `name`, `clientId`, `clientSecret`, `weight`, `id` | `ClientId`, `ClientSecret` |
| SFB | `BPMSoftOCCSFBChannelView` | `AddSFBChannel` | `skype/api/v1/webhook` | `name`, `clientId`, `clientSecret`, `weight`, `id` | `ClientId`, `ClientSecret` |
| Teams | `BPMSoftOCCTeamsChannelView` | `AddTeamsChannel` | `teams/api/v1/webhook` | `name`, `clientId`, `clientSecret`, `weight`, `id` | `ClientId`, `ClientSecret` |
| WeChat | `BPMSoftOCCWeChatChannelView` | `AddWeChatChannel` | `wechat/api/v1/webhook` | `name`, `clientId`, `clientSecret`, `weight`, `id` | `ClientId`, `ClientSecret` |
| Workplace | `BPMSoftOCCWorkplaceChannelView` | `AddWorkplaceChannel` | `workplace/api/v1/webhook` | `name`, `token`, `clientId`, `weight`, `id` | `Token`, `InternalId` |
| Twitter | `BPMSoftOCCTwitterChannelView` | `AddTwitterChannel` | `twitter/api/v1/webhook` | `accessToken`, `accessSecret`, `consumerSecret`, `consumerKey`, `environmentName`, `weight`, `id` | `Token`, `ClientSecret`, `InternalId` |
| Line | `BPMSoftOCCLineChannelView` | `AddLineChannel` | `line/api/v1/webhook` | `clientSecret`, `webhook`, `weight`, `id` | `ClientSecret` |
| Viber | `BPMSoftOCCViberChannelView` | `AddViberChannel` | `viber/api/v1/webhook` | `token`, `weight`, `id` | `Token` |
| OK | `BPMSoftOCCOKChannelView` | `AddOKChannel` | `ok/api/v1/webhook` | `token`, `weight`, `id` | `Token` |
| Max | `BPMSoftOCCMaxChannelView` | `AddMaxChannel` | `max/api/v1/webhook` | `token`, `weight`, `id` | `Token` |
| Custom/API | `BPMSoftOCCCustomChannelView` / `BPMSoftOCCBpmChannelView` | `AddAPIChannel`, `AddDefaultChannel`, `AddBPMSoftOCCChannel` | `custom/api/v1/webhook`, `site/webhook` и др. | `url`, `token`, `domain`, `weight`, `id` | чаще `Token` или `InternalId` |

## Разбор по типам credential-модели

### Token-only каналы

Самые простые для поддержки:

- Telegram
- Viber
- OK
- Max
- частично VK / Workplace / Instagram

Обычно UI содержит `Name`, `Token`, `Weight`, а сервис сохраняет `Token`.

### App credentials каналы

Используют пару `ClientId` + `ClientSecret`:

- Skype
- Teams
- WeChat
- SFB

Для них channel view обычно:

- удаляет стандартное поле `Token`;
- добавляет `ClientId` и `ClientSecret`;
- показывает `Webhook` как readonly field.

### Social/page каналы с дополнительным внешним id

Используют и токен, и внешний идентификатор ресурса:

- Facebook / Facebook Messenger
- Instagram
- VK / VK Wall
- Workplace

Здесь типично участвуют:

- `Token`
- `InternalId`
- иногда отдельный внешний `ChannelId`/page id
- для Instagram ещё `instagramInternalId` -> `SiteCode`

## Что реально делает `BPMSoftOCCAddChannelService`

### 1. Выбирает доступный connector host

`GetConnectorUrl()`:

- читает `BPMSoftOCCOperatoHost`;
- проверяет `/heartbeat`;
- выбирает host по ping/доступности.

### 2. Формирует JSON payload по `ChannelCode`

`AddCustomChannel(...)` меняет набор полей в payload в зависимости от канала:

- Telegram/Viber/Line/Max - простой payload;
- Teams/Skype/WeChat - `AzureAppId` / `AzureAppSecret` или `WechatAppId` / `WechatAppSecret`;
- Twitter - составные credential fields;
- Instagram/Facebook - `InternalId` и внешний channel/page id.

### 3. Вызывает внешний connector endpoint

Практически всегда это POST на `/api/v1/webhook`, но с channel-specific префиксом:

- `telegram`
- `vk`
- `fb`
- `instagram`
- `teams`
- `line`
- `max`

### 4. Сохраняет BPMSoft channel entity

Если `updateMode = false`, сервис вставляет/обновляет запись `BPMSoftOCCChannel` с конфигурацией канала.

## Наблюдаемые UI-паттерны channel view

### Базовый view

`BPMSoftOCCChannelView` даёт:

- `ConfigurationId`
- `ChannelId`
- `AllIsBad`
- `ErrorText`
- кнопки `AfterAdding`, `BackToPrevios`, loading mask lifecycle

### Специализированные view

Отличаются в основном:

- набором полей;
- именем метода сервиса;
- возможностью отобразить webhook URL;
- дополнительными client-side проверками.

Например, `BPMSoftOCCTeamsChannelView`:

- убирает `TokenField`;
- добавляет `ClientId`, `ClientSecret`;
- показывает readonly `Webhook`;
- использует копирование webhook в буфер.

## Отличие от WhatsApp MFMS/Edna

Эта матрица сознательно не покрывает `BPMSoftOCCWAMfmsJson`.

Ключевые отличия MFMS/Edna от обычных каналов:

- используется отдельный сервис `BPMSoftOCCAddMfmsJsonService`, а не общий `BPMSoftOCCAddChannelService`;
- конфигурация хранится как JSON в `Token`;
- endpoint отличается: `wa/edna` или `wa/mfms/json`;
- UI зависит от `BPMSoftOCCUseObsoleteWhatsAppApi`.

Подробности см. в [occ-whatsapp-mfms-json.md](occ-whatsapp-mfms-json.md).

## Что проверять при проблеме создания канала

| Симптом | Что проверить |
| ----- | ----- |
| View открывается, но webhook не строится | `BPMSoftOCCOperatoHost`, `GetConnectorUrl()` |
| Канал не создаётся, ошибка connector | `BPMSoftOCCServices`, channel-specific payload |
| Канал создался, но поля в карточке пустые | mapping в `AddCustomChannel(...)` для нужного `ChannelCode` |
| Неверный тип credential-полей в UI | конкретный `BPMSoftOCC*ChannelView*.js` |
| Неправильный icon/type в chat list | `BPMSoftOCCChatListPanelSchema.getChannelImg()` |

## Когда смотреть этот документ

Открывай его, если нужно:

- добавить или поддержать конкретный канал;
- понять, какие поля реально нужны UI и серверу;
- найти connector endpoint для канала;
- разобраться, почему конфигурация оказалась в `Token`, `InternalId` или `ClientSecret`;
- отличить общий channel flow от WhatsApp MFMS/Edna.

## Ключевые файлы

| Область | Файл |
| ----- | ----- |
| Общий add-channel service | `Autogenerated/Src/BPMSoftOCCAddChannelService.BPMSoftOCC.cs` |
| Базовый channel view | `Autogenerated/Src/BPMSoftOCCChannelView.BPMSoftOCC.js` |
| Telegram view | `Autogenerated/Src/BPMSoftOCCTelegramChannelView.BPMSoftOCC.js` |
| Teams view | `Autogenerated/Src/BPMSoftOCCTeamsChannelView.BPMSoftOCC.js` |
| Max view | `Autogenerated/Src/BPMSoftOCCMaxChannelView.BPMSoftOCC.js` |
| WhatsApp MFMS/Edna | `Autogenerated/Src/BPMSoftOCCAddMfmsJsonService.BPMSoftOCCWAMfmsJson.cs` |

## Связанные документы

- [Архитектура OCC](../architecture/bpmsoft-occ.md)
- [Сервисы OCC и Sender](bpmsoft-occ-services.md)
- [Настройки OCC](../reference/bpmsoft-occ-settings.md)
- [Клиентский OCC UI](../client/occ-client-ui.md)
- [WhatsApp MFMS/Edna](occ-whatsapp-mfms-json.md)
