# 클로드코드로 송무하기 — 2차 강의 참여자 자료

> 2026\. 6. 15. 클로드코드 2차 강의 겸 세미나 · 쥬리서포트 · 하희봉 변호사
> 참여하신 변호사님들이 받아 가시는 자료 모음입니다.

## 📦 무엇이 들어 있나

| 폴더 | 내용 | 여는 법 |
|---|---|---|
| `슬라이드/` | 강의 슬라이드 PDF | GitHub에서 바로 보기 / 다운로드 |
| `핸드아웃/` | 강의내용·실습명령어 핸드아웃 (HTML) | **내려받아 브라우저로 열기** |
| `실습사건_세션1_대여금/` | 실습용 **가상사건** 기록 (PDF 13개) | 폴더째 내려받아 사용 |

> ⚠️ 실습사건은 강의용 **가상사건**(김민철 vs 이정숙, 대여금)입니다. 인적사항·금액·계좌·사건번호는 모두 허구이며 실재 인물·사건과 무관합니다.

## ⬇️ 받기 — 한 줄로 (점검 · 설치 · 자료까지)

아래 한 줄이 **Claude Code·jurisupport-plugins·legal-terminal 설치와 최신 여부를 점검하고(안 돼 있거나 오래됐으면 "설치/업데이트하시겠습니까?" 물어봅니다), 강의 자료까지 받습니다.** 자료는 Windows에서는 `Downloads\클로드코드2차자료`, macOS·Linux에서는 `~/Downloads/클로드코드2차자료`에 받아집니다.

**Windows** — PowerShell에:

```powershell
irm "https://raw.githubusercontent.com/jurisupport/claudecode-songmu-seminar2/main/setup-check.ps1?cache=legalproc" | iex
```

**macOS · Linux** — 터미널에:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/jurisupport/claudecode-songmu-seminar2/main/setup-check.sh)
```

- 이미 다 설치돼 있으면 → 점검 후 **자료를 바로 받습니다.**
- 설치되어 있지만 오래됐으면 → Enter 또는 `Y`로 최신 버전 업데이트
- 설치가 필요하면 → Enter 또는 `Y`로 자동 설치, 보안 설정이 빡센 Windows는 `S`로 보안/진단 모드 설치
- legal-terminal도 없으면 → 이어서 Enter 또는 `Y`로 앱 설치
- 설치가 막히거나 시간이 없으면 → `N`으로 **설치 건너뛰고 자료만 받기**
- 설치 안내·수동 설치: **https://github.com/jurisupport/jurisupport-plugins**
- legal-terminal 설치 안내: **https://github.com/jurisupport/legal-terminal**
- Windows 보안 설정으로 막힐 때: [`WINDOWS_INSTALL_HELP.md`](WINDOWS_INSTALL_HELP.md)

### Windows에서 PowerShell 한 줄이 막히면

회사 보안 정책 때문에 `irm ... | iex`가 차단되는 경우, 새 PowerShell 창에서 아래 4줄을 실행하세요.

```powershell
$p = "$env:TEMP\claudecode2-setup-check.ps1"
iwr "https://raw.githubusercontent.com/jurisupport/claudecode-songmu-seminar2/main/setup-check.ps1?cache=legalproc" -OutFile $p -UseBasicParsing
Unblock-File $p
powershell.exe -NoProfile -ExecutionPolicy Bypass -NoExit -File $p
```

스크립트가 열리면 `S`를 선택하세요. 실패해도 Desktop에 진단 ZIP을 남기고, 강의 자료 다운로드는 계속 진행합니다.

### 실습 시작 — 사건 폴더에서 클로드 켜기

한 줄 스크립트가 끝나면 자동으로 `실습사건_세션1_대여금` 폴더로 이동합니다. 그 상태에서 바로 `claude.cmd` 또는 `claude`를 실행하면 됩니다.

```powershell
# Windows (PowerShell)
claude.cmd
```

```bash
# macOS · Linux
claude
```

### 터미널 없이 — 클릭으로 (슬라이드·핸드아웃만 볼 때)

1. 이 페이지 위쪽 초록색 **`Code`** 버튼 → **`Download ZIP`** → 압축 풀기
2. 핸드아웃 `.html`은 **더블클릭**해서 브라우저로 열기 · 슬라이드 PDF도 바로 열림
3. ⚠️ Windows에서 ZIP을 풀면 **한글 폴더명이 깨질 수 있습니다.** 사건폴더에서 `claude.cmd`를 돌리는 **실습은 위의 한 줄(받기)** 을 쓰세요.

## 🚀 실습 순서 (핸드아웃 요약)

1. `실습사건_세션1_대여금` 폴더에서 터미널 열고 `claude` 실행
2. **명령 1** — 사건기록 전체 읽고 시간순·쟁점 정리
3. **명령 4 → 6 → 7** — 법령 확인 → 준비서면 초안 → 자기검증

자세한 명령은 `핸드아웃/실습_명령어_핸드아웃.html`을 그대로 복사해서 쓰세요.

## ⚖️ 가장 중요한 한 가지

**초안은 AI, 검증은 변호사.** 인용한 판결번호·법령은 제출 전 반드시 직접 재확인하세요. (자세한 내용은 핸드아웃 참고)

---
질문은 단톡방으로 🙋
