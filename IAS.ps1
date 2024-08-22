# Check the instructions here on how to use it https://github.com/lstprjct/IDM-Activation-Script/wiki

$ErrorActionPreference = "Stop"
# Enable TLSv1.2 for compatibility with older clients
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

# Define la URL del archivo que deseas descargar
$url = "https://raw.githubusercontent.com/mggons93/Install_IDM_AUTO/main/idman642build20.exe"

# Define la ruta donde se guardará el archivo descargado
$output = "$env:TEMP\idman642build20.exe" 

# Descarga el archivo
Invoke-WebRequest -Uri $url -OutFile $output > $null

# Espera a que la descarga se complete antes de proceder
Write-Host "Descarga completada. Iniciando la instalación..."

# Ejecuta el instalador descargado
Start-Process $output -Wait

# Confirma la finalización de la instalación
Write-Host "Instalación completada."
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

Start-Process $FilePath "$ScriptArgs /act" -Wait

$FilePaths = @("$env:TEMP\IAS*.cmd", "$env:SystemRoot\Temp\IAS*.cmd")
foreach ($FilePath in $FilePaths) { Get-Item $FilePath | Remove-Item }
