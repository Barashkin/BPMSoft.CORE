# ContentBuilder Export

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: ContentBuilder, MJML, HTML, exporter -->

> Визуальный ContentBuilder и экспорт конфигурации шаблона в HTML.

## EmailTemplateContentBuilder

`EmailTemplateContentBuilder` наследуется от `EmailContentBuilder` и работает с
карточкой `EmailTemplate` через sandbox messages:

| Message | Направление | Назначение |
| ------- | ----------- | ---------- |
| `GetEmailTemplateData` | publish | получить `body` и `bodyConfig` |
| `SetEmailTemplateData` | publish | вернуть HTML и config |
| `CloseEmailTemplateBuilder` | publish | закрыть builder |
| `SetParametersInfo` | subscribe | получить сведения о параметрах |

Если `bodyConfig` пустой, но есть legacy HTML body, builder создаёт `html` block.
Если `bodyConfig` есть, он декодируется как JSON config.

## Save flow

При сохранении builder:

1. Проверяет, что в config есть items.
2. Получает config через `serializeViewModel` или `ContentBuilderHelper`.
3. Обрабатывает images.
4. Выбирает exporter через `ContentExporterFactory`.
5. Экспортирует display HTML.
6. Отправляет `SetEmailTemplateData`.
7. Публикует `CloseEmailTemplateBuilder`.

## Exporter selection

`ContentExporterFactory` выбирает exporter по первому item:

| `ItemType` | Exporter |
| ---------- | -------- |
| `mjblock` | `BPMSoft.MjmlContentExporter` |
| `blockgroup` | рекурсивно по вложенным items |
| `block` | `BPMSoft.EmailContentExporter` |
| `htmlblock` | `BPMSoft.HtmlContentExporter` |
| empty/other | default `BPMSoft.EmailContentExporter` |

## MJML export

`MjmlContentExporter` выполняет цепочку:

1. `ContentBuilderConfigToMjmlConverter.convert(config)`.
2. `mjml(mjmlConfig)`.
3. Опциональная минификация через feature `MinifyEmailHtml`.
4. `sanitizeHTML`.

`sanitizeHTML` использует `BPMSoft.utils.html.sanitizeHTML` и дополнительно
перемещает comment/style nodes.

## Preview and reload

`EmailTemplatePageV2` открывает builder через URL из `ContentBuilderEnumsModule`
в режиме `EMAILTEMPLATE`. После изменения builder отправляет сообщение в
`ServerChannel`, а карточка перечитывает `Body` через ESQ и обновляет iframe.

`ContentBuilderService.ReloadContent(recordId, senderName)` отправляет websocket
message через `MsgChannelUtilities.PostMessage`.

## Практические правила

- Храните исходный config в `bodyConfig`, а render HTML в `body`.
- Для MJML включайте `MinifyEmailHtml` только после проверки результата.
- Не сохраняйте пустой шаблон: builder уже блокирует empty items.
- Legacy HTML можно обернуть в `html` block для редактирования.
- После внешнего изменения body используйте `ReloadContent`.

## Связанные документы

- [Content email templates overview](content-email-templates-overview.md)
- [Email template storage](email-template-storage.md)
- [Content template security limits](content-template-security-limits.md)
- [Client sandbox messages](../client/client-sandbox-messages.md)
