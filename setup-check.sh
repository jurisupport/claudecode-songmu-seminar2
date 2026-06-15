#!/usr/bin/env bash
# 클로드코드 2차 — 점검 · 설치 · 자료 받기 (macOS / Linux)
# 사용:  bash <(curl -fsSL https://raw.githubusercontent.com/jurisupport/claudecode-songmu-seminar2/main/setup-check.sh)

set -u
BOOTSTRAP="https://raw.githubusercontent.com/jurisupport/jurisupport-plugins/main/bootstrap.sh"
LEGAL_TERMINAL_INSTALLER="https://raw.githubusercontent.com/jurisupport/legal-terminal/main/install-mac.sh"
GUIDE="https://github.com/jurisupport/jurisupport-plugins"
LEGAL_TERMINAL_GUIDE="https://github.com/jurisupport/legal-terminal"
REPO="https://github.com/jurisupport/claudecode-songmu-seminar2.git"
TARBALL="https://github.com/jurisupport/claudecode-songmu-seminar2/archive/refs/heads/main.tar.gz"
DEST="$HOME/Downloads/클로드코드2차자료"
PRACTICE_DIR="$DEST/실습사건_세션1_대여금"
SELF='bash <(curl -fsSL https://raw.githubusercontent.com/jurisupport/claudecode-songmu-seminar2/main/setup-check.sh)'

get_materials() {
  mkdir -p "$HOME/Downloads"
  rm -rf "$DEST"
  if command -v git >/dev/null 2>&1; then
    if git clone --depth 1 "$REPO" "$DEST" >/dev/null 2>&1; then
      rm -rf "$DEST/.git"
      return 0
    fi
    rm -rf "$DEST"
  fi

  tmp="$(mktemp -d)" || return 1
  if curl -fsSL "$TARBALL" | tar xz -C "$tmp"; then
    mv "$tmp/claudecode-songmu-seminar2-main" "$DEST"
    rc=$?
  else
    rc=1
  fi
  rm -rf "$tmp"
  [ "$rc" -eq 0 ] || return "$rc"
  [ -d "$DEST" ]
}

has_legal_terminal() {
  get_legal_terminal_app >/dev/null 2>&1
}

short_ref() {
  if [ -n "${1:-}" ]; then
    printf '%s' "$1" | cut -c 1-12
  fi
}

version_clean() {
  printf '%s' "${1:-}" | sed 's/^v//'
}

get_claude_current_version() {
  if command -v npm >/dev/null 2>&1; then
    npm list -g @anthropic-ai/claude-code --depth=0 2>/dev/null |
      sed -n 's/.*@anthropic-ai\/claude-code@\([^[:space:]]*\).*/\1/p' |
      head -1
  fi
}

get_claude_latest_version() {
  if command -v npm >/dev/null 2>&1; then
    npm view @anthropic-ai/claude-code version 2>/dev/null | head -1
  fi
}

get_plugins_current_ref() {
  if [ -d "$HOME/jurisupport-plugins/.git" ] && command -v git >/dev/null 2>&1; then
    git -C "$HOME/jurisupport-plugins" rev-parse HEAD 2>/dev/null || true
  fi
}

get_plugins_latest_ref() {
  if [ -d "$HOME/jurisupport-plugins/.git" ] && command -v git >/dev/null 2>&1; then
    git -C "$HOME/jurisupport-plugins" ls-remote origin refs/heads/main 2>/dev/null |
      awk 'NR == 1 {print $1}'
  fi
}

plugins_present() {
  [ -d "$HOME/jurisupport-plugins" ] ||
    [ -d "$HOME/.claude/skills/lbox-guide" ] ||
    [ -d "$HOME/.claude/skills/beopgoeul-search" ] ||
    [ -d "$HOME/.codex/skills/lbox-guide" ] ||
    [ -d "$HOME/.codex/skills/beopgoeul-search" ]
}

append_missing() {
  if [ -n "${missing:-}" ]; then
    missing="$missing, $1"
  else
    missing="$1"
  fi
}

