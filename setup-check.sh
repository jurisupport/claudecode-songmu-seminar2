#!/usr/bin/env bash
# 클로드코드 2차 — 점검 · 설치 · 자료 받기 (macOS / Linux)
# 사용:  bash <(curl -fsSL https://raw.githubusercontent.com/jurisupport/claudecode-songmu-seminar2/main/setup-check.sh)

set -u
BOOTSTRAP="https://raw.githubusercontent.com/jurisupport/jurisupport-plugins/main/bootstrap.sh"
GUIDE="https://github.com/jurisupport/jurisupport-plugins"
REPO="https://github.com/jurisupport/claudecode-songmu-seminar2.git"
TARBALL="https://github.com/jurisupport/claudecode-songmu-seminar2/archive/refs/heads/main.tar.gz"
DEST="$HOME/Downloads/클로드코드2차자료"
SELF='bash <(curl -fsSL https://raw.githubusercontent.com/jurisupport/claudecode-songmu-seminar2/main/setup-check.sh)'

get_materials() {
  mkdir -p "$HOME/Downloads"
  rm -rf "$DEST"
  if command -v git >/dev/null 2>&1; then
    git clone --depth 1 "$REPO" "$DEST" >/dev/null 2>&1 && rm -rf "$DEST/.git"
  else
    tmp="$(mktemp -d)"
    curl -fsSL "$TARBALL" | tar xz -C "$tmp" && mv "$tmp"/claudecode-songmu-seminar2-main "$DEST"
    rm -rf "$tmp"
  fi
  [ -d "$DEST" ]
}

echo "========================================"
echo "  클로드코드 2차 - 점검 · 설치 · 자료 받기"
echo "========================================"

has_claude=0;  command -v claude >/dev/null 2>&1 && has_claude=1
has_plugins=0
if [ -d "$HOME/jurisupport-plugins" ] || [ -d "$HOME/.claude/skills/brief-draft" ] || [ -d "$HOME/.claude/skills/beopgoeul-search" ]; then
  has_plugins=1
fi
[ "$has_claude" -eq 1 ]  && echo "  [OK] Claude Code"          || echo "  [--] Claude Code 미설치"
[ "$has_plugins" -eq 1 ] && echo "  [OK] jurisupport-plugins"  || echo "  [--] jurisupport-plugins 미설치"
echo "----------------------------------------"

if [ "$has_claude" -ne 1 ] || [ "$has_plugins" -ne 1 ]; then
  echo "  설치 안내: $GUIDE"
  echo
  printf "  Claude Code + 플러그인을 지금 설치할까요? (y/N) "
  read -r ans
  case "${ans:-N}" in
    [yY]*)
      echo; echo "  설치를 시작합니다… (약 5~10분)"; echo
      bash <(curl -fsSL "$BOOTSTRAP")
      ;;
    *)
      echo; echo "  나중에 설치하시려면 아래 한 줄을 실행하세요:"
      echo "      bash <(curl -fsSL $BOOTSTRAP)"
      echo "  설치 후 이 명령을 다시 실행하면 강의 자료까지 받습니다."
      exit 0
      ;;
  esac
fi

echo
echo "  강의 자료를 받습니다..."
if get_materials; then
  echo
  echo "  완료 → $DEST"
  echo "  실습을 시작하려면:  cd \"$DEST/실습사건_세션1_대여금\" && claude"
  # 받은 폴더 열기 (mac: open, linux: xdg-open)
  if command -v open >/dev/null 2>&1; then open "$DEST" >/dev/null 2>&1
  elif command -v xdg-open >/dev/null 2>&1; then xdg-open "$DEST" >/dev/null 2>&1; fi
else
  echo
  echo "  자료를 받지 못했습니다. 새 터미널에서 아래를 다시 실행하세요:"
  echo "      $SELF"
fi
