# File Security Limits

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: file security, MaxFileSize, FileSecurityMode, rights, upload errors -->

> Права, лимиты размера и security-настройки файлов.

## Rights model

Файлы — это записи entity schema, поэтому на них действуют обычные schema/record rights. Для пользовательских действий проверяйте права на:

- master record;
- `{Entity}File` record;
- operation right, если действие административное;
- license, если включён viewer или доменный модуль.

В клиентской детали добавление файла зависит от `CanEditMasterRecord`.

## File API rights

`IFile` может получать `FileOptions`.

```csharp
var options = new FileOptions {
    UseRights = false,
    RemoveMetadataOnDelete = false
};
```

`UseRights = false` допустим для внутренних lifecycle-операций, но не для пользовательского endpoint без предварительной server-side проверки.

## MaxFileSize

Клиентский upload проверяет системную настройку размера.

```javascript
const sysSettingName = Ext.isEmpty(this.uploadConfig.maxFileSizeSysSettingsName)
    ? "MaxFileSize"
    : this.uploadConfig.maxFileSizeSysSettingsName;
BPMSoft.SysSettings.querySysSettingsItem(sysSettingName, function(value) {
    const maxSizeInBytes = value * 1024 * 1024;
});
```

Для отдельных сценариев могут использоваться другие настройки, например `FileImportMaxFileSize`.

## Upload error handling

`FileUploadErrorHandlers`:

- собирает ошибки по файлам;
- группирует сообщения;
- добавляет признак `isFileOversize`;
- показывает кнопку перехода к настройке размера, если пользователь может управлять sys settings.

Для права на изменение настройки используется `CanManageSysSettings` или `CanManageAdministration` при включённой feature.

## File security schemas

В metadata есть отдельные схемы:

- `FileSecurityModeSchema`;
- `FileSecurityExcludedUriSchema`;
- `FileSecurityExcludedUriEventListener`.

Они описывают security modes и исключения URI из проверок. Не используйте исключения URI как бизнес-авторизацию.

## Viewer license

`FileDetailV2` проверяет лицензию viewer через service call.

```javascript
ServiceHelper.callService("FileViewerService", "CheckHasOperationLicenseFileViewer",
    function(response) {
        this.$isVisibleFileViewer = response.CheckHasOperationLicenseFileViewerResult;
    }, {}, this);
```

Viewer availability не равна праву на скачивание или изменение файла.

## Практические правила

- Проверяйте master record rights до upload/delete.
- Разделяйте "нет прав", "нет лицензии" и "превышен размер".
- Не показывайте пользователю ссылку на sys setting без права администрирования.
- Для внешних или публичных URI отдельно анализируйте file security exclusions.
- Server-side upload всё равно должен валидировать размер и права.

## Связанные документы

- [File Storage Overview](file-overview.md)
- [Security overview](security-overview.md)
- [Security schema and record rights](security-schema-record-rights.md)
- [File troubleshooting](file-troubleshooting.md)
