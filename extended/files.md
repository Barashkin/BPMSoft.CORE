# Работа с файлами в системе

<!-- Версия: 1.0 | Обновлено: 2026-03-19 | Платформа: BPMSoft 1.9 -->
<!-- Теги: файлы, FileRepository, IFile, загрузка, удаление -->

> Дополнение к [file-storage.md](../server/file-storage.md). Краткая шпаргалка по API. Подробности — в основном документе.

## Загрузка файла (сервер)

```csharp
// FileRepository.Base.cs
var repo = new FileRepository(UserConnection);
var uploadInfo = new FileEntityUploadInfo("ContactFile", fileId, "document.pdf") {
    TotalFileLength = fileBytes.Length
};
uploadInfo.Content = new MemoryStream(fileBytes);
repo.UploadFile(uploadInfo);
```

## Чтение файла

```csharp
IFileUploadInfo fileInfo = repo.LoadFile(entitySchemaUId, fileId);
// fileInfo.Content или поток — контент
// fileInfo.TotalFileLength — размер
```

## Удаление файла

```csharp
repo.DeleteFile("ContactFile", fileId);
repo.DeleteFiles("ContactFile", new[] { fileId1, fileId2 });
```

## Через IFile API (при включённом FeatureUseFileApi)

```csharp
IFileFactory fileFactory = userConnection.GetFileFactory();
var fileLocator = new EntityFileLocator("ContactFile", fileId);
IFile file = fileFactory.Create(fileLocator);
file.Name = "document.pdf";
file.SetAttribute("ContactId", contactId);
using (var stream = new MemoryStream(fileBytes)) {
    file.Write(stream, FileWriteOptions.SinglePart);
}
// Чтение
IFile readFile = fileFactory.Get(fileLocator);
using (Stream stream = readFile.Read()) { ... }
// Удаление
readFile.Delete();
```

## Создание записи файловой сущности с контентом

```csharp
var schema = UserConnection.EntitySchemaManager.GetInstanceByName("ContactFile");
var entity = schema.CreateEntity(UserConnection);
entity.SetDefColumnValues();
entity.SetColumnValue("Id", Guid.NewGuid());
entity.SetColumnValue("Name", "Договор.pdf");
entity.SetColumnValue("ContactId", contactId);
entity.SetColumnValue("TypeId", FileConsts.FileTypeUId);
entity.SetStreamValue("Data", new MemoryStream(fileBytes));
entity.SetColumnValue("Size", fileBytes.Length);
entity.Save();
```

---

**Связанные документы:** [Файлы и хранилища](../server/file-storage.md) | [Расширенное руководство — оглавление](INDEX.md)
