taskkill /im java.exe /f
taskkill /im dart.exe /f
wmic process where name="Code.exe" call terminate
