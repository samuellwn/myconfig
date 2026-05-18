# @!os:linux
# @!user:dracowizard
# @!install:755:$HOME/.local/bin/pretendpkg

tmpdir=$(mktemp -d)

if [[ ! -d $tmpdir ]]; then
	exit 1
fi

mkdir $tmpdir/pkg || exit

cat <<EOF > $tmpdir/pkg/.PKGINFO
pkgname = pretend-${1}-exists
pkgver = 999-1
pkgdesc = pretend ${1} exists
builddate = $(date +%s)
size = 0
arch = any
provides = ${1}
conflict = ${1}
EOF

pkgpath="$tmpdir/${1}-999-1-any.pkg.tar.zstd"

tar --zstd -cf $pkgpath -C $tmpdir/pkg .PKGINFO
sudo pacman -U $pkgpath
