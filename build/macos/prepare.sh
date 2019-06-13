#!/usr/bin/env bash

depcheck() {
	if [ ! -z "${SKIP_DEPCHECK}" ]; then
		return 0
	fi

	if ! which brew; then
		echo 'Homebrew can be used to fetch all the dependencies and is generally useful to have around; consider installing it (refer to https://brew.sh/ for instructions).'
		echo 'From now on assuming that necessary steps in that regard are already taken.'
		return 0
	fi

	# The list could be optimized a bit further, but I've spent enough time already.
	brew install libtool autoconf automake intltool gtk-doc py2cairo pygtk babl gegl glib-networking gexiv2 libmypaint poppler lcms2 libheif aalib gtk-mac-integration || return

	if ! brew install mypaint-brushes; then
		local mypaint_brushes_link='https://github.com/ryan-robeson/homebrew-gimp/releases/download/v1.0/mypaint-brushes-v1.3.x.mojave.bottle.tar.gz'

		echo '"my paint-brushes" package is not provided by core Homebrew repository.'
		echo 'Note that the following prebuilt binary is created by a totally random person who is most certainly not associated with GIMP developers, Homebrew team, developer of this script and so on. Said that, it contains just a bunch of PNGs and some pkg-config rules, so it _should_ be mostly harmless.'
		echo "Here's the download link if you are inclined to investigate contents of the package personally: ${mypaint_brushes_link}"
		echo -n "Type 'yes' to confirm you've read the passage above and will to continue [yes/no]: "

		local resp=
		while read resp; do
			if [ -z "${resp}" ]; then
				echo -n "Type 'yes' to confirm you've read the passage above and will to continue [yes/no]: "
			elif [ "${resp,,}" != 'yes' ]; then
				echo 'Aborting.'
				return 1
			else
				break
			fi
		done

		local macos_codename="$(grep -oE 'SOFTWARE LICENSE AGREEMENT FOR macOS.*[A-Za-z]' '/System/Library/CoreServices/Setup Assistant.app/Contents/Resources/en.lproj/OSXSoftwareLicense.rtf' | sed 's/SOFT.*macOS //')"
		local bottle_file="./mypaint-brushes-v1.3.x.${macos_codename,,}.bottle.tar.gz"

		curl -vL "${mypaint_brushes_link}" > "${bottle_file}" &&
		brew install "${bottle_file}" &&
		rm "${bottle_file}" || return
	fi

	# libffi is SPECIAL and won't provide its .pc file voluntarily; fixing that inconvenience.
	if [ ! -e '/usr/local/lib/pkgconfig/libffi.pc' ]; then
		pushd /usr/local/lib/pkgconfig
		ln -s ../../opt/libffi/lib/pkgconfig/libffi.pc
		popd
	fi
}

run_autogen() {
	# Aclocal won't work without those for some reason
	export ACLOCAL_FLAGS="-I /usr/local/share/aclocal -I /usr/local/opt/gettext/share/aclocal/"
	# Your standard .app bundle locations
	export AUTOGEN_CONFIGURE_ARGS="--prefix=${HOME}/GIMP.app/Contents/Resources --bindir=${HOME}/GIMP.app/Contents/MacOS --enable-static --disable-shared --without-libxpm"
	# Optimizing binaries for size and current machine's CPU
	export CFLAGS="-Os -ftree-vectorize $(pkg-config --cflags gtk+-2.0) -march=native -flto"
	# Using LTO to optimize resulting binaries (note the mirroring -flto in CFLAGS)
	export LDFLAGS="$(pkg-config --libs gtk+-2.0) -flto"

	./autogen.sh
}

main() {
	depcheck && run_autogen || return
}

main "$@"

