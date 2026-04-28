# Mailbox Exchange Client UI

<!-- Версия: 1.0 | Обновлено: 2026-04-28 | Платформа: BPMSoft 1.9 -->
<!-- Теги: MailboxSyncSettings, client, UI, MeetingInvitationsMixin, ServiceHelper -->

> Клиентские модули mailbox settings, Exchange sync tabs и meeting invitations.

## Mailbox settings modules

Основные модули:

| Файл | Назначение |
| ---- | ---------- |
| `MailboxSynchronizationSettingsModule.Exchange.js` | grid mailbox settings |
| `MailboxSynchronizationSettingsPageModule.Exchange.js` | page module wrapper |
| `MailboxSyncSettingsViewModel.Exchange.js` | view model данных mailbox |
| `MailboxFolderSyncSettingsModule.Exchange.js` | folder sync settings |

`MailboxSynchronizationSettingsModule` строит grid с колонками:

- `SenderEmailAddress`;
- `UserName`;
- `Type`;
- `MailBoxOwner`.

Active row actions:

- `Edit`;
- `Delete`;
- `EditRights`.

## Sync settings UI

Exchange-specific модули:

- `SyncSettings.Exchange.js`;
- `SyncSettingsMixin.Exchange.js`;
- `SyncSettingsEditMixin.Exchange.js`;
- `ActivitySyncSettingsTab.Exchange.js`;
- `ActivitySyncSettingsEdit.Exchange.js`;
- `ContactSyncSettingsTab.Exchange.js`;
- `ContactSyncSettingsEdit.Exchange.js`;
- `EmailSyncSettings.ExchangeListener.js`.

Эти модули соединяют mailbox settings с tabs для email, activity/calendar и
contact sync.

## NUI/UIv2 boundary

В кодовой базе также есть NUI/UIv2 модули:

- `MailboxSynchronizationSettingsModule.NUI.js`;
- `MailboxSynchronizationSettingsPageModule.NUI.js`;
- `EmailSyncSettings.UIv2.js`;
- `CredentialsSyncSettingsMixin.UIv2.js`;
- `SyncSettingsTabModule.UIv2.js`.

Они относятся к тому же пользовательскому сценарию, но могут обслуживать другой
UI shell. При доработке проверяйте, какой module реально используется в target
workspace.

## Meeting invitations UI

`MeetingInvitationsMixin.IntegrationV2.js` добавляет клиентский flow для
приглашений:

- проверяет feature `MeetingInvitation`;
- вызывает `MeetingService.CanUserChangeMeeting`;
- при необходимости вызывает `GetMeetingInvitationInfo`;
- показывает confirmation;
- вызывает `SendInvitations`;
- обновляет flags `ParticipantsInvited`, `MeetingExported`,
  `InvitationButtonEnabled`, `OutdatedMeeting`.

## Service calls

Клиентские модули используют `ServiceHelper` и backend services:

| Service | Назначение |
| ------- | ---------- |
| `MailboxSynchronizationSettingsService` | IMAP/SMTP validation, BPMCRM folder, job checks |
| `MailboxSettingsService` | IntegrationV2 mailbox management, jobs, folder tree |
| `ExchangeSyncService` | Exchange folders и trigger cleanup |
| `ExchangeEventsService` | start/stop/recreate listener |
| `MeetingService` | invitations and calendar change checks |

## Связанные документы

- [Mailbox Exchange Sync Overview](mailbox-exchange-sync-overview.md)
- [Mailbox Exchange Listener Calendar](mailbox-exchange-listener-calendar.md)
- [Client Service Calls](services-client-calls.md)
- [Client Sandbox Messages](../client/client-sandbox-messages.md)
