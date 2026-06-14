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

## 🛠️ 처음이신 분 — 설치 확인 (Claude Code + 플러그인)

실습하려면 **Claude Code**와 **jurisupport-plugins**가 설치돼 있어야 합니다. 아래를 붙여넣으면 설치 여부를 확인하고, **안 돼 있으면 설치할지 물어봅니다.**

**macOS · Linux** — 터미널에:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/jurisupport/claudecode-songmu-seminar2/main/setup-check.sh)
```

**Windows** — PowerShell에:

```powershell
irm https://raw.githubusercontent.com/jurisupport/claudecode-songmu-seminar2/main/setup-check.ps1 | iex
```

- 이미 다 설치돼 있으면 "준비 완료"가 뜹니다 → 바로 아래 **받는 법**으로.
- 설치 안내·수동 설치: **https://github.com/jurisupport/jurisupport-plugins**

## ⬇️ 받는 법

### 방법 A — 한 줄로 받기 (git 불필요 · 권장)

**macOS · Linux** (터미널) — `~/Downloads/클로드코드2차자료`에 받아집니다:

```bash
cd ~/Downloads && rm -rf 클로드코드2차자료 && curl -L https://github.com/jurisupport/claudecode-songmu-seminar2/archive/refs/heads/main.tar.gz | tar xz && mv claudecode-songmu-seminar2-main 클로드코드2차자료 && echo "완료 → ~/Downloads/클로드코드2차자료"
```

**Windows** (PowerShell, Win10/11) — `다운로드\클로드코드2차자료`에 받아집니다:

```powershell
cd ~\Downloads; if (Test-Path 클로드코드2차자료) { Remove-Item 클로드코드2차자료 -Recurse -Force }; curl.exe -L https://github.com/jurisupport/claudecode-songmu-seminar2/archive/refs/heads/main.tar.gz -o cc2.tgz; tar -xf cc2.tgz; Remove-Item cc2.tgz; Rename-Item claudecode-songmu-seminar2-main 클로드코드2차자료; "완료 -> $HOME\Downloads\클로드코드2차자료"
```

> `curl.exe`·`tar`는 Windows 10/11에 기본 내장입니다. (`Expand-Archive`는 한글 폴더명이 깨질 수 있어 `tar`를 씁니다.)

실습을 시작할 때는, 사건 폴더로 들어가 클로드를 켭니다.

```bash
# macOS · Linux
cd ~/Downloads/클로드코드2차자료/실습사건_세션1_대여금 && claude
```

```powershell
# Windows (PowerShell)
cd ~\Downloads\클로드코드2차자료\실습사건_세션1_대여금; claude
```

### 방법 B — 클릭으로 (OS 무관)

1. 이 페이지 위쪽 초록색 **`Code`** 버튼 → **`Download ZIP`** → 압축 풀기
2. 핸드아웃 2개는 `.html` 파일을 **더블클릭**해서 브라우저로 엽니다 (명령마다 복사 버튼)
3. 실습은 `실습사건_세션1_대여금` 폴더를 통째로 쓰면 됩니다

## 🚀 실습 순서 (핸드아웃 요약)

1. `실습사건_세션1_대여금` 폴더에서 터미널 열고 `claude` 실행
2. **명령 1** — 사건기록 전체 읽고 시간순·쟁점 정리
3. **명령 4 → 6 → 7** — 법령 확인 → 준비서면 초안 → 자기검증

자세한 명령은 `핸드아웃/실습_명령어_핸드아웃.html`을 그대로 복사해서 쓰세요.

## ⚖️ 가장 중요한 한 가지

**초안은 AI, 검증은 변호사.** 인용한 판결번호·법령은 제출 전 반드시 직접 재확인하세요. (자세한 내용은 핸드아웃 참고)

---
질문은 단톡방으로 🙋
