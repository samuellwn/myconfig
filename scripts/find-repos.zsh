#!/usr/bin/env zsh
# @!os:unix
# @!user:dracowizard
# @!install:755:$HOME/.local/bin/find-repos.zsh

set -euo pipefail

(
find ~/src -mindepth 2 -maxdepth 2 -type d \
	-not -path '*/.*' -not -path '*/_*'
find ~/Projects -mindepth 1 -maxdepth 1 -type d \
	-not -path '*/.*' -not -path '*/_*' \
	-not -name wikis -not -name makepkg \
	-not -name ProjectsArchive
find ~/Work -mindepth 1 -maxdepth 1 -type d \
	-not -path '*/.*' -not -path '*/_*' \
	-not -name 'System Volume Information' \
	-not -name 'Web' -not -name 'SysAdmin' \
	-not -name 'Cloudveil' -not -name 'sb'

echo ~/Work/sfi/sfi

for name in ~/Projects/wikis ~/Projects/makepkg; do
	find $name -mindepth 1 -maxdepth 1 -type d \
		-not -path '*/.*' -not -path '*/_*'
done

for name in ~/Work/Web ~/Work/Cloudveil; do
	find $name -mindepth 1 -maxdepth 1 -type d \
		-not -path '*/.*' -not -path '*/_*'
done

) | sed -E 's:^/home/[[:alnum:]_-]*:~:' | sort
