#!/bin/sh
set -eu
LC_ALL=C
export LC_ALL

fail() {
  printf '知微安装失败：%s\n' "$1" >&2
  exit 1
}

for command_name in curl unzip zipinfo node ssh; do
  command -v "$command_name" >/dev/null 2>&1 || fail "缺少 $command_name"
done

DOWNLOAD_URL='https://github.com/Archytao/zhiwei-releases/releases/download/v1.1.9/zhiwei-requirement-assistant-1.1.9.zip'
EXPECTED_NAME='zhiwei-requirement-assistant-1.1.9.zip'
EXPECTED_SIZE='1631203'
EXPECTED_SHA256='5cf70d37bac7d00646830d59bfca7bac69ff2c8b50366fb561622c223889fa10'
EXPECTED_VERSION='1.1.9'
WORK_DIR=$(mktemp -d /tmp/zhiwei-install.XXXXXX)
ARCHIVE="$WORK_DIR/package.zip"
EXTRACT_ROOT="$WORK_DIR/extract"
ENTRIES="$WORK_DIR/entries.txt"
trap 'rm -rf "$WORK_DIR"' EXIT HUP INT TERM

printf '正在从 GitHub 下载知微 %s...\n' "$EXPECTED_VERSION"
curl --proto '=https' --tlsv1.2 -fsSL "$DOWNLOAD_URL" -o "$ARCHIVE" || fail "安装包下载失败"

ACTUAL_SIZE=$(wc -c < "$ARCHIVE" | tr -d '[:space:]')
[ "$ACTUAL_SIZE" = "$EXPECTED_SIZE" ] || fail "安装包大小不匹配"
if command -v shasum >/dev/null 2>&1; then
  ACTUAL_SHA256=$(shasum -a 256 "$ARCHIVE" | cut -d ' ' -f 1)
elif command -v sha256sum >/dev/null 2>&1; then
  ACTUAL_SHA256=$(sha256sum "$ARCHIVE" | cut -d ' ' -f 1)
else
  fail "缺少 SHA-256 校验工具"
fi
[ "$ACTUAL_SHA256" = "$EXPECTED_SHA256" ] || fail "安装包 SHA-256 不匹配"

unzip -Z1 "$ARCHIVE" > "$ENTRIES" || fail "无法读取安装包目录"
[ -s "$ENTRIES" ] || fail "安装包为空"
if grep -Eq '(^/|(^|/)\.\.(/|$))' "$ENTRIES"; then
  fail "安装包包含不安全路径"
fi
if zipinfo -l "$ARCHIVE" | grep -Eq '^l'; then
  fail "安装包包含符号链接"
fi
TOP_LEVELS=$(cut -d/ -f1 "$ENTRIES" | sed '/^$/d' | sort -u)
TOP_COUNT=$(printf '%s\n' "$TOP_LEVELS" | sed '/^$/d' | wc -l | tr -d '[:space:]')
[ "$TOP_COUNT" = '1' ] || fail "安装包顶层目录异常"
TOP_LEVEL=$(printf '%s\n' "$TOP_LEVELS" | sed -n '1p')

mkdir -p "$EXTRACT_ROOT"
unzip -qq "$ARCHIVE" -d "$EXTRACT_ROOT" || fail "安装包解压失败"
PACKAGE_ROOT="$EXTRACT_ROOT/$TOP_LEVEL"
[ -f "$PACKAGE_ROOT/manifest.json" ] || fail "安装包缺少 manifest.json"
ACTUAL_VERSION=$(node -e "const fs=require('fs');const m=JSON.parse(fs.readFileSync(process.argv[1],'utf8'));process.stdout.write(String(m.bundleVersion||''))" "$PACKAGE_ROOT/manifest.json")
[ "$ACTUAL_VERSION" = "$EXPECTED_VERSION" ] || fail "安装包版本不匹配"
[ -f "$PACKAGE_ROOT/install.command" ] || fail "通用安装入口缺失"
[ -f "$PACKAGE_ROOT/doctor.command" ] || fail "自检入口缺失"

printf '已校验 %s，开始安装...\n' "$EXPECTED_NAME"
sh "$PACKAGE_ROOT/install.command" "$@"
sh "$PACKAGE_ROOT/doctor.command" "$@"
printf '知微 %s 安装完成，已包含需求评审会议与评审通知闭环。\n' "$EXPECTED_VERSION"