get_plugins_missing() {
  missing=""
  repo="$HOME/jurisupport-plugins"

  [ -f "$repo/install.sh" ] || append_missing "repo/install.sh"
  [ -f "$repo/plugins/jurisupport/.claude-plugin/plugin.json" ] || append_missing "plugin manifest"

  for skills_root in "$HOME/.claude/skills" "$HOME/.codex/skills"; do
    root_label=".claude"
    case "$skills_root" in
      "$HOME/.codex/skills") root_label=".codex" ;;
    esac
    for skill in lbox-guide beopgoeul-search; do
      [ -f "$skills_root/$skill/SKILL.md" ] || append_missing "$root_label $skill skill"
    done
  done

  [ -f "$HOME/.claude/commands/beopgoeul-search.md" ] || append_missing "beopgoeul command"

  if command -v claude >/dev/null 2>&1; then
    if ! claude plugin list 2>/dev/null | grep -Eq '(^|[[:space:]])jurisupport([[:space:]]|$|@)'; then
      append_missing "Claude plugin jurisupport"
    fi
    if ! claude plugin marketplace list 2>/dev/null | grep -q "jurisupport-plugins"; then
      append_missing "Claude marketplace jurisupport-plugins"
    fi
  else
    append_missing "Claude Code CLI"
  fi

  printf '%s' "$missing"
}

get_legal_terminal_app() {
  for app in "/Applications/legal-terminal.app" "$HOME/Applications/legal-terminal.app" "$HOME/Downloads/legal-terminal.app"; do
    if [ -d "$app" ]; then
      printf '%s\n' "$app"
      return 0
    fi
  done
  if command -v mdfind >/dev/null 2>&1; then
    found="$(mdfind "kMDItemCFBundleIdentifier == 'kr.lawpid.legalterminal'" 2>/dev/null | head -1)"
    if [ -n "$found" ] && [ -d "$found" ]; then
      printf '%s\n' "$found"
      return 0
    fi
  fi
  return 1
}

get_legal_terminal_current_version() {
  app="$(get_legal_terminal_app 2>/dev/null || true)"
  plist="$app/Contents/Info.plist"
  if [ -n "$app" ] && [ -f "$plist" ]; then
    if command -v /usr/libexec/PlistBuddy >/dev/null 2>&1; then
      /usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$plist" 2>/dev/null || true
    else
      defaults read "$plist" CFBundleShortVersionString 2>/dev/null || true
    fi
  fi
}

get_legal_terminal_latest_version() {
  if command -v curl >/dev/null 2>&1; then
    curl -fsIL -o /dev/null -w '%{url_effective}' https://github.com/jurisupport/legal-terminal/releases/latest 2>/dev/null |
      sed 's#.*/tag/##; s/^v//'
  fi
}

write_status() {
  name="$1"
  installed="$2"
  current="$3"
  latest="$4"
  needs_update="$5"
  missing="${6:-}"

  if [ "$installed" -ne 1 ]; then
    if [ -n "$missing" ]; then
      echo "  [--] $name 미설치/불완전 (누락: $(printf '%.140s' "$missing"))"
    else
      echo "  [--] $name 미설치"
    fi
    return
  fi

  mark="[OK]"
  [ "$needs_update" -eq 1 ] && mark="[!!]"
  [ -n "$missing" ] && mark="[!!]"
  details=""
  if [ -n "$missing" ]; then
    details="불완전, 누락: $(printf '%.140s' "$missing")"
  fi
  [ -n "$current" ] && details="현재 $(short_ref "$current")"
  if [ -n "$missing" ] && [ -n "$current" ]; then
    details="불완전, 누락: $(printf '%.100s' "$missing"), 현재 $(short_ref "$current")"
  fi
  if [ -n "$latest" ]; then
    [ -n "$details" ] && details="$details, "
    details="${details}최신 $(short_ref "$latest")"
  fi
  if [ "$needs_update" -eq 1 ]; then
    [ -n "$details" ] && details="$details, "
    details="${details}업데이트 필요"
  elif [ -z "$missing" ] && [ -n "$current" ] && [ -n "$latest" ]; then
    details="$details, 최신 상태"
  elif [ -z "$current" ] && [ -n "$latest" ]; then
    [ -n "$details" ] && details="$details, "
    details="${details}현재 버전 확인 불가"
  elif [ -n "$current" ] && [ -z "$latest" ]; then
    [ -n "$details" ] && details="$details, "
    details="${details}최신 버전 확인 불가"
  else
    [ -n "$details" ] || details="버전 확인 불가"
  fi

  echo "  $mark $name ($details)"
}

