param(
  [string]$ApiBaseUrl = ""
)

$ErrorActionPreference = "Stop"

$args = @(
  'build',
  'web',
  '--release',
  '--dart-define=PARIFLOW_ENABLE_DEV_TOKEN=false'
)

if ($ApiBaseUrl -and $ApiBaseUrl.Trim().Length -gt 0) {
  $args += "--dart-define=PARIFLOW_API_BASE_URL=$ApiBaseUrl"
}

flutter @args
