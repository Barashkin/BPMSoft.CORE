# AI LLM Attachments

<!-- Версия: 1.0 | Обновлено: 2026-04-27 | Платформа: BPMSoft 1.9 -->
<!-- Теги: AI, LLM, attachments, PDF, prompt injection -->

> Как `LlmUserTask` добавляет содержимое файлов в prompt: `EntityFileLocator`,
> PDF extraction через PdfPig и injection через XML-like блоки.

## Где используется

Вложения обрабатываются только в `LlmUserTask`. Если параметр `Files` пустой,
prompt передаётся provider без изменений.

Если файлы есть, задача создаёт список `LlmAttachment` и вызывает
`ILlmAttachmentInjector.Inject`.

## Извлечение файлов

`LlmUserTask.CreateAttachments()` ожидает, что каждый composite object содержит
значение по ключу `File`:

```text
compositeObject["File"] -> EntityFileLocator
```

Далее task:

- получает файл через `UserConnection.GetFile(fileLocator)`;
- читает bytes через `file.ReadBytes()`;
- передаёт bytes в `ILlmPdfExtractor.Extract`;
- добавляет `LlmAttachment` с `Name` и `Content`.

## PDF extractor

`LlmPdfExtractor` зарегистрирован как default binding для `ILlmPdfExtractor`.
Он использует `UglyToad.PdfPig`:

```text
PdfDocument.Open(bytes)
  -> foreach page
  -> ContentOrderTextExtractor.GetText(page)
```

Если PDF повреждён или не соответствует формату, `PdfDocumentFormatException`
оборачивается в `LlmProviderException` с указанием entity schema и record id
файла.

## Prompt injection

`LlmAttachmentInjector` добавляет каждый attachment в конец prompt по шаблону:

```text
<attachment name="{name}">
{content}
</attachment>
```

Результирующий prompt остаётся обычной строкой. Provider не знает о файлах и
получает уже объединённый текст.

## Ограничения

- Нет отдельной обработки DOCX, XLSX, изображений или OCR.
- Нет chunking, token budgeting и сжатия текста вложений.
- Нет защиты от prompt injection внутри содержимого файла.
- Все вложения добавляются последовательно в один prompt.

Если нужны большие документы или разные форматы, расширение лучше делать на
уровне extractor/injector, не меняя provider contract.

## Связанные документы

- [ai-llm-process-user-task.md](ai-llm-process-user-task.md)
- [ai-llm-providers.md](ai-llm-providers.md)
- [File Storage](file-storage.md)
