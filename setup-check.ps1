# 클로드코드 2차 — 점검 · 설치 · 자료 받기 (Windows / PowerShell)
# 사용:  irm "https://raw.githubusercontent.com/jurisupport/claudecode-songmu-seminar2/main/setup-check.ps1?cache=20260616" | iex

try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

$bootstrap = 'https://raw.githubusercontent.com/jurisupport/jurisupport-plugins/main/windows-bootstrap.ps1'
$legalTerminalInstaller = 'https://raw.githubusercontent.com/jurisupport/legal-terminal/main/install.ps1'
$guide     = 'https://github.com/jurisupport/jurisupport-plugins'
$legalTerminalGuide = 'https://github.com/jurisupport/legal-terminal'
$nativeGuide = 'https://github.com/jurisupport/jurisupport-plugins/blob/main/WINDOWS_NATIVE.md'
$supportGuide = 'https://github.com/jurisupport/jurisupport-plugins/blob/main/SUPPORT_REPORTS.md'
$wslGuide = 'https://github.com/jurisupport/jurisupport-plugins/blob/main/WINDOWS_WSL.md'
$repoUrl   = 'https://github.com/jurisupport/claudecode-songmu-seminar2.git'
$archiveUrl = 'https://github.com/jurisupport/claudecode-songmu-seminar2/archive/refs/heads/main.zip'
$dest      = Join-Path $HOME 'Downloads\클로드코드2차자료'
$practiceDir = Join-Path $dest '실습사건_세션1_대여금'
$self      = 'irm "https://raw.githubusercontent.com/jurisupport/claudecode-songmu-seminar2/main/setup-check.ps1?cache=20260616" | iex'

function Has-Plugins {
  (Get-JuriSupportPluginsHealth).Complete
}

function Has-LegalTerminal {
  (Get-LegalTerminalInstallInfo).Installed
}

function Get-LegalTerminalPath {
  $candidates = @(
    "$env:LOCALAPPDATA\Programs\legal-terminal\legal-terminal.exe",
    "$env:LOCALAPPDATA\legal-terminal\legal-terminal.exe",
    "$HOME\AppData\Local\Programs\legal-terminal\legal-terminal.exe",
    "$HOME\AppData\Local\legal-terminal\legal-terminal.exe",
    "$env:ProgramFiles\legal-terminal\legal-terminal.exe",
    "${env:ProgramFiles(x86)}\legal-terminal\legal-terminal.exe",
    "$HOME\Desktop\legal-terminal-portable.exe",
    "$HOME\Downloads\legal-terminal-portable.exe"
  ) | Where-Object { $_ }

  foreach ($candidate in $candidates) {
    if (Test-Path $candidate) { return $candidate }
  }

  $shortcutCandidates = @(
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\legal-terminal.lnk",
    "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\legal-terminal.lnk"
  ) | Where-Object { $_ }

  foreach ($candidate in $shortcutCandidates) {
    if (Test-Path $candidate) { return $candidate }
  }

  $searchRoots = @(
    "$env:LOCALAPPDATA\Programs",
    "$env:LOCALAPPDATA",
    "$HOME\Downloads",
    "$HOME\Desktop"
  ) | Where-Object { $_ -and (Test-Path $_) }

  foreach ($root in $searchRoots) {
    try {
      $match = Get-ChildItem -LiteralPath $root -Filter 'legal-terminal.exe' -File -Recurse -Depth 3 -ErrorAction SilentlyContinue |
        Select-Object -First 1
      if ($match -and $match.FullName) { return $match.FullName }
    } catch {}
  }

  return $null
}

function ConvertTo-ExePath {
  param([AllowNull()][string]$Value)
  if (-not $Value) { return $null }
  $path = $Value.Trim().Trim('"')
  if ($path -match '^(.*?\.exe)') { $path = $matches[1] }
  $path = $path.Trim('"')
  if ($path -and (Test-Path -LiteralPath $path)) { return $path }
  return $null
}

function Get-LegalTerminalRegistryEntry {
  $roots = @(
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
  )

  foreach ($root in $roots) {
    try {
      $entry = Get-ItemProperty $root -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -match '(?i)legal[- ]?terminal' } |
        Select-Object -First 1
      if ($entry) { return $entry }
    } catch {}
  }

  return $null
}

