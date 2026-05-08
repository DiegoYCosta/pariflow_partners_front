param(
  [string]$DeviceId,
  [string]$ApiBaseUrl = "http://3.18.213.49/api/v1"
)

$ErrorActionPreference = "Stop"

$args = @(
  'run',
  "--dart-define=PARIFLOW_API_BASE_URL=$ApiBaseUrl",
  '--dart-define=PARIFLOW_ENABLE_DEV_TOKEN=false'
)

if ($DeviceId -and $DeviceId.Trim().Length -gt 0) {
  $args += @('-d', $DeviceId)
}

flutter @args
