' Stream Hub 隱藏式啟動腳本（無黑視窗）
Set WshShell = CreateObject("WScript.Shell")

' 取得腳本所在目錄
scriptDir = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)

' 切換到腳本目錄
WshShell.CurrentDirectory = scriptDir

' 隱藏執行 Python 伺服器
WshShell.Run "python -m http.server 8000", 0, False

' 等待 2 秒
WScript.Sleep 2000

' 使用 Chrome 開啟瀏覽器
Dim chromePath
chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"

' 如果找不到 Chrome，嘗試其他常見路徑
If Not CreateObject("Scripting.FileSystemObject").FileExists(chromePath) Then
    chromePath = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
End If

' 如果還是找不到，使用預設瀏覽器
If CreateObject("Scripting.FileSystemObject").FileExists(chromePath) Then
    WshShell.Run """" & chromePath & """ http://localhost:8000/Stream-hub_Ver-22_1_with_98-XP_sound-Smooth-Carousel_Securd.html"
Else
    WshShell.Run "http://localhost:8000/Stream-hub_Ver-22_1_with_98-XP_sound-Smooth-Slide-bar.html"
End If