function Get-LegalTerminalInstallInfo {
  $path = Get-LegalTerminalPath
  if ($path) {
    return [pscustomobject]@{
      Installed = $true
      Path = $path
      Version = $null
      Source = 'path'
    }
  }

  $entry = Get-LegalTerminalRegistryEntry
  if ($entry) {
    $registryPath = ConvertTo-ExePath $entry.DisplayIcon
    if ((-not $registryPath) -and $entry.InstallLocation) {
      $registryPath = ConvertTo-ExePath (Join-Path $entry.InstallLocation 'legal-terminal.exe')
    }

    return [pscustomobject]@{
      Installed = $true
      Path = $registryPath
      Version = $entry.DisplayVersion
      Source = 'registry'
    }
  }

  [pscustomobject]@{
    Installed = $false
    Path = $null
    Version = $null
    Source = $null
  }
}

function ConvertTo-ComparableVersion {
  param([AllowNull()][string]$Value)
  if (-not $Value) { return $null }
  $clean = $Value.Trim()
  if ($clean.StartsWith('v')) { $clean = $clean.Substring(1) }
  return $clean
}

function Get-NpmCommand {
  foreach ($name in @('npm.cmd', 'npm.exe', 'npm')) {
    $cmd = Get-Command $name -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($cmd -and $cmd.Source) { return $cmd.Source }
  }
  return $null
}

function Get-ClaudeCommand {
  foreach ($name in @('claude.cmd', 'claude.exe', 'claude')) {
    $cmd = Get-Command $name -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($cmd -and $cmd.Source) { return $cmd.Source }
  }
  return $null
}

function Get-JuriSupportPluginsHealth {
  $repoDir = Join-Path $HOME 'jurisupport-plugins'
  $missing = New-Object System.Collections.Generic.List[string]

  if (-not (Test-Path -LiteralPath (Join-Path $repoDir 'install.sh') -PathType Leaf)) {
    $missing.Add('repo/install.sh') | Out-Null
  }
  if (-not (Test-Path -LiteralPath (Join-Path $repoDir 'plugins\jurisupport\.claude-plugin\plugin.json') -PathType Leaf)) {
    $missing.Add('plugin manifest') | Out-Null
  }

  $skillRoots = @(
    [pscustomobject]@{ Label = '.claude'; Path = (Join-Path $HOME '.claude\skills') },
    [pscustomobject]@{ Label = '.codex'; Path = (Join-Path $HOME '.codex\skills') }
  )

  foreach ($skillsRoot in $skillRoots) {
    foreach ($skill in @('lbox-guide', 'beopgoeul-search')) {
      $skillFile = Join-Path (Join-Path $skillsRoot.Path $skill) 'SKILL.md'
      if (-not (Test-Path -LiteralPath $skillFile -PathType Leaf)) {
        $missing.Add("$($skillsRoot.Label) $skill skill") | Out-Null
      }
    }
  }

  $commandFile = Join-Path $HOME '.claude\commands\beopgoeul-search.md'
  if (-not (Test-Path -LiteralPath $commandFile -PathType Leaf)) {
    $missing.Add('beopgoeul command') | Out-Null
  }

  $claude = Get-ClaudeCommand
  if ($claude) {
    $pluginList = $null
    try { $pluginList = (& $claude plugin list 2>$null | Out-String) } catch {}
    if ((-not $pluginList) -or ($pluginList -notmatch '(?im)^\s*(?:\S+\s+)?jurisupport(@|\s|$)')) {
      $missing.Add('Claude plugin jurisupport') | Out-Null
    }

    $marketplaceList = $null
    try { $marketplaceList = (& $claude plugin marketplace list 2>$null | Out-String) } catch {}
    if ((-not $marketplaceList) -or ($marketplaceList -notmatch '(?i)jurisupport-plugins')) {
      $missing.Add('Claude marketplace jurisupport-plugins') | Out-Null
    }
  } else {
    $missing.Add('Claude Code CLI') | Out-Null
  }

  $present = (Test-Path -LiteralPath $repoDir -PathType Container) -or
    (Test-Path -LiteralPath (Join-Path $HOME '.claude\skills\lbox-guide') -PathType Container) -or
    (Test-Path -LiteralPath (Join-Path $HOME '.claude\skills\beopgoeul-search') -PathType Container) -or
    (Test-Path -LiteralPath (Join-Path $HOME '.codex\skills\lbox-guide') -PathType Container) -or
    (Test-Path -LiteralPath (Join-Path $HOME '.codex\skills\beopgoeul-search') -PathType Container)

  [pscustomobject]@{
    Present = $present
    Complete = ($missing.Count -eq 0)
    Missing = @($missing.ToArray())
  }
}

