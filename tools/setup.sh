#!/usr/bin/env bash
#
# setup.sh - Validates the local environment for the Claude Skills Library.
# Usage: ./tools/setup.sh
#

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PASS=0
FAIL=0
WARN=0

header() {
  echo ""
  echo -e "${BLUE}============================================${NC}"
  echo -e "${BLUE}  Claude Skills Library - Environment Check${NC}"
  echo -e "${BLUE}============================================${NC}"
  echo ""
}

check_required() {
  local name="$1"
  local cmd="$2"
  local min_version="$3"
  local version_cmd="$4"

  if command -v "$cmd" &>/dev/null; then
    local version
    version=$(eval "$version_cmd" 2>&1 | head -1)
    echo -e "  ${GREEN}[PASS]${NC} $name found: $version (minimum: $min_version)"
    PASS=$((PASS + 1))
  else
    echo -e "  ${RED}[FAIL]${NC} $name not found (minimum required: $min_version)"
    FAIL=$((FAIL + 1))
  fi
}

check_optional() {
  local name="$1"
  local cmd="$2"
  local purpose="$3"

  if command -v "$cmd" &>/dev/null; then
    local version
    version=$("$cmd" --version 2>&1 | head -1 || echo "installed")
    echo -e "  ${GREEN}[PASS]${NC} $name found: $version"
    PASS=$((PASS + 1))
  else
    echo -e "  ${YELLOW}[WARN]${NC} $name not found - used for: $purpose"
    WARN=$((WARN + 1))
  fi
}

check_node_version() {
  if command -v node &>/dev/null; then
    local version
    version=$(node --version 2>&1 | sed 's/^v//')
    local major
    major=$(echo "$version" | cut -d. -f1)
    if [ "$major" -ge 18 ]; then
      echo -e "  ${GREEN}[PASS]${NC} Node.js version check: v$version (>= 18)"
      PASS=$((PASS + 1))
    else
      echo -e "  ${RED}[FAIL]${NC} Node.js version too old: v$version (need >= 18)"
      FAIL=$((FAIL + 1))
    fi
  fi
}

check_python_version() {
  local pycmd=""
  if command -v python3 &>/dev/null; then
    pycmd="python3"
  elif command -v python &>/dev/null; then
    pycmd="python"
  fi

  if [ -n "$pycmd" ]; then
    local version
    version=$($pycmd --version 2>&1 | sed 's/Python //')
    local major minor
    major=$(echo "$version" | cut -d. -f1)
    minor=$(echo "$version" | cut -d. -f2)
    if [ "$major" -ge 3 ] && [ "$minor" -ge 10 ]; then
      echo -e "  ${GREEN}[PASS]${NC} Python version check: $version (>= 3.10)"
      PASS=$((PASS + 1))
    else
      echo -e "  ${RED}[FAIL]${NC} Python version too old: $version (need >= 3.10)"
      FAIL=$((FAIL + 1))
    fi
  fi
}

check_skills_directory() {
  local skills_dir
  skills_dir="$(cd "$(dirname "$0")/.." && pwd)/.claude/skills"

  if [ -d "$skills_dir" ]; then
    local count
    count=$(find "$skills_dir" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
    echo -e "  ${GREEN}[PASS]${NC} Skills directory found: $count skill(s) detected"
    PASS=$((PASS + 1))
  else
    echo -e "  ${RED}[FAIL]${NC} Skills directory not found at .claude/skills/"
    FAIL=$((FAIL + 1))
  fi
}

# ── Main ────────────────────────────────────────────────────────────

header

echo -e "${BLUE}Required Tools${NC}"
check_required "Node.js" "node" ">= 18" "node --version"
check_node_version
check_required "Python" "python3" ">= 3.10" "python3 --version"
check_python_version
check_required "Git" "git" "any" "git --version"

echo ""
echo -e "${BLUE}Optional Tools${NC}"
check_optional "jq" "jq" "JSON processing in automation scripts"
check_optional "curl" "curl" "HTTP requests in web-scraping and API skills"

echo ""
echo -e "${BLUE}Project Structure${NC}"
check_skills_directory

echo ""
echo -e "${BLUE}────────────────────────────────────────────${NC}"
echo -e "  ${GREEN}Passed: $PASS${NC}  ${RED}Failed: $FAIL${NC}  ${YELLOW}Warnings: $WARN${NC}"
echo -e "${BLUE}────────────────────────────────────────────${NC}"

if [ "$FAIL" -gt 0 ]; then
  echo ""
  echo -e "${RED}Some required checks failed. Please install missing dependencies.${NC}"
  exit 1
else
  echo ""
  echo -e "${GREEN}Environment is ready for Claude Skills Library.${NC}"
  exit 0
fi
