' Stream Hub Chrome 專用啟動腳本
Set WshShell = CreateObject("WScript.Shell")
Set FSO = CreateObject("Scripting.FileSystemObject")

' 取得腳本所在目錄
scriptDir = FSO.GetParentFolderName(WScript.ScriptFullName)

' 切換到腳本目錄
WshShell.CurrentDirectory = scriptDir

' 隱藏執行 Python 伺服器
WshShell.Run "python -m http.server 8000", 0, False

' 等待 2 秒
WScript.Sleep 2000

' 尋找 Chrome 的多個可能位置
Dim chromePaths(4)
chromePaths(0) = "C:\Program Files\Google\Chrome\Application\chrome.exe"
chromePaths(1) = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
chromePaths(2) = WshShell.ExpandEnvironmentStrings("%LOCALAPPDATA%") & "\Google\Chrome\Application\chrome.exe"
chromePaths(3) = WshShell.ExpandEnvironmentStrings("%PROGRAMFILES%") & "\Google\Chrome\Application\chrome.exe"
chromePaths(4) = WshShell.ExpandEnvironmentStrings("%PROGRAMFILES(X86)%") & "\Google\Chrome\Application\chrome.exe"

Dim chromePath, found
found = False

' 搜尋 Chrome
For Each path In chromePaths
    If FSO.FileExists(path) Then
        chromePath = path
        found = True
        Exit For
    End If
Next

' 開啟瀏覽器
Dim url
url = "http://localhost:8000/Stream-Hub_Ver-178_1_with_98-XP_sound-Smooth-Carousel_Securd.html"

If found Then
    ' 使用 Chrome 開啟（加入 --new-window 參數開新視窗）
    WshShell.Run """" & chromePath & """ --new-window """ & url & """"
Else
    ' Chrome 未安裝，使用預設瀏覽器
    MsgBox "未找到 Chrome 瀏覽器，將使用系統預設瀏覽器開啟", vbInformation, "Stream Hub"
    WshShell.Run url
End If