function Get-ClaudeStatus {
  $installed = [bool](Get-ClaudeCommand)
  $current = $null
  $latest = $null

  $npm = Get-NpmCommand
  if ($npm) {
    try {
      $listText = (& $npm list -g '@anthropic-ai/claude-code' --depth=0 2>$null | Out-String)
      if ($listText -match '@anthropic-ai/claude-code@([0-9][^\s]*)') {
        $current = $matches[1]
      }
    } catch {}

    try {
      $latestText = (& $npm view '@anthropic-ai/claude-code' version 2>$null | Out-String).Trim()
      if ($latestText) { $latest = $latestText }
    } catch {}
  }

  $needsUpdate = $false
  if ($current -and $latest) {
    $needsUpdate = ((ConvertTo-ComparableVersion $current) -ne (ConvertTo-ComparableVersion $latest))
  }

  [pscustomobject]@{
    Installed = $installed
    Current = $current
    Latest = $latest
    NeedsUpdate = $needsUpdate
  }
}

function Get-JuriSupportPluginsStatus {
  $health = Get-JuriSupportPluginsHealth
  $repoDir = Join-Path $HOME 'jurisupport-plugins'
  $current = $null
  $latest = $null
  $needsUpdate = $false

  if ((Test-Path (Join-Path $repoDir '.git')) -and (Get-Command git -ErrorAction SilentlyContinue)) {
    try {
      $current = (& git -C $repoDir rev-parse HEAD 2>$null | Out-String).Trim()
    } catch {}

    try {
      $remoteLine = (& git -C $repoDir ls-remote origin refs/heads/main 2>$null | Select-Object -First 1)
      if ($remoteLine -match '^([0-9a-fA-F]{40})') { $latest = $matches[1] }
    } catch {}

    if ($current -and $latest) { $needsUpdate = ($current -ne $latest) }
  }

  [pscustomobject]@{
    Installed = $health.Present
    Complete = $health.Complete
    Missing = $health.Missing
    Current = $current
    Latest = $latest
    NeedsUpdate = $needsUpdate
  }
}

function Get-LegalTerminalStatus {
  $info = Get-LegalTerminalInstallInfo
  $path = $info.Path
  $installed = $info.Installed
  $current = $info.Version
  $latest = $null
  $needsUpdate = $false

  if ($path -and ($path -like '*.exe')) {
    try {
      $versionInfo = (Get-Item -LiteralPath $path).VersionInfo
      if ($versionInfo.ProductVersion) { $current = $versionInfo.ProductVersion }
      elseif ($versionInfo.FileVersion) { $current = $versionInfo.FileVersion }
    } catch {}
  }

  try {
    $release = Invoke-RestMethod -Uri 'https://api.github.com/repos/jurisupport/legal-terminal/releases/latest' -ErrorAction Stop
    if ($release.tag_name) { $latest = $release.tag_name }
  } catch {}

  if ($current -and $latest) {
    $needsUpdate = ((ConvertTo-ComparableVersion $current) -ne (ConvertTo-ComparableVersion $latest))
  }

  [pscustomobject]@{
    Installed = $installed
    Current = $current
    Latest = $latest
    NeedsUpdate = $needsUpdate
    Path = $path
    Source = $info.Source
  }
}

function Format-ShortRef {
  param([AllowNull()][string]$Value)
  if (-not $Value) { return $null }
  if ($Value.Length -gt 12) { return $Value.Substring(0, 12) }
  return $Value
}

