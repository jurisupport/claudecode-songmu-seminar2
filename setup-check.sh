#!/usr/bin/env bash
# 클로드코드 + jurisupport-plugins 설치 확인 (macOS / Linux)
# 사용:  bash <(curl -fsSL https://raw.githubusercontent.com/jurisupport/claudecode-songmu-seminar2/main/setup-check.sh)

set -u
BOOTSTRAP="https://raw.githubusercontent.com/jurisupport/jurisupport-plugins/main/bootstrap.sh"
GUIDE="https://github.com/jurisupport/jurisupport-plugins"

echo "────────────────────────────────────────"
echo "  클로드코드 실습 환경 점검"
echo "────────────────────────────────────────"

need_install=0

# 1) Claude Code
if command -v claude >/dev/null 2>&1; then
  echo "  ✅ Claude Code 설치됨   ($(claude --version 2>/dev/null | head -1))"
else
  echo "  ❌ Claude Code 미설치"
  need_install=1
fi

# 2) jurisupport-plugins (여러 신호로 감지)
if [ -d "$HOME/jurisupport-plugins" ] \
   || [ -d "$HOME/.claude/skills/brief-draft" ] \
   || [ -d "$HOME/.claude/skills/beopgoeul-search" ]; then
  echo "  ✅ jurisupport-plugins 설치됨"
else
  echo "  ❌ jurisupport-plugins 미설치"
  need_install=1
fi

echo "────────────────────────────────────────"

if [ "$need_install" -eq 0 ]; then
  echo "  🎉 준비 완료 — 바로 실습하시면 됩니다."
  echo
  exit 0
fi

echo "  설치 안내:  $GUIDE"
echo
echo "  ※ Windows(WSL 미사용) 분은 위 링크의 WINDOWS_WSL 가이드를 참고하세요."
echo "    이 자동 설치는 macOS / Linux / WSL 기준입니다."
echo

printf "  지금 자동 설치를 진행할까요? (y/N) "
read -r ans
case "${ans:-N}" in
  [yY]*)
    echo
    echo "  설치를 시작합니다… (약 5~10분, 중간에 비밀번호·[Y/n] 물을 수 있음)"
    echo
    bash <(curl -fsSL "$BOOTSTRAP")
    ;;
  *)
    echo
    echo "  알겠습니다. 나중에 설치하시려면 아래 한 줄을 터미널에 붙여넣으세요:"
    echo
    echo "    bash <(curl -fsSL $BOOTSTRAP)"
    echo
    echo "  자세한 안내: $GUIDE"
    ;;
esac
