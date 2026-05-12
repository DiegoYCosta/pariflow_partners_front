param(
  [string]$WebPort = "8082",
  [string]$ApiBaseUrl = "http://localhost:3000/api/v1",
  [string]$EnvFile = ".env.front.preview",
  [switch]$UseDevToken
)

$ErrorActionPreference = "Stop"

function Test-LocalApiBaseUrl {
  param([string]$Value)

  $uri = [Uri]$Value
  $hostName = $uri.Host.ToLowerInvariant()
  return $hostName -eq "localhost" -or
    $hostName -eq "127.0.0.1" -or
    $hostName -eq "::1"
}

if ($UseDevToken -and -not (Test-LocalApiBaseUrl $ApiBaseUrl)) {
  throw "UseDevToken so e permitido com ApiBaseUrl local. Para API online, use Firebase real."
}

function Read-DartDefines {
  param([string]$Path)

  $defines = @()
  if (-not (Test-Path -LiteralPath $Path)) {
    Write-Warning "Arquivo de env do front nao encontrado: $Path. Firebase pode ficar indisponivel."
    return $defines
  }

  foreach ($line in Get-Content -LiteralPath $Path) {
    $trimmed = $line.Trim()
    if ([string]::IsNullOrWhiteSpace($trimmed) -or $trimmed.StartsWith("#")) {
      continue
    }

    $parts = $trimmed.Split("=", 2)
    if ($parts.Count -ne 2) {
      continue
    }

    $key = $parts[0].Trim()
    $value = $parts[1].Trim()
    if ($key -notmatch "^PARIFLOW_[A-Z0-9_]+$" -or [string]::IsNullOrWhiteSpace($value)) {
      continue
    }
    if ($key -eq "PARIFLOW_API_BASE_URL" -or $key -eq "PARIFLOW_ENABLE_DEV_TOKEN") {
      continue
    }

    $defines += "--dart-define=$key=$value"
  }

  return $defines
}

$devTokenValue = if ($UseDevToken) { "true" } else { "false" }
$dartDefines = Read-DartDefines -Path $EnvFile
$dartDefines += "--dart-define=PARIFLOW_API_BASE_URL=$ApiBaseUrl"
$dartDefines += "--dart-define=PARIFLOW_ENABLE_DEV_TOKEN=$devTokenValue"
$flutterArgs = @(
  "run",
  "-d",
  "web-server",
  "--web-hostname",
  "127.0.0.1",
  "--web-port",
  $WebPort
) + $dartDefines

Write-Host "PariFlow front local: http://127.0.0.1:$WebPort"
Write-Host "PariFlow API: $ApiBaseUrl"
Write-Host "Dev token local: $devTokenValue"
Write-Host "Use o endereco acima; portas abertas pelo Run do Android Studio/VS Code podem ficar sem os dart-defines."

flutter @flutterArgs