function Write-InstallStatus {
  param(
    [string]$Name,
    [object]$Status
  )

  if (-not $Status.Installed) {
    if ($Status.PSObject.Properties['Missing'] -and $Status.Missing) {
      Write-Host "  [--] $Name 미설치/불완전 (누락: $($Status.Missing -join ', '))"
    } else {
      Write-Host "  [--] $Name 미설치"
    }
    return
  }

  $isIncomplete = $false
  if ($Status.PSObject.Properties['Complete']) { $isIncomplete = -not $Status.Complete }
  $mark = if ($Status.NeedsUpdate -or $isIncomplete) { '[!!]' } else { '[OK]' }
  $parts = @()
  if ($isIncomplete) {
    $parts += '불완전'
    if ($Status.Missing) {
      $parts += "누락: $($Status.Missing -join ', ')"
    }
  }
  if ($Status.Current) { $parts += "현재 $(Format-ShortRef $Status.Current)" }
  if ($Status.Latest) { $parts += "최신 $(Format-ShortRef $Status.Latest)" }
  if ($Status.NeedsUpdate) { $parts += '업데이트 필요' }
  elseif ((-not $isIncomplete) -and $Status.Current -and $Status.Latest) { $parts += '최신 상태' }
  elseif ((-not $Status.Current) -and $Status.Latest) { $parts += '현재 버전 확인 불가' }
  elseif ($Status.Current -and (-not $Status.Latest)) { $parts += '최신 버전 확인 불가' }
  if (($parts.Count -eq 0) -and $Status.Installed) { $parts += '버전 확인 불가' }

  Write-Host "  $mark $Name ($($parts -join ', '))"
}

function Test-CoreInstallComplete {
  param([string]$ActionName)

  $afterClaude = Get-ClaudeStatus
  $afterPlugins = Get-JuriSupportPluginsStatus
  if ($afterClaude.Installed -and $afterPlugins.Complete) { return $true }

  Write-Host ""
  Write-Host "  $ActionName 후 점검에서 누락을 발견했습니다."
  if (-not $afterClaude.Installed) {
    Write-Host "    - Claude Code CLI"
  }
  if (-not $afterPlugins.Complete) {
    foreach ($item in $afterPlugins.Missing) {
      Write-Host "    - $item"
    }
  }
  return $false
}

function Test-LegalTerminalInstallComplete {
  param([string]$ActionName)

  $afterLegalTerminal = Get-LegalTerminalStatus
  if ($afterLegalTerminal.Installed -and (-not $afterLegalTerminal.NeedsUpdate)) { return $true }

  Write-Host ""
  Write-Host "  legal-terminal $ActionName 후 점검에서 문제가 발견됐습니다."
  if (-not $afterLegalTerminal.Installed) {
    Write-Host "    - legal-terminal 앱이 감지되지 않음"
  } elseif ($afterLegalTerminal.NeedsUpdate) {
    Write-Host "    - legal-terminal 최신 버전 아님"
  }
  return $false
}

