# 클로드코드 2차 — 점검 · 설치 · 자료 받기 (Windows / PowerShell)
# 사용:  irm https://raw.githubusercontent.com/jurisupport/claudecode-songmu-seminar2/main/setup-check.ps1 | iex

try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

$bootstrap = 'https://raw.githubusercontent.com/jurisupport/jurisupport-plugins/main/windows-bootstrap.ps1'
$guide     = 'https://github.com/jurisupport/jurisupport-plugins'
$repoUrl   = 'https://github.com/jurisupport/claudecode-songmu-seminar2.git'
$dest      = Join-Path $HOME 'Downloads\클로드코드2차자료'
$self      = 'irm https://raw.githubusercontent.com/jurisupport/claudecode-songmu-seminar2/main/setup-check.ps1 | iex'

function Has-Plugins {
  (Test-Path "$HOME\jurisupport-plugins") -or
  (Test-Path "$HOME\.claude\skills\brief-draft") -or
  (Test-Path "$HOME\.claude\skills\beopgoeul-search")
}

function Get-Materials {
  if (-not (Get-Command git -ErrorAction SilentlyContinue)) { return $false }
  if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
  git clone --depth 1 $repoUrl $dest 2>$null | Out-Null
  $gitdir = Join-Path $dest '.git'
  if (Test-Path $gitdir) { Remove-Item $gitdir -Recurse -Force -ErrorAction SilentlyContinue }
  return (Test-Path $dest)
}

Write-Host "========================================"
Write-Host "  클로드코드 2차 - 점검 · 설치 · 자료 받기"
Write-Host "========================================"

$hasClaude  = [bool](Get-Command claude -ErrorAction SilentlyContinue)
$hasPlugins = Has-Plugins
if ($hasClaude)  { Write-Host "  [OK] Claude Code" }          else { Write-Host "  [--] Claude Code 미설치" }
if ($hasPlugins) { Write-Host "  [OK] jurisupport-plugins" }  else { Write-Host "  [--] jurisupport-plugins 미설치" }
Write-Host "----------------------------------------"

if (-not ($hasClaude -and $hasPlugins)) {
  Write-Host "  설치 안내: $guide"
  Write-Host ""
  $ans = Read-Host "  Claude Code + 플러그인을 지금 설치할까요? (y/N)"
  if ($ans -match '^[yY]') {
    Write-Host ""
    Write-Host "  설치를 시작합니다... (약 15분, UAC 팝업이 뜨면 '예')"
    Set-ExecutionPolicy Bypass -Scope Process -Force
    irm $bootstrap | iex
  } else {
    Write-Host ""
    Write-Host "  나중에 설치하시려면 아래 한 줄을 실행하세요:"
    Write-Host "      irm $bootstrap | iex"
    Write-Host "  설치 후 이 명령을 다시 실행하면 강의 자료까지 받습니다."
    return
  }
}

Write-Host ""
Write-Host "  강의 자료를 받습니다..."
if (Get-Materials) {
  Write-Host ""
  Write-Host "  완료 -> $dest"
  Write-Host ""
  Write-Host "  실습을 시작하려면 아래를 붙여넣으세요:"
  Write-Host "      cd `"$dest\실습사건_세션1_대여금`"; claude"
} else {
  Write-Host ""
  Write-Host "  자료를 받으려면 git이 필요합니다. (방금 설치하셨다면 PATH 적용을 위해)"
  Write-Host "  '새 PowerShell 창'을 열고 아래 한 줄을 다시 실행하세요:"
  Write-Host "      $self"
}
