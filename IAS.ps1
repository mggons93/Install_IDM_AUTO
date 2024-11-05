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

# Ruta del registro de IDM
$regPath = "HKCU:\Software\DownloadManager"

# Comprobar si la clave de registro existe
if (Test-Path $regPath) {
    # Establecer el valor de NoAutoUpdate a 1 (desactiva las actualizaciones automáticas)
    Set-ItemProperty -Path $regPath -Name "NoAutoUpdate" -Value 1
    Write-Host "Las actualizaciones automáticas de IDM han sido desactivadas."
} else {
    Write-Host "No se encontró la clave de registro de IDM. Asegúrate de que IDM esté instalado."
}

# Función para bloquear la conexión de IDM usando el archivo hosts
function Bloquear-IDM-HOSTS {
    $hostsFilePath = "C:\Windows\System32\drivers\etc\hosts"
    $idmBlockedServers = @(
        "www.internetdownloadmanager.com",
        "downloadmanager.com",
        "idman.exe"
    )
    
    # Verificar si el archivo hosts existe
    if (Test-Path $hostsFilePath) {
        # Abrir el archivo y agregar las entradas para bloquear
        foreach ($server in $idmBlockedServers) {
            # Agregar la redirección para cada servidor IDM
            $entry = "127.0.0.1 $server"
            Add-Content -Path $hostsFilePath -Value $entry
            Write-Host "Añadido al archivo hosts: $entry"
        }
    } else {
        Write-Host "No se encuentra el archivo hosts."
    }
}

# Función para bloquear IDM mediante el Firewall de Windows
function Bloquear-IDM-Firewall {
    $idmPath = "C:\Program Files (x86)\Internet Download Manager\IDMan.exe"
    
    # Verificar si IDM está instalado
    if (Test-Path $idmPath) {
        # Crear una nueva regla de salida en el firewall
        New-NetFirewallRule -DisplayName "Bloquear IDM" -Direction Outbound -Program $idmPath -Action Block -Profile Any
        Write-Host "Regla de firewall creada para bloquear IDM."
    } else {
        Write-Host "No se encuentra el archivo ejecutable de IDM en la ruta especificada."
    }
}

# Ejecutar ambas funciones
Bloquear-IDM-HOSTS
Bloquear-IDM-Firewall