function Repair-JuriSupportPluginsFromRepo {
  $repoDir = Join-Path $HOME 'jurisupport-plugins'
  $installSh = Join-Path $repoDir 'install.sh'
  $manifest = Join-Path $repoDir 'plugins\jurisupport\.claude-plugin\plugin.json'

  if ((Get-JuriSupportPluginsHealth).Complete) { return $true }
  if ((-not (Test-Path -LiteralPath $installSh -PathType Leaf)) -or
    (-not (Test-Path -LiteralPath $manifest -PathType Leaf))) {
    return $false
  }

  Write-Host ""
  Write-Host "  jurisupport-plugins 저장소는 있으나 일부 구성이 빠져 있어 직접 복구합니다..."

  $ok = $true
  foreach ($skillsRoot in @((Join-Path $HOME '.claude\skills'), (Join-Path $HOME '.codex\skills'))) {
    foreach ($skill in @('lbox-guide', 'beopgoeul-search')) {
      $source = Join-Path (Join-Path $repoDir "skills\$skill") 'SKILL.md'
      $targetDir = Join-Path $skillsRoot $skill
      $target = Join-Path $targetDir 'SKILL.md'
      try {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        Copy-Item -LiteralPath $source -Destination $target -Force -ErrorAction Stop
        Write-Host "    - 스킬 복구: $skill"
      } catch {
        Write-Host "    - 스킬 복구 실패: $skill ($($_.Exception.Message))"
        $ok = $false
      }
    }
  }

  try {
    $commandsDir = Join-Path $HOME '.claude\commands'
    $commandSource = Join-Path $repoDir 'skills\beopgoeul-search\SKILL.md'
    $commandTarget = Join-Path $commandsDir 'beopgoeul-search.md'
    New-Item -ItemType Directory -Path $commandsDir -Force | Out-Null
    Copy-Item -LiteralPath $commandSource -Destination $commandTarget -Force -ErrorAction Stop
    Write-Host "    - 명령 복구: beopgoeul-search"
  } catch {
    Write-Host "    - 명령 복구 실패: beopgoeul-search ($($_.Exception.Message))"
    $ok = $false
  }

  $claude = Get-ClaudeCommand
  if (-not $claude) {
    Write-Host "    - Claude Code CLI를 찾지 못해 플러그인 등록을 복구하지 못했습니다."
    return $false
  }

  try {
    $marketplaceList = (& $claude plugin marketplace list 2>$null | Out-String)
    if ($marketplaceList -notmatch '(?i)jurisupport-plugins') {
      Write-Host "    - Claude marketplace 등록: jurisupport-plugins"
      & $claude plugin marketplace add $repoDir
      if ($LASTEXITCODE -ne 0) { $ok = $false }
    }
  } catch {
    Write-Host "    - Claude marketplace 확인/등록 실패: $($_.Exception.Message)"
    $ok = $false
  }

  try {
    $pluginList = (& $claude plugin list 2>$null | Out-String)
    if ($pluginList -notmatch '(?im)^\s*(?:\S+\s+)?jurisupport(@|\s|$)') {
      Write-Host "    - Claude plugin 설치: jurisupport"
      & $claude plugin install jurisupport@jurisupport-plugins
      if ($LASTEXITCODE -ne 0) { $ok = $false }
    }
  } catch {
    Write-Host "    - Claude plugin 확인/설치 실패: $($_.Exception.Message)"
    $ok = $false
  }

  return ($ok -and (Get-JuriSupportPluginsHealth).Complete)
}

function Get-Materials {
  $parent = Split-Path $dest -Parent
  New-Item -ItemType Directory -Path $parent -Force | Out-Null
  if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }

  if (Get-Command git -ErrorAction SilentlyContinue) {
    git clone --depth 1 $repoUrl $dest 2>$null | Out-Null
    if (($LASTEXITCODE -eq 0) -and (Test-Path $dest)) {
      $gitdir = Join-Path $dest '.git'
      if (Test-Path $gitdir) { Remove-Item $gitdir -Recurse -Force -ErrorAction SilentlyContinue }
      return $true
    }
    if (Test-Path $dest) { Remove-Item $dest -Recurse -Force -ErrorAction SilentlyContinue }
  }

  $tmpRoot = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid().ToString())
  $zipPath = Join-Path $tmpRoot 'materials.zip'
  try {
    New-Item -ItemType Directory -Path $tmpRoot -Force -ErrorAction Stop | Out-Null
    Invoke-WebRequest -Uri $archiveUrl -OutFile $zipPath -UseBasicParsing -ErrorAction Stop
    Expand-Archive -LiteralPath $zipPath -DestinationPath $tmpRoot -Force -ErrorAction Stop
    $expanded = Join-Path $tmpRoot 'claudecode-songmu-seminar2-main'
    if (-not (Test-Path $expanded)) { return $false }
    Move-Item -LiteralPath $expanded -Destination $dest -ErrorAction Stop
    return (Test-Path $dest)
  } catch {
    return $false
  } finally {
    if (Test-Path $tmpRoot) { Remove-Item $tmpRoot -Recurse -Force -ErrorAction SilentlyContinue }
  }
}

function Get-PowerShellExe {
  $cmd = Get-Command powershell.exe -ErrorAction SilentlyContinue
  if ($cmd -and $cmd.Source) { return $cmd.Source }

  $cmd = Get-Command pwsh.exe -ErrorAction SilentlyContinue
  if ($cmd -and $cmd.Source) { return $cmd.Source }

  return $null
}

function Get-NoCacheHeaders {
  @{
    'Cache-Control' = 'no-cache'
    'Pragma' = 'no-cache'
  }
}

