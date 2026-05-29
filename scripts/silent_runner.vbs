' silent_runner.vbs — PowerShell を完全不可視で実行
' 使い方: cscript silent_runner.vbs "<scriptPath>"
' Task Scheduler から呼ぶと一瞬たりともターミナルが見えなくなる

If WScript.Arguments.Count < 1 Then
    WScript.Quit 1
End If

scriptPath = WScript.Arguments(0)
cmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File """ & scriptPath & """"

Set WshShell = CreateObject("WScript.Shell")
' 第2引数 0 = 完全不可視、第3引数 False = 非同期 (待たない)
WshShell.Run cmd, 0, False
Set WshShell = Nothing
