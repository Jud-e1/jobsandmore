# Builds the Flutter web app and deploys it to Vercel production
# (https://jobsandmore.vercel.app).
#
# Usage (from anywhere):
#   powershell -ExecutionPolicy Bypass -File tool\deploy_web.ps1
#   powershell -ExecutionPolicy Bypass -File tool\deploy_web.ps1 -SkipTests
#
# Needs: Flutter on PATH (or C:\src\flutter), Node/npx, and a one-time
# `npx vercel login`. The Vercel project link lives in .vercel/project.json
# (git-ignored).
param([switch]$SkipTests)

# 'Continue' so progress text that flutter/vercel print on stderr is not
# treated as a failure in Windows PowerShell 5.1; real failures are caught
# through $LASTEXITCODE below.
$ErrorActionPreference = 'Continue'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$flutter = (Get-Command flutter -ErrorAction SilentlyContinue).Source
if (-not $flutter) { $flutter = 'C:\src\flutter\bin\flutter.bat' }

$link = Join-Path $root '.vercel\project.json'
if (-not (Test-Path $link)) { throw "Missing $link. Run 'npx vercel link --project jobsandmore' in the project folder first." }
$proj = Get-Content $link -Raw | ConvertFrom-Json

if (-not $SkipTests) {
  Write-Host '> Analysing and testing...' -ForegroundColor Cyan
  & $flutter analyze; if ($LASTEXITCODE) { throw 'flutter analyze failed' }
  & $flutter test;    if ($LASTEXITCODE) { throw 'flutter test failed' }
}

Write-Host '> Building web (release)...' -ForegroundColor Cyan
& $flutter build web --release; if ($LASTEXITCODE) { throw 'flutter build web failed' }

Write-Host '> Deploying to Vercel production...' -ForegroundColor Cyan
$env:VERCEL_ORG_ID = $proj.orgId
$env:VERCEL_PROJECT_ID = $proj.projectId
npx --yes vercel@66.2.0 deploy build/web --prod --yes
if ($LASTEXITCODE) { throw 'vercel deploy failed' }

Write-Host '> Live at https://jobsandmore.vercel.app' -ForegroundColor Green