function Show-WindowsInstallHelp {
  Write-Host ""
  Write-Host "  Windows 보안 설정으로 설치가 막힐 때:"
  Write-Host "    1) 새 PowerShell 창을 열고 아래 4줄로 로컬 파일 실행을 시도하세요:"
  Write-Host "       `$p = `"`$env:TEMP\claudecode2-setup-check.ps1`""
  Write-Host "       iwr `"https://raw.githubusercontent.com/jurisupport/claudecode-songmu-seminar2/main/setup-check.ps1?cache=20260616`" -OutFile `$p -UseBasicParsing"
  Write-Host "       Unblock-File `$p"
  Write-Host "       powershell.exe -NoProfile -ExecutionPolicy Bypass -NoExit -File `$p"
  Write-Host ""
  Write-Host "    2) 위 스크립트에서 설치 질문이 나오면 S(보안/진단 모드)를 선택하세요."
  Write-Host "       실패해도 Desktop에 진단 ZIP이 남습니다. 자동 업로드는 끕니다."
  Write-Host ""
  Write-Host "    3) 회사 정책이 winget/PowerShell 실행을 막으면 자료만 받은 뒤 수동 설치 가이드를 따르세요:"
  Write-Host "       $nativeGuide"
  Write-Host "       $supportGuide"
  Write-Host "       $wslGuide"
  Write-Host "       $legalTerminalGuide"
}

function Invoke-PluginBootstrap {
  param([switch]$SupportMode)

  $psExe = Get-PowerShellExe
  if (-not $psExe) {
    Write-Host "  PowerShell 실행 파일을 찾지 못했습니다."
    return $false
  }

  $tmp = Join-Path ([System.IO.Path]::GetTempPath()) "jurisupport-bootstrap-$([System.Guid]::NewGuid().ToString('N')).ps1"
  try {
    Write-Host "  설치 스크립트를 로컬 임시 파일로 내려받습니다..."
    Invoke-WebRequest -Uri $bootstrap -OutFile $tmp -UseBasicParsing -Headers (Get-NoCacheHeaders) -ErrorAction Stop
    try { Unblock-File -LiteralPath $tmp -ErrorAction SilentlyContinue } catch {}

    $oldReport = $env:JURISUPPORT_SUPPORT_REPORT
    $oldUpload = $env:JURISUPPORT_SUPPORT_UPLOAD_URL
    if ($SupportMode) {
      $env:JURISUPPORT_SUPPORT_REPORT = '1'
      $env:JURISUPPORT_SUPPORT_UPLOAD_URL = 'off'
      Write-Host "  보안/진단 모드: 실패 시 Desktop에 진단 ZIP을 만들고 자동 업로드는 하지 않습니다."
    }

    try {
      & $psExe -NoProfile -ExecutionPolicy Bypass -File $tmp
      return ($LASTEXITCODE -eq 0)
    } finally {
      if ($null -eq $oldReport) { Remove-Item Env:\JURISUPPORT_SUPPORT_REPORT -ErrorAction SilentlyContinue } else { $env:JURISUPPORT_SUPPORT_REPORT = $oldReport }
      if ($null -eq $oldUpload) { Remove-Item Env:\JURISUPPORT_SUPPORT_UPLOAD_URL -ErrorAction SilentlyContinue } else { $env:JURISUPPORT_SUPPORT_UPLOAD_URL = $oldUpload }
    }
  } catch {
    Write-Host "  설치 스크립트 준비 실패: $($_.Exception.Message)"
    return $false
  } finally {
    if (Test-Path $tmp) { Remove-Item $tmp -Force -ErrorAction SilentlyContinue }
  }
}

function Invoke-LegalTerminalInstall {
  $psExe = Get-PowerShellExe
  if (-not $psExe) {
    Write-Host "  PowerShell 실행 파일을 찾지 못했습니다."
    return $false
  }

  $tmp = Join-Path ([System.IO.Path]::GetTempPath()) "legal-terminal-install-$([System.Guid]::NewGuid().ToString('N')).ps1"
  try {
    Write-Host "  legal-terminal 설치 스크립트를 로컬 임시 파일로 내려받습니다..."
    Invoke-WebRequest -Uri $legalTerminalInstaller -OutFile $tmp -UseBasicParsing -Headers (Get-NoCacheHeaders) -ErrorAction Stop
    try { Unblock-File -LiteralPath $tmp -ErrorAction SilentlyContinue } catch {}

    & $psExe -NoProfile -ExecutionPolicy Bypass -File $tmp
    return ($LASTEXITCODE -eq 0)
  } catch {
    Write-Host "  legal-terminal 설치 실패: $($_.Exception.Message)"
    Write-Host "  수동 설치 안내: $legalTerminalGuide"
    return $false
  } finally {
    if (Test-Path $tmp) { Remove-Item $tmp -Force -ErrorAction SilentlyContinue }
  }
}

