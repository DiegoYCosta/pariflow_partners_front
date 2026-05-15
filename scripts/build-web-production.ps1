param(
  [string]$ApiBaseUrl = "https://pariflowpartners.com.br/api/v1",
  [string]$EnvFile = ".env.front.preview"
)

$ErrorActionPreference = "Stop"

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

$dartDefines = Read-DartDefines -Path $EnvFile
$dartDefines += "--dart-define=PARIFLOW_ENABLE_DEV_TOKEN=false"

if ($ApiBaseUrl -and $ApiBaseUrl.Trim().Length -gt 0) {
  $dartDefines += "--dart-define=PARIFLOW_API_BASE_URL=$ApiBaseUrl"
}

$buildArgs = @(
  'build',
  'web',
  '--release',
  '--no-wasm-dry-run'
) + $dartDefines

flutter @buildArgs