verify_core_install() {
  action="$1"
  post_missing="$(get_plugins_missing)"
  post_has_claude=0
  command -v claude >/dev/null 2>&1 && post_has_claude=1
  if [ "$post_has_claude" -eq 1 ] && [ -z "$post_missing" ]; then
    return 0
  fi

  echo
  echo "  $action 후 점검에서 누락을 발견했습니다."
  [ "$post_has_claude" -eq 1 ] || echo "    - Claude Code CLI"
  if [ -n "$post_missing" ]; then
    old_ifs="$IFS"
    IFS=','
    for item in $post_missing; do
      trimmed="$(printf '%s' "$item" | sed 's/^ *//; s/ *$//')"
      [ -n "$trimmed" ] && echo "    - $trimmed"
    done
    IFS="$old_ifs"
  fi
  return 1
}

verify_legal_terminal_install() {
  action="$1"
  if ! has_legal_terminal; then
    echo
    echo "  legal-terminal $action 후 점검에서 문제가 발견됐습니다."
    echo "    - legal-terminal 앱이 감지되지 않음"
    return 1
  fi

  post_current="$(get_legal_terminal_current_version)"
  post_latest="$(get_legal_terminal_latest_version)"
  if [ -n "$post_current" ] && [ -n "$post_latest" ] &&
    [ "$(version_clean "$post_current")" != "$(version_clean "$post_latest")" ]; then
    echo
    echo "  legal-terminal $action 후 점검에서 문제가 발견됐습니다."
    echo "    - legal-terminal 최신 버전 아님"
    return 1
  fi

  return 0
}

install_legal_terminal() {
  case "$(uname -s)" in
    Darwin)
      curl -fsSL "$LEGAL_TERMINAL_INSTALLER" | bash
      ;;
    *)
      echo "  Linux에서는 legal-terminal 앱 자동 설치를 지원하지 않습니다."
      echo "  수동 안내: $LEGAL_TERMINAL_GUIDE"
      return 1
      ;;
  esac
}

enter_practice_dir() {
  if [ ! -d "$PRACTICE_DIR" ]; then
    echo "  실습 폴더를 찾지 못했습니다. 직접 이동해 주세요:"
    echo "      cd \"$PRACTICE_DIR\" && claude"
    return 1
  fi

  cd "$PRACTICE_DIR" || return 1
  echo "  현재 위치를 실습 폴더로 이동했습니다:"
  echo "      $PWD"
  echo
  echo "  실습을 시작하려면 아래를 실행하세요:"
  echo "      claude"

  if [ -t 0 ] && [ -t 1 ]; then
    echo
    echo "  이 터미널을 실습 폴더에서 계속 쓰도록 새 셸을 엽니다."
    echo "  원래 셸로 돌아가려면 exit 를 입력하세요."
    exec "${SHELL:-/bin/bash}"
  fi
}

echo "========================================"
echo "  클로드코드 2차 - 점검 · 설치 · 자료 받기"
echo "========================================"

has_claude=0;  command -v claude >/dev/null 2>&1 && has_claude=1
has_plugins=0
plugins_missing="$(get_plugins_missing)"
[ -z "$plugins_missing" ] && has_plugins=1
plugins_present_status=0
if [ "$has_plugins" -eq 1 ] || plugins_present; then plugins_present_status=1; fi
has_legal_terminal_status=0; has_legal_terminal && has_legal_terminal_status=1
claude_current="$(get_claude_current_version)"
claude_latest="$(get_claude_latest_version)"
plugins_current="$(get_plugins_current_ref)"
plugins_latest="$(get_plugins_latest_ref)"
legal_terminal_current="$(get_legal_terminal_current_version)"
legal_terminal_latest="$(get_legal_terminal_latest_version)"
claude_needs_update=0
plugins_needs_update=0
legal_terminal_needs_update=0
[ -n "$claude_current" ] && [ -n "$claude_latest" ] && [ "$(version_clean "$claude_current")" != "$(version_clean "$claude_latest")" ] && claude_needs_update=1
[ -n "$plugins_current" ] && [ -n "$plugins_latest" ] && [ "$plugins_current" != "$plugins_latest" ] && plugins_needs_update=1
[ -n "$legal_terminal_current" ] && [ -n "$legal_terminal_latest" ] && [ "$(version_clean "$legal_terminal_current")" != "$(version_clean "$legal_terminal_latest")" ] && legal_terminal_needs_update=1
write_status "Claude Code" "$has_claude" "$claude_current" "$claude_latest" "$claude_needs_update"
write_status "jurisupport-plugins" "$plugins_present_status" "$plugins_current" "$plugins_latest" "$plugins_needs_update" "$plugins_missing"
write_status "legal-terminal" "$has_legal_terminal_status" "$legal_terminal_current" "$legal_terminal_latest" "$legal_terminal_needs_update"
echo "----------------------------------------"

