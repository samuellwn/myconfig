#!/usr/bin/env bash
set -euo pipefail

explicit_only=false
native_only=false
foreign_only=false
no_header=false

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Output a TSV report of installed Arch Linux packages to stdout.

Fields: source  name  version  install_reason  description

Options:
  --explicit-only   Only explicitly installed packages (default: all)
  --native-only     Only native (repo) packages
  --foreign-only    Only foreign (AUR/manual) packages
  --no-header       Omit the TSV header row
  -h, --help        Show this help message
EOF
    exit 0
}

for arg in "$@"; do
    case "$arg" in
        --explicit-only) explicit_only=true ;;
        --native-only)   native_only=true ;;
        --foreign-only)  foreign_only=true ;;
        --no-header)     no_header=true ;;
        -h|--help)       usage ;;
        *) echo "Unknown option: $arg" >&2; usage ;;
    esac
done

if ! command -v pacman &>/dev/null; then
    echo "Error: pacman not found. This script requires an Arch-based system." >&2
    exit 1
fi

if ! $no_header; then
    printf 'source\tname\tversion\tinstall_reason\tdescription\n'
fi

foreign_pkgs=$(pacman -Qqm 2>/dev/null | paste -sd ' ' || true)

pacman -Qi 2>/dev/null | awk -v foreign="$foreign_pkgs" \
    -v explicit_only="$explicit_only" \
    -v native_only="$native_only" \
    -v foreign_only="$foreign_only" '
BEGIN {
    RS = ""
    FS = "\n"
    OFS = "\t"
    split(foreign, arr, " ")
    for (i in arr) f[arr[i]] = 1
}
{
    name = ""; vers = ""; desc = ""; reason = ""
    for (i = 1; i <= NF; i++) {
        if      ($i ~ /^Name[[:space:]]+:/)             { sub(/^Name[[:space:]]*:[[:space:]]*/, "", $i); name = $i }
        else if ($i ~ /^Version[[:space:]]+:/)          { sub(/^Version[[:space:]]*:[[:space:]]*/, "", $i); vers = $i }
        else if ($i ~ /^Description[[:space:]]+:/)      { sub(/^Description[[:space:]]*:[[:space:]]*/, "", $i); desc = $i }
        else if ($i ~ /^Install Reason[[:space:]]+:/)   { sub(/^Install Reason[[:space:]]*:[[:space:]]*/, "", $i); reason = $i }
    }
    if (name == "") next

    gsub(/\t/, " ", desc)
    gsub(/\n/, " ", desc)

    if (reason ~ /^Explicitly/) reason = "explicit"
    else if (reason ~ /Installed as a dependency/) reason = "dependency"
    else reason = "unknown"

    source = (name in f) ? "aur" : "native"

    if (explicit_only == "true" && reason != "explicit") next
    if (native_only  == "true" && source != "native") next
    if (foreign_only == "true" && source != "aur")   next

    print source, name, vers, reason, desc
}'
