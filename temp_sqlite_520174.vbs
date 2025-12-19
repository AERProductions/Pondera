Set objShell = CreateObject("WScript.Shell")
Set objWshScriptExec = objShell.Exec("cmd /c "db/lib/sqlite3_x64.exe" "db/pondera.db" < "temp_sqlite_query_561045.sql"")
WScript.Echo objWshScriptExec.StdOut.ReadAll()
