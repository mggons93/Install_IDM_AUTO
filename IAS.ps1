$ErrorActionPreference = "Stop"
# Enable TLSv1.2 for compatibility with older clients
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$url = "https://raw.githubusercontent.com/mggons93/Install_IDM_AUTO/main/idman642build22.exe"

$output = "$env:TEMP\idman642build20.exe" 

Invoke-WebRequest -Uri $url -OutFile $output > $null

Write-Host "Descarga completada. Iniciando la instalación..."
Start-Process $output -Wait

Write-Host "Instalación completada."
Remove-Item $output -Force
Start-Sleep 2
Write-Host "Activando IDM."
$DownloadURL = 'https://raw.githubusercontent.com/mggons93/Install_IDM_AUTO/main/Active/IAS.cmd'

$rand = Get-Random -Maximum 99999999
$isAdmin = [bool]([Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544')
$FilePath = if ($isAdmin) { "$env:SystemRoot\Temp\IAS_$rand.cmd" } else { "$env:TEMP\IAS_$rand.cmd" }

try {
    $response = Invoke-WebRequest -Uri $DownloadURL -UseBasicParsing
}
catch {
    $response = Invoke-WebRequest -Uri $DownloadURL2 -UseBasicParsing
}

$ScriptArgs = "$args "
$prefix = "@REM $rand `r`n"
$content = $prefix + $response
Set-Content -Path $FilePath -Value $content

#Este metodo sirve para activar mediante codigo
#Start-Process $FilePath "$ScriptArgs /act" -Wait

#Este metodo sirve para congelar el modo de prueba indefinidamente
Start-Process $FilePath "$ScriptArgs /frz" -Wait

$FilePaths = @("$env:TEMP\IAS*.cmd", "$env:SystemRoot\Temp\IAS*.cmd")
foreach ($FilePath in $FilePaths) { Get-Item $FilePath | Remove-Item }
