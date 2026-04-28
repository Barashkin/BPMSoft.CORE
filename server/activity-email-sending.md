# Activity Email Sending

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: EmailSender, IEmailSender, ActivityEmailSender, EmailSendStatus -->

> Отправка email: `IEmailSender`, `EmailSender`, `ActivityEmailSender`, статусы и ошибки.

## IEmailSender binding

`EmailSender` зарегистрирован как default binding для `IEmailSender`.

```csharp
[DefaultBinding(typeof(IEmailSender))]
public class EmailSender : IEmailSender
```

Код обычно получает отправитель через `ClassFactory` или создаёт `EmailSender` с `EmailClientFactory`.

## Base EmailSender

Базовый `EmailSender` отправляет `EmailMessage` через `IEmailClient`.

```csharp
public virtual void Send(EmailMessage emailMessage, bool ignoreRights = false) {
    IEmailClient emailClient = _emailClientFactory
        .CreateEmailClient(emailMessage.From.ExtractEmailAddress(), ignoreRights);
    SendMessage(emailClient, emailMessage, ignoreRights);
}
```

Ошибки отправки логируются и передаются в synchronization error helper.

## HtmlEmailMessageSender

`HtmlEmailMessageSender` обрабатывает HTML body:

- находит inline images;
- связывает content ids;
- удаляет лишний inline content из `ActivityFile`;
- оборачивает ошибки формата в `EmailException`.

## ActivityEmailSender

`ActivityEmailSender` работает с записью `Activity`:

1. Загружает activity и проверяет, что тип — email.
2. Переводит `EmailSendStatus` в `InProgress`.
3. Создаёт `EmailMessage` из полей activity.
4. Отправляет сообщение.
5. Заполняет `SendDate`, mailbox metadata и права.
6. Завершает activity и ставит send status `Sended`.
7. При ошибке пишет `ErrorOnSend`.

## EmailSendStatus

| Code | Смысл |
| ---- | ----- |
| `NotSend` | письмо ещё не отправлено |
| `InProgress` | отправка выполняется |
| `Sended` | письмо отправлено |
| `Opened` | письмо открыто |
| `ErrorOnSend` | ошибка отправки |

`ErrorOnSend` хранит текст ошибки для диагностики.

## Attachments

`ActivityEmailSender` получает вложения из `ActivityFile` и конвертирует их в `EmailAttachment`. Для чтения контента используется `FileRepository.LoadFile`.

## Default sender

`SendEmailUserTask` может отправлять через:

- mailbox sender, если задан `Sender`;
- default sender;
- legacy SMTP sys settings при включённой старой интеграции.

## Практические правила

- Перед отправкой проверяйте наличие получателей.
- Не считайте `Status = Finished` признаком успешной отправки без `EmailSendStatus`.
- Для HTML-писем проверяйте inline attachments.
- Ошибки отправки смотрите в `ErrorOnSend` и sync error helper.
- `ignoreRights` используйте только для системных сценариев.

## Связанные документы

- [Activity Email Overview](activity-overview.md)
- [Activity process user tasks](activity-process-user-tasks.md)
- [Activity troubleshooting](activity-troubleshooting.md)
- [File Repository API](file-repository-api.md)
