param(
  [string]$WebPort = "8082",
  [string]$ProxyPort = "3002",
  [string]$ProxyTarget = "http://3.18.213.49"
)

$ErrorActionPreference = "Stop"

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

flutter run `
  -d web-server `
  --web-hostname 127.0.0.1 `
  --web-port $WebPort `
  --dart-define=PARIFLOW_API_BASE_URL=http://127.0.0.1:$ProxyPort/api/v1 `
  --dart-define=PARIFLOW_ENABLE_DEV_TOKEN=true
