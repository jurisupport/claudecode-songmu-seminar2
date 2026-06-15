# Windows 설치가 보안 설정으로 막힐 때

회사 PC나 보안 프로그램이 있는 Windows에서는 PowerShell 한 줄 설치가 막힐 수 있습니다. 강의 자료는 플러그인 설치와 별도로 받을 수 있으니, 설치가 막혀도 먼저 자료를 받아 강의를 따라오면 됩니다.

## 1. 먼저 자료만 받기

README의 Windows 한 줄을 실행했을 때 설치 질문이 나오면 `N`을 누르세요. 플러그인 설치를 건너뛰고 `Downloads\클로드코드2차자료`에 강의 자료만 받습니다.

## 2. 한 줄 실행 자체가 막히는 경우

`irm ... | iex`가 차단되면 새 PowerShell 창에서 아래 4줄을 실행하세요.

```powershell
$p = "$env:TEMP\claudecode2-setup-check.ps1"
iwr "https://raw.githubusercontent.com/jurisupport/claudecode-songmu-seminar2/main/setup-check.ps1?cache=d56081a" -OutFile $p -UseBasicParsing
Unblock-File $p
powershell.exe -NoProfile -ExecutionPolicy Bypass -NoExit -File $p
```

스크립트가 열리면 선택지에서 `S`를 고르세요. 보안/진단 모드는 jurisupport-plugins의 Windows bootstrap을 로컬 임시 파일로 내려받아 실행하고, 실패 시 Desktop에 진단 ZIP을 남깁니다. 자동 업로드는 꺼 둡니다.

## 3. 설치 도중 멈추는 경우

Windows 설치는 `winget`과 UAC 팝업을 사용합니다. 화면이 멈춘 것처럼 보이면 작업 표시줄의 노란 방패 아이콘이나 뒤에 가려진 UAC 창을 확인하고 `예`를 누르세요.

그래도 실패하면 아래 진단 모드만 직접 실행할 수 있습니다.

```powershell
$env:JURISUPPORT_SUPPORT_REPORT = "1"
$env:JURISUPPORT_SUPPORT_UPLOAD_URL = "off"
$p = "$env:TEMP\jurisupport-windows-bootstrap.ps1"
iwr https://raw.githubusercontent.com/jurisupport/jurisupport-plugins/main/windows-bootstrap.ps1 -OutFile $p -UseBasicParsing
Unblock-File $p
powershell.exe -NoProfile -ExecutionPolicy Bypass -File $p
```

생성되는 `jurisupport-install-report-*.zip`에는 Windows 버전, PowerShell 실행 정책, winget/Git/Node/npm/Python/Claude Code 상태, bootstrap 로그가 들어갑니다. 사건자료, Claude 설정 파일, secrets 파일은 넣지 않도록 설계되어 있습니다.

## 4. legal-terminal만 따로 설치해야 하는 경우

플러그인 설치는 끝났는데 legal-terminal 앱 설치만 막히면 공식 설치 파일을 직접 내려받아 실행하세요.

- Windows 설치본: https://github.com/jurisupport/legal-terminal/releases/latest/download/legal-terminal-Setup.exe
- Windows 포터블: https://github.com/jurisupport/legal-terminal/releases/latest/download/legal-terminal-portable.exe
- 설치 가이드: https://github.com/jurisupport/legal-terminal

설치 파일 실행 중 "Windows의 PC 보호" 창이 뜨면 **추가 정보** → **실행**을 누릅니다. 그래도 막히면 받은 `.exe`를 우클릭 → 속성 → **차단 해제** 후 다시 실행합니다.

## 5. 조직 정책이 winget/PowerShell을 막는 경우

사용자 권한으로 해결되지 않을 수 있습니다. 이 경우 다음 중 하나로 진행하세요.

- 강의 당일에는 `N`으로 자료만 받고, 핸드아웃과 슬라이드를 보며 시연을 따라옵니다.
- 사무실 IT 담당자에게 Git, Node.js LTS, Python 3.12, Google Chrome, jq, Git Bash, Claude Code, legal-terminal 설치 허용을 요청합니다.
- WSL2가 허용되는 PC라면 jurisupport-plugins의 WSL2 경로를 사용합니다.

공식 가이드:

- Windows 네이티브: https://github.com/jurisupport/jurisupport-plugins/blob/main/WINDOWS_NATIVE.md
- 진단 리포트: https://github.com/jurisupport/jurisupport-plugins/blob/main/SUPPORT_REPORTS.md
- WSL2 대안: https://github.com/jurisupport/jurisupport-plugins/blob/main/WINDOWS_WSL.md
