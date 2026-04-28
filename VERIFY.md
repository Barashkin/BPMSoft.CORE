# Проверки целостности документации

<!-- Версия: 1.0 | Обновлено: 2026-04-28 | Платформа: BPMSoft 1.9 -->
<!-- Теги: verify, links, markdownlint, encyclopedia -->

Конституция замкнутой модели: [ENCYCLOPEDIA.md](ENCYCLOPEDIA.md).

## 1. Граф ссылок и отсутствие «сирот»

Из каталога `docs/`:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\Verify-Docs.ps1
```

Ожидается: `BrokenLinks = 0`, `Orphans = 0`. Иначе скрипт завершается с кодом `1`.

Параметр `-DocsRoot` не обязателен: по умолчанию используется родитель каталога `tools`.

## 2. Markdownlint (опционально)

Требуется Node.js. Один раз в каталоге `docs/`:

```text
npm install
npm run lint
```

Правила: [`.markdownlint.json`](.markdownlint.json): отключены правила,
массово нарушаемые до ввода единого lint (длинные строки, пробелы у таблиц,
дубликаты заголовков в больших документах, множественные пустые строки).
При правке отдельного файла имеет смысл поправить и локально включить более
строгую проверку через `markdownlint файл.md` без этого конфигурационного файла.

## 3. Синхронизация имён схем с кодом (опционально)

После крупных изменений метаданных сущностей:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\Export-EntitySchemaNames.ps1
```

Результат: [reference/entity-schema-names.generated.json](reference/entity-schema-names.generated.json).

## 4. Что проверять перед merge

- [ ] `Verify-Docs.ps1` без ошибок;
- [ ] новые страницы добавлены в [INDEX.md](INDEX.md) и при необходимости в [AGENT_INDEX.md](AGENT_INDEX.md);
- [ ] при новом primary entry — [`.cursor/rules/bpmsoft-docs.mdc`](../.cursor/rules/bpmsoft-docs.mdc);
- [ ] при изменении перечня сущностей в коде — при необходимости перегенерировать `entity-schema-names.generated.json`.
