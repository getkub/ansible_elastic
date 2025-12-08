## Curl or Wget Spawned via Node.js

- Detects when Node.js, directly or via a shell, spawns the curl or wget command.
- This may indicate command and control behavior. Adversaries may use Node.js to download additional tools or payloads onto the system.
- Equivalent of [This](https://elastic.github.io/detection-rules-explorer/rules/d9af2479-ad13-4471-a312-f586517f1243)

```
FROM "your-index-pattern"
| WHERE event.type = 'start'
| WHERE event.action IN ('exec', 'exec_event', 'start', 'ProcessRollup2', 'executed', 'process_started')
| WHERE process.parent.name IN ('node', 'bun', 'node.exe', 'bun.exe')
| WHERE (
    (
      process.name IN ('bash', 'dash', 'sh', 'tcsh', 'csh', 'zsh', 'ksh', 'fish', 'cmd.exe', 'bash.exe', 'powershell.exe') AND
      (process.command_line LIKE '%curl%http%' OR process.command_line LIKE '%wget%http%')
    ) OR
    (
      process.name IN ('curl', 'wget', 'curl.exe', 'wget.exe')
    )
  )
| WHERE process.command_line NOT LIKE '%127.0.0.1%'
| WHERE process.command_line NOT LIKE '%localhost%'
```