Write-Host "========================================"
Write-Host "  클로드코드 2차 - 점검 · 설치 · 자료 받기"
Write-Host "========================================"

$claudeStatus = Get-ClaudeStatus
$pluginsStatus = Get-JuriSupportPluginsStatus
$legalTerminalStatus = Get-LegalTerminalStatus
Write-InstallStatus 'Claude Code' $claudeStatus
Write-InstallStatus 'jurisupport-plugins' $pluginsStatus
Write-InstallStatus 'legal-terminal' $legalTerminalStatus
Write-Host "----------------------------------------"

$skipToolInstall = $false

$needsCoreInstall = -not ($claudeStatus.Installed -and $pluginsStatus.Complete)
$needsCoreUpdate = ($claudeStatus.NeedsUpdate -or $pluginsStatus.NeedsUpdate)

if ($needsCoreInstall) {
  Write-Host "  설치 안내: $guide"
  Write-Host ""
  Write-Host "  선택:"
  Write-Host "    Y = Claude Code + 플러그인 자동 설치 (기본값)"
  Write-Host "    S = 보안/진단 모드 설치 (실패 시 Desktop 진단 ZIP, 자동 업로드 없음)"
  Write-Host "    N = 도구 설치 건너뛰고 강의 자료만 받기"
  $ans = (Read-Host "  Claude Code + 플러그인을 설치할까요? (Y/S/N, Enter=설치)").Trim()
  if (($ans -eq '') -or ($ans -match '^[yY]')) {
    Write-Host ""
    Write-Host "  설치를 시작합니다... (약 15분, UAC 팝업이 뜨면 '예')"
    Set-ExecutionPolicy Bypass -Scope Process -Force
    $null = Invoke-PluginBootstrap
    $null = Repair-JuriSupportPluginsFromRepo
    $verifyOk = Test-CoreInstallComplete '설치'
    if (-not $verifyOk) {
      Write-Host ""
      Write-Host "  설치가 완료되지 않았습니다. 그래도 강의 자료는 계속 받습니다."
      Show-WindowsInstallHelp
    }
  } elseif ($ans -match '^[sS]') {
    Write-Host ""
    Write-Host "  보안/진단 모드로 설치를 시작합니다... (약 15분, UAC 팝업이 뜨면 '예')"
    Set-ExecutionPolicy Bypass -Scope Process -Force
    $null = Invoke-PluginBootstrap -SupportMode
    $null = Repair-JuriSupportPluginsFromRepo
    $verifyOk = Test-CoreInstallComplete '설치'
    if (-not $verifyOk) {
      Write-Host ""
      Write-Host "  설치가 완료되지 않았습니다. 그래도 강의 자료는 계속 받습니다."
      Show-WindowsInstallHelp
    }
  } else {
    Write-Host ""
    Write-Host "  도구 설치는 건너뛰고 강의 자료만 받습니다."
    $skipToolInstall = $true
    Show-WindowsInstallHelp
  }
} elseif ($needsCoreUpdate) {
  Write-Host ""
  Write-Host "  Claude Code 또는 jurisupport-plugins 업데이트가 필요합니다."
  Write-Host "  선택:"
  Write-Host "    Y = 최신 버전으로 업데이트 (기본값)"
  Write-Host "    S = 보안/진단 모드 업데이트 (실패 시 Desktop 진단 ZIP, 자동 업로드 없음)"
  Write-Host "    N = 업데이트 건너뛰기"
  $ans = (Read-Host "  지금 업데이트할까요? (Y/S/N, Enter=업데이트)").Trim()
  if (($ans -eq '') -or ($ans -match '^[yY]')) {
    Write-Host ""
    Write-Host "  업데이트를 시작합니다..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    $null = Invoke-PluginBootstrap
    $null = Repair-JuriSupportPluginsFromRepo
    $verifyOk = Test-CoreInstallComplete '업데이트'
    if (-not $verifyOk) {
      Write-Host ""
      Write-Host "  업데이트가 완료되지 않았습니다. 그래도 강의 자료는 계속 받습니다."
      Show-WindowsInstallHelp
    }
  } elseif ($ans -match '^[sS]') {
    Write-Host ""
    Write-Host "  보안/진단 모드로 업데이트를 시작합니다..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    $null = Invoke-PluginBootstrap -SupportMode
    $null = Repair-JuriSupportPluginsFromRepo
    $verifyOk = Test-CoreInstallComplete '업데이트'
    if (-not $verifyOk) {
      Write-Host ""
      Write-Host "  업데이트가 완료되지 않았습니다. 그래도 강의 자료는 계속 받습니다."
      Show-WindowsInstallHelp
    }
  } else {
    Write-Host "  업데이트는 건너뜁니다."
  }
}

