param(
  [string]$DeviceId = 'android'
)

$ErrorActionPreference = "Stop"

& .\scripts\run-mobile-online.ps1 -DeviceId $DeviceId
