# 클로드코드 + jurisupport-plugins 설치 확인 (Windows PowerShell)
# 사용:  irm https://raw.githubusercontent.com/jurisupport/claudecode-songmu-seminar2/main/setup-check.ps1 | iex

$bootstrap = 'https://raw.githubusercontent.com/jurisupport/jurisupport-plugins/main/windows-bootstrap.ps1'
$guide     = 'https://github.com/jurisupport/jurisupport-plugins'

Write-Host "----------------------------------------"
Write-Host "  클로드코드 실습 환경 점검"
Write-Host "----------------------------------------"

$need = $false

# 1) Claude Code
if (Get-Command claude -ErrorAction SilentlyContinue) {
  Write-Host "  [O] Claude Code 설치됨"
} else {
  Write-Host "  [X] Claude Code 미설치"
  $need = $true
}

# 2) jurisupport-plugins
if ((Test-Path "$HOME\jurisupport-plugins") -or
    (Test-Path "$HOME\.claude\skills\brief-draft") -or
    (Test-Path "$HOME\.claude\skills\beopgoeul-search")) {
  Write-Host "  [O] jurisupport-plugins 설치됨"
} else {
  Write-Host "  [X] jurisupport-plugins 미설치"
  $need = $true
}

Write-Host "----------------------------------------"

if (-not $need) {
  Write-Host "  준비 완료 - 바로 실습하시면 됩니다."
  return
}

Write-Host "  설치 안내:  $guide"
Write-Host ""
$ans = Read-Host "  지금 자동 설치를 진행할까요? (y/N)"
if ($ans -match '^[yY]') {
  Write-Host ""
  Write-Host "  설치를 시작합니다... (약 15분, 중간에 팝업/입력 있을 수 있음)"
  Write-Host ""
  irm $bootstrap | iex
} else {
  Write-Host ""
  Write-Host "  나중에 설치하시려면 PowerShell에 아래 한 줄을 붙여넣으세요:"
  Write-Host ""
  Write-Host "    irm $bootstrap | iex"
  Write-Host ""
  Write-Host "  자세한 안내: $guide"
}
