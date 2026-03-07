' ============================================================
' Stream Hub Chrome Launcher - Fixed Version
' Chrome path locked: C:\Program Files\Google\Chrome\Application
' ============================================================
Option Explicit

Dim WshShell, FSO
Set WshShell = CreateObject("WScript.Shell")
Set FSO = CreateObject("Scripting.FileSystemObject")

Dim siteDir, htmlFile, url, chromePath
siteDir    = "C:\Users\da07222024\OneDrive\Desktop\Site Web en ligne-Forwin10"
htmlFile   = "Stream-Hub_Ver-169_10_with_98-XP_sound-Smooth-Carousel_Securd.html"
url        = "http://localhost:8048/" & htmlFiLe
chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"

' -- Check site folder exists
If Not FSO.FolderExists(siteDir) Then
    MsgBox "Folder not found:" & Chr(13) & siteDir, vbCritical, "Stream Hub Error"
    WScript.Quit 1
End If

' -- Check HTML file exists
If Not FSO.FileExists(siteDir & "\" & htmlFile) Then
    MsgBox "HTML file not found:" & Chr(13) & htmlFile, vbCritical, "Stream Hub Error"
    WScript.Quit 1
End If

' -- Check Chrome exists
If Not FSO.FileExists(chromePath) Then
    MsgBox "Chrome not found:" & Chr(13) & chromePath, vbCritical, "Stream Hub Error"
    WScript.Quit 1
End If

' -- Start HTTP server on Port 8048 (skip if already running)
Dim chk1
chk1 = WshShell.Run("cmd /c netstat -ano | find "":8048"" | find ""LISTENING"" > nul 2>&1", 0, True)
If chk1 <> 0 Then
    WshShell.Run "cmd /c cd /d """ & siteDir & """ && python -m http.server 8048", 0, False
    WScript.Sleep 2000
End If

' -- Start Chrome history server on Port 8765 (skip if already running)
Dim chk2
chk2 = WshShell.Run("cmd /c netstat -ano | find "":8765"" | find ""LISTENING"" > nul 2>&1", 0, True)
If chk2 <> 0 Then
    If FSO.FileExists(siteDir & "\chrome_history_server.py") Then
        WshShell.Run "cmd /c cd /d """ & siteDir & """ && python chrome_history_server.py", 0, False
        WScript.Sleep 2000
    End If
End If

' -- Launch Chrome
WshShell.Run """" & chromePath & """ --new-window """ & url & """"