skip_tool_install=0

if [ "$has_claude" -ne 1 ] || [ "$has_plugins" -ne 1 ]; then
  echo "  설치 안내: $GUIDE"
  echo
  printf "  Claude Code + 플러그인을 지금 설치할까요? (Y/n, Enter=설치, n=도구 설치 건너뛰기) "
  read -r ans
  case "${ans:-Y}" in
    [nN]*)
      echo; echo "  도구 설치는 건너뛰고 강의 자료만 받습니다."
      skip_tool_install=1
      echo "  나중에 설치하시려면 아래 한 줄을 실행하세요:"
      echo "      bash <(curl -fsSL $BOOTSTRAP)"
      echo "  설치 후 이 명령을 다시 실행하면 점검까지 다시 할 수 있습니다."
      ;;
    *)
      echo; echo "  설치를 시작합니다… (약 5~10분)"; echo
      bootstrap_ok=0
      bash <(curl -fsSL "$BOOTSTRAP") || bootstrap_ok=$?
      if [ "$bootstrap_ok" -ne 0 ] || ! verify_core_install "설치"; then
        echo "  설치가 완료되지 않았습니다. 그래도 강의 자료는 계속 받습니다."
      fi
      ;;
  esac
elif [ "$claude_needs_update" -eq 1 ] || [ "$plugins_needs_update" -eq 1 ]; then
  echo
  echo "  Claude Code 또는 jurisupport-plugins 업데이트가 필요합니다."
  printf "  지금 최신 버전으로 업데이트할까요? (Y/n, Enter=업데이트) "
  read -r update_ans
  case "${update_ans:-Y}" in
    [nN]*)
      echo "  업데이트는 건너뜁니다."
      ;;
    *)
      echo; echo "  업데이트를 시작합니다…"; echo
      bootstrap_ok=0
      bash <(curl -fsSL "$BOOTSTRAP") || bootstrap_ok=$?
      if [ "$bootstrap_ok" -ne 0 ] || ! verify_core_install "업데이트"; then
        echo "  업데이트가 완료되지 않았습니다. 그래도 강의 자료는 계속 받습니다."
      fi
      ;;
  esac
fi

if ! has_legal_terminal && [ "$skip_tool_install" -ne 1 ]; then
  echo
  echo "  legal-terminal 설치 안내: $LEGAL_TERMINAL_GUIDE"
  printf "  legal-terminal 앱을 설치할까요? (Y/n, Enter=설치) "
  read -r lt_ans
  case "${lt_ans:-Y}" in
    [nN]*)
      echo "  legal-terminal 설치는 건너뜁니다."
      ;;
    *)
      if ! install_legal_terminal || ! verify_legal_terminal_install "설치"; then
        echo "  legal-terminal 설치가 완료되지 않았습니다. 그래도 강의 자료는 계속 받습니다."
      fi
      ;;
  esac
elif [ "$legal_terminal_needs_update" -eq 1 ] && [ "$skip_tool_install" -ne 1 ]; then
  echo
  echo "  legal-terminal 업데이트가 필요합니다."
  printf "  legal-terminal 앱을 최신 버전으로 업데이트할까요? (Y/n, Enter=업데이트) "
  read -r lt_update_ans
  case "${lt_update_ans:-Y}" in
    [nN]*)
      echo "  legal-terminal 업데이트는 건너뜁니다."
      ;;
    *)
      if ! install_legal_terminal || ! verify_legal_terminal_install "업데이트"; then
        echo "  legal-terminal 업데이트가 완료되지 않았습니다. 그래도 강의 자료는 계속 받습니다."
      fi
      ;;
  esac
fi

echo
echo "  강의 자료를 받습니다..."
if get_materials; then
  echo
  echo "  완료 → $DEST"
  # 받은 폴더 열기 (mac: open, linux: xdg-open)
  if command -v open >/dev/null 2>&1; then open "$PRACTICE_DIR" >/dev/null 2>&1
  elif command -v xdg-open >/dev/null 2>&1; then xdg-open "$PRACTICE_DIR" >/dev/null 2>&1; fi
  enter_practice_dir
else
  echo
  echo "  자료를 받지 못했습니다. 새 터미널에서 아래를 다시 실행하세요:"
  echo "      $SELF"
fi
