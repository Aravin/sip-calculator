#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────
#  SIP Calculator — Automated Build Script
#  Bumps version, builds release artifacts,
#  and optionally creates a git tag.
# ──────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PUBSPEC="$SCRIPT_DIR/pubspec.yaml"
VERSION_REGEX='^version: ([0-9]+)\.([0-9]+)\.([0-9]+)\+([0-9]+)$'

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

print_usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Bump version and build release APK / AAB for SIP Calculator.

Options:
  --major            Bump major version (x.0.0)
  --minor            Bump minor version (0.x.0)  [default]
  --patch            Bump patch version (0.0.x)
  --build-only       Only increment build number, leave version name unchanged
  --dry-run          Show what would be done without writing files
  --no-build         Bump version only, skip the Flutter build
  --tag              Create a git tag after a successful build
  --commit           Create a git commit with the version bump
  -h, --help         Show this help message

Examples:
  $(basename "$0")                     # bump minor + build, build APK + AAB
  $(basename "$0") --patch             # bump patch + build
  $(basename "$0") --build-only        # bump build only
  $(basename "$0") --no-build          # just bump, don't build
  $(basename "$0") --tag --commit      # bump, build, commit & tag
  $(basename "$0") --dry-run           # preview only
EOF
  exit 0
}

# ── Parse arguments ───────────────────
BUMP_MAJOR=false
BUMP_MINOR=false
BUMP_PATCH=false
BUILD_ONLY=false
DRY_RUN=false
SKIP_BUILD=false
DO_TAG=false
DO_COMMIT=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --major)    BUMP_MAJOR=true ;;
    --minor)    BUMP_MINOR=true ;;
    --patch)    BUMP_PATCH=true ;;
    --build-only) BUILD_ONLY=true ;;
    --dry-run)  DRY_RUN=true ;;
    --no-build) SKIP_BUILD=true ;;
    --tag)      DO_TAG=true ;;
    --commit)   DO_COMMIT=true ;;
    -h|--help)  print_usage ;;
    *)          echo -e "${RED}Unknown option: $1${NC}" >&2; print_usage ;;
  esac
  shift
done

# ── Determine bump strategy ───────────
if $BUILD_ONLY; then
  BUMP_MAJOR=false; BUMP_MINOR=false; BUMP_PATCH=false
elif ! $BUMP_MAJOR && ! $BUMP_MINOR && ! $BUMP_PATCH; then
  BUMP_MINOR=true
fi

# ── Read current version ──────────────
if [[ ! -f "$PUBSPEC" ]]; then
  echo -e "${RED}Error: $PUBSPEC not found. Run this script from the 'app' directory.${NC}" >&2
  exit 1
fi

VERSION_LINE=$(grep -E '^version: ' "$PUBSPEC")
if [[ ! "$VERSION_LINE" =~ $VERSION_REGEX ]]; then
  echo -e "${RED}Error: could not parse version from pubspec.yaml${NC}" >&2
  exit 1
fi

MAJOR="${BASH_REMATCH[1]}"
MINOR="${BASH_REMATCH[2]}"
PATCH="${BASH_REMATCH[3]}"
BUILD="${BASH_REMATCH[4]}"

echo -e "${CYAN}Current version: ${YELLOW}$MAJOR.$MINOR.$PATCH+$BUILD${NC}"

# ── Compute new version ───────────────
if $BUILD_ONLY; then
  NEW_MAJOR=$MAJOR
  NEW_MINOR=$MINOR
  NEW_PATCH=$PATCH
elif $BUMP_MAJOR; then
  NEW_MAJOR=$((MAJOR + 1))
  NEW_MINOR=0
  NEW_PATCH=0
elif $BUMP_MINOR; then
  NEW_MAJOR=$MAJOR
  NEW_MINOR=$((MINOR + 1))
  NEW_PATCH=0
elif $BUMP_PATCH; then
  NEW_MAJOR=$MAJOR
  NEW_MINOR=$MINOR
  NEW_PATCH=$((PATCH + 1))
fi
NEW_BUILD=$((BUILD + 1))
NEW_VERSION="$NEW_MAJOR.$NEW_MINOR.$NEW_PATCH+$NEW_BUILD"

echo -e "${CYAN}New version:     ${GREEN}$NEW_VERSION${NC}"

# ── Determine build name / number ─────
BUILD_NAME="$NEW_MAJOR.$NEW_MINOR.$NEW_PATCH"
BUILD_NUMBER="$NEW_BUILD"

# ── Dry-run / confirm ─────────────────
if $DRY_RUN; then
  echo -e "\n${YELLOW}[DRY-RUN] No files were changed.${NC}"
  echo "  pubspec.yaml : version: $NEW_VERSION"
  echo "  Build name   : $BUILD_NAME"
  echo "  Build number : $BUILD_NUMBER"
  if ! $SKIP_BUILD; then
    echo "  Flutter build: appbundle"
  fi
  if $DO_TAG; then
    echo "  Git tag      : v$NEW_VERSION"
  fi
  if $DO_COMMIT; then
    echo "  Git commit   : 'chore: bump version to $NEW_VERSION'"
  fi
  exit 0
fi

# ── Write new version to pubspec.yaml ──
echo -e "\n${CYAN}Updating pubspec.yaml...${NC}"
sed -i "" "s/^version: .*/version: $NEW_VERSION/" "$PUBSPEC"
echo -e "${GREEN}  → version: $NEW_VERSION${NC}"

# ── Optional git commit ───────────────
if $DO_COMMIT; then
  echo -e "\n${CYAN}Committing version bump...${NC}"
  git add "$PUBSPEC" && git commit -m "chore: bump version to $NEW_VERSION"
  echo -e "${GREEN}  ✓ committed${NC}"
fi

# ── Build ─────────────────────────────
if ! $SKIP_BUILD; then
  echo -e "\n${CYAN}Building Flutter release...${NC}"

  if ! command -v flutter &>/dev/null; then
    echo -e "${RED}Error: 'flutter' not found on PATH${NC}" >&2
    exit 1
  fi

  echo -e "${YELLOW}  → flutter clean${NC}"
  flutter clean 2>&1 | sed 's/^/    /'

  echo -e "${YELLOW}  → flutter pub get${NC}"
  flutter pub get 2>&1 | sed 's/^/    /'

  echo -e "${YELLOW}  → flutter build appbundle --release${NC}"
  flutter build appbundle --release 2>&1 | sed 's/^/    /'

  # ── Locate built artifacts ──────────
  AAB_PATH="$(find "$SCRIPT_DIR/build/app/outputs/bundle/release" -name '*.aab' 2>/dev/null | head -1)"
  echo -e "\n${GREEN}✓ Build complete!${NC}"
  [[ -n "$AAB_PATH" ]] && echo -e "  AAB: ${CYAN}$AAB_PATH${NC}"

  # ── Optional git tag ────────────────
  if $DO_TAG; then
    TAG="v$NEW_VERSION"
    echo -e "\n${CYAN}Creating git tag: ${YELLOW}$TAG${NC}"
    git tag "$TAG" && echo -e "${GREEN}  ✓ tagged as $TAG${NC}"
  fi
else
  echo -e "\n${GREEN}✓ Version bumped to $NEW_VERSION (build skipped)${NC}"
fi

echo -e "\n${GREEN}Done.${NC}"
