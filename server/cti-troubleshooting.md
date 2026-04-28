# CTI Troubleshooting

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: CTI, telephony, troubleshooting, WebRTC -->

> Диагностику CTI удобно вести по цепочке: настройки `SysMsgLib`, параметры
> пользователя, лицензии, загрузка provider, соединение WebRTC, сохранение
> `Call`, затем UI-панель и история.

## Телефония не включается

Проверить:

1. `SysSettings.SysMsgLib` не пустой.
2. В `SysMsgLib` заполнен `CtiProviderName`.
3. Для пользователя есть `SysMsgUserSettings.ConnectionParams`.
4. JSON в `ConnectionParams` корректен.
5. `disableCallCentre` не включен.
6. У пользователя есть лицензии из `LicOperations`.
7. `CtiBaseHelper.GetIsTelephonyEnabled` возвращает `true`.

Типовые сообщения логируются в `CtiBaseHelper`: пустой `SysMsgLib`, отсутствие
лицензии, пустая или некорректная connection config.

## Provider не загружается

Проверить:

- `SysMsgLib.CtiProviderName`;
- наличие AMD module с таким именем;
- доступность файла provider в конфигурации;
- переопределения `initCustomCtiProvider`;
- ошибки `require([ctiProviderName])` в браузере.

Если provider уже есть в `BPMSoft[ctiProviderName]`, повторный `require` не
выполняется.

## WebRTC не подключается

Проверить:

- ответ `MsgUtilService.svc/LogInMsgServer`;
- параметры `url`, `login`, `password`, `debugMode`;
- доступность SIP/WebSocket endpoint;
- корректность `WebRTCAdapter` и `WebRTCSession`;
- browser permissions для микрофона;
- блокировку mixed content, если приложение и WebSocket используют разные
  схемы безопасности;
- звуки из `WebRTCOutRing`, `WebRTCInRing`, `WebRTCCancelRing`.

`BaseWebRTCProvider` генерирует события `initialized`, `disconnected`,
`callStarted`, `callFinished`, `callInfoChanged`. Если UI не реагирует,
проверьте подписки CTI-панели на события provider.

## Звонок не сохраняется или не обновляется

Проверить:

- вызов `UpdateCall` в `MsgUtilService.svc`;
- заполнение `Call.IntegrationId`;
- наличие `databaseUId` у runtime call;
- состояние `call.isSavedInDB`;
- ошибки `UpdateQuery` в `CtiPanelIdentificationUtilities`;
- права на запись в `Call`.

Если идентификация выбрана, но поля не сохранились, проверьте
`needSaveIdentificationData` и содержимое `identificationFieldsData`.

## История звонков пустая

Проверить:

1. Есть ли записи в `Call`.
2. Работает ли view `VwRecentCall`.
3. `CommunicationHistoryRowCount` больше нуля.
4. `CreatedById` совпадает с `CURRENT_USER_CONTACT`.
5. Заполнены `Call.Contact` или `Call.Account`.
6. В ESQ истории добавляются нужные relation columns.

CTI-панель читает историю из `VwRecentCall`, а не напрямую из `Call`.

## Неверно определяется тип звонка

Проверить:

- `Call.Direction`;
- `Call.EndDate`;
- `Call.TalkTime`;
- runtime state `BPMSoft.GeneralizedCallState`;
- соответствие `CallDirection` и `CtiConstants.CallType`.

В истории входящий звонок с `TalkTime = 0` и заполненным `EndDate` трактуется
как missed.

## Абонент не идентифицируется

Проверить:

- `SearchNumberLength`;
- коммуникации контакта/аккаунта;
- `DefaultContactCommunicationType`;
- `DefaultAccountCommunicationType`;
- коллекции `IdentifiedSubscriberPanelCollection` и `SearchResultPanelCollection`;
- `CTISearchResult`;
- нет ли дублей по `SubscriberId`.

Если пользователь вручную выбрал абонента, проверьте сохранение через
`updateCallByIdentificationData`.

## Не открывается запись разговора

Проверить:

- `TelephonyIntegration.EnableCallRecordingFeature`;
- `CallRecordLinkUrlTemplate`;
- `TelephonyIntegration.WebServiceURL`;
- `TelephonyAuthType`;
- `Login`, `Password`, `Token`;
- `TelephonyServerTimeZone`;
- provider-specific service, например `UisCallRecordService`.

Ошибки HTTP-интеграции смотреть в logger, который использует
`TelephonyCallRecordServiceHelper`.

## Header или CTI panel не обновляют состояние

Проверить:

- sandbox message `AgentStateChanged`;
- `CtiPanelConnected`;
- `SelectCommunicationPanelItem`;
- состояние `SysMsgUserStateInLib`;
- интеграцию `MainHeaderSchema.CTIBase.js`;
- подписки `CommunicationPanel`.
