param(
  [string]$EnvFile = ".env.front.preview",
  [switch]$Release = $true
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $EnvFile)) {
  throw "Arquivo de ambiente nao encontrado: $EnvFile"
}

$defines = @()
Get-Content -LiteralPath $EnvFile | ForEach-Object {
  $line = $_.Trim()
  if ($line.Length -eq 0 -or $line.StartsWith("#")) {
    return
  }

  $parts = $line -split "=", 2
  if ($parts.Count -ne 2) {
    return
  }

  $key = $parts[0].Trim()
  $value = $parts[1].Trim()
  if ($key.Length -eq 0 -or $value.Length -eq 0) {
    return
  }

  $defines += "--dart-define=$key=$value"
}

$mode = if ($Release) { "--release" } else { "--debug" }
flutter build web $mode @defines