$legalTerminalStatus = Get-LegalTerminalStatus
if ((-not $legalTerminalStatus.Installed) -and (-not $skipToolInstall)) {
  Write-Host ""
  Write-Host "  legal-terminal 설치 안내: $legalTerminalGuide"
  $ltAns = (Read-Host "  legal-terminal 앱을 설치할까요? (Y/n, Enter=설치)").Trim()
  if (($ltAns -eq '') -or ($ltAns -match '^[yY]')) {
    $legalTerminalInstallOk = Invoke-LegalTerminalInstall
    $legalTerminalVerifyOk = Test-LegalTerminalInstallComplete '설치'
    if (-not ($legalTerminalInstallOk -and $legalTerminalVerifyOk)) {
      Write-Host "  legal-terminal 설치가 완료되지 않았습니다. 그래도 강의 자료는 계속 받습니다."
    }
  } else {
    Write-Host "  legal-terminal 설치는 건너뜁니다."
  }
} elseif ($legalTerminalStatus.NeedsUpdate -and (-not $skipToolInstall)) {
  Write-Host ""
  Write-Host "  legal-terminal 업데이트가 필요합니다."
  $ltAns = (Read-Host "  legal-terminal 앱을 최신 버전으로 업데이트할까요? (Y/n, Enter=업데이트)").Trim()
  if (($ltAns -eq '') -or ($ltAns -match '^[yY]')) {
    $legalTerminalInstallOk = Invoke-LegalTerminalInstall
    $legalTerminalVerifyOk = Test-LegalTerminalInstallComplete '업데이트'
    if (-not ($legalTerminalInstallOk -and $legalTerminalVerifyOk)) {
      Write-Host "  legal-terminal 업데이트가 완료되지 않았습니다. 그래도 강의 자료는 계속 받습니다."
    }
  } else {
    Write-Host "  legal-terminal 업데이트는 건너뜁니다."
  }
}

Write-Host ""
Write-Host "  강의 자료를 받습니다..."
if (Get-Materials) {
  Write-Host ""
  Write-Host "  완료 -> $dest"
  Write-Host ""
  if (Test-Path $practiceDir) {
    Set-Location -LiteralPath $practiceDir
    Write-Host "  현재 위치를 실습 폴더로 이동했습니다:"
    Write-Host "      $practiceDir"
    Write-Host ""
    Write-Host "  실습을 시작하려면 아래를 실행하세요:"
    Write-Host "      claude.cmd"
  } else {
    Write-Host "  실습 폴더를 찾지 못했습니다. 직접 이동해 주세요:"
    Write-Host "      cd `"$practiceDir`"; claude.cmd"
  }
  # 받은 폴더를 탐색기로 열기 (Invoke-Item이 가장 안정적, 안 되면 explorer 폴백)
  try { Invoke-Item -LiteralPath $practiceDir } catch { try { explorer.exe $dest } catch {} }
} else {
  Write-Host ""
  Write-Host "  자료를 받지 못했습니다. (방금 설치하셨다면 PATH 적용을 위해)"
  Write-Host "  '새 PowerShell 창'을 열고 아래 한 줄을 다시 실행해 보세요:"
  Write-Host "      $self"
}
