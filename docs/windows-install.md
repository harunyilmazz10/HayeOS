# Windows Install

After permanent plugin install, normal project setup is:

```text
/haye:start
```

If the project has no Haye memory yet, `/haye:start` asks:

```text
Bu projede Haye hafızası bulunamadı. Şimdi otomatik oluşturayım mı?
```

Choose yes and Haye creates `.hayeos.json` plus the Obsidian vault automatically. You can also run:

```text
/haye:init-memory
```

Users normally do not need to run `bin/haye` manually.

Manual fallback commands for Windows:

```text
C:\Users\hayed\Desktop\HayeOS\bin\haye.cmd init
```

or:

```text
powershell -ExecutionPolicy Bypass -File C:\Users\hayed\Desktop\HayeOS\bin\haye.ps1 init
```

Do not run the Python `bin/haye` file through bash on Windows. Use `haye.cmd`, `haye.ps1`, `/haye:start`, or `/haye:init-memory`.
