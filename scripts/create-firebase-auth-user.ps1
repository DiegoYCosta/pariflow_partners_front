param(
  [Parameter(Mandatory = $true)]
  [string]$Email,

  [Parameter(Mandatory = $true)]
  [SecureString]$Password,

  [string]$EnvFile = ".env.front.preview",
  [switch]$WriteResultFile
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $EnvFile)) {
  throw "Arquivo de ambiente nao encontrado: $EnvFile"
}

$apiKeyLine = Get-Content -LiteralPath $EnvFile |
  Where-Object { $_ -match '^\s*PARIFLOW_FIREBASE_API_KEY\s*=' } |
  Select-Object -First 1

if (-not $apiKeyLine) {
  throw "PARIFLOW_FIREBASE_API_KEY nao encontrado em $EnvFile"
}

$apiKey = ($apiKeyLine -split '=', 2)[1].Trim()
if (-not $apiKey) {
  throw "PARIFLOW_FIREBASE_API_KEY esta vazio em $EnvFile"
}

$bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
try {
  $plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
} finally {
  [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
}

$body = @{
  email = $Email
  password = $plainPassword
  returnSecureToken = $true
} | ConvertTo-Json

try {
  $response = Invoke-RestMethod `
    -Method Post `
    -Uri "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey" `
    -ContentType "application/json" `
    -Body $body
} catch {
  $message = $_.ErrorDetails.Message
  if ($message -match 'OPERATION_NOT_ALLOWED') {
    throw "Email/Password ainda nao esta habilitado no Firebase Console."
  }
  if ($message -match 'EMAIL_EXISTS') {
    throw "Ja existe usuario Firebase com este e-mail."
  }
  throw
} finally {
  $plainPassword = $null
}

$result = [ordered]@{
  email = $Email
  firebaseUid = $response.localId
  createdAt = (Get-Date).ToString("o")
}

if ($WriteResultFile) {
  $outDir = ".local"
  New-Item -ItemType Directory -Force -Path $outDir | Out-Null
  $result | ConvertTo-Json | Set-Content -LiteralPath "$outDir\firebase-user-result.json" -Encoding UTF8
}

Write-Host "Usuario Firebase criado."
Write-Host "Email: $Email"
Write-Host "Firebase UID: $($response.localId)"
Write-Host "A senha nao foi gravada nem exibida."
