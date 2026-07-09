param(
  [string]$WebPort = "8082",
  [string]$ProxyPort = "3002",
  [string]$ProxyTarget = "http://pariflowpartners.com.br",
  [string]$EnvFile = ".env.front.preview",
  [switch]$UseDevToken
)

$ErrorActionPreference = "Stop"

function Test-LocalTarget {
  param([string]$Value)

  $uri = [Uri]$Value
  $hostName = $uri.Host.ToLowerInvariant()
  return $hostName -eq "localhost" -or
    $hostName -eq "127.0.0.1" -or
    $hostName -eq "::1"
}

if ($UseDevToken -and -not (Test-LocalTarget $ProxyTarget)) {
  throw "UseDevToken so e permitido quando ProxyTarget for localhost/127.0.0.1. Para API online, use Firebase real."
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

$proxyCheck = Get-NetTCPConnection -LocalPort $ProxyPort -ErrorAction SilentlyContinue
if (-not $proxyCheck) {
  New-Item -ItemType Directory -Force -Path '.local' | Out-Null
  $proxyOut = Join-Path (Resolve-Path '.local') "dev-api-proxy-$ProxyPort.out.log"
  $proxyErr = Join-Path (Resolve-Path '.local') "dev-api-proxy-$ProxyPort.err.log"
  $env:PARIFLOW_PROXY_TARGET = $ProxyTarget
  $env:PARIFLOW_PROXY_PORT = $ProxyPort
  $env:PARIFLOW_PROXY_HOST = '127.0.0.1'
  $proxyArgs = @('.\scripts\dev-api-proxy.cjs')
  Start-Process -FilePath 'node.exe' -ArgumentList $proxyArgs -WorkingDirectory (Get-Location) -WindowStyle Hidden -RedirectStandardOutput $proxyOut -RedirectStandardError $proxyErr
} else {
  try {
    $proxyStatus = Invoke-RestMethod -Uri "http://127.0.0.1:$ProxyPort/__pariflow_dev_proxy" -TimeoutSec 3
    if ($proxyStatus.target -ne $ProxyTarget) {
      throw "Proxy atual aponta para $($proxyStatus.target), mas este comando pediu $ProxyTarget."
    }
  } catch {
    throw "A porta $ProxyPort ja esta em uso por outro processo ou por um proxy antigo. Encerre esse processo ou informe outra porta com -ProxyPort."
  }
}

for ($i = 0; $i -lt 30; $i++) {
  Start-Sleep -Seconds 1
  try {
    $response = Invoke-WebRequest -Uri "http://127.0.0.1:$ProxyPort/health/ready" -UseBasicParsing -TimeoutSec 3
    if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 500) {
      break
    }
  } catch {}
}

$devTokenValue = if ($UseDevToken) { "true" } else { "false" }
$dartDefines = Read-DartDefines -Path $EnvFile
$dartDefines += "--dart-define=PARIFLOW_API_BASE_URL=http://127.0.0.1:$ProxyPort/api/v1"
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

flutter @flutterArgs
