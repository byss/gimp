#!/usr/bin/env bash

build_gimp() {
	if [ ! -z "${SKIP_MAKEINSTALL}" ]; then
		return 0
	fi

	local jobs_count="$(($(sysctl -n 'machdep.cpu.thread_count') * 2))"

	make -j${jobs_count} && make install -j${jobs_count}
}

complete_app_bundle() {
	local install_prefix="$(PKG_CONFIG_PATH='.' pkg-config --variable=prefix gimp-2.0)"
	local bundle_contents="${install_prefix%/Resources}"
	local app_root="${bundle_contents%/Contents}"

	cp "build/macos/Info.plist" "${bundle_contents}/Info.plist" &&
	echo 'APPLGIMP' > "${bundle_contents}/PkgInfo" &&
	cp "build/macos/gimp.icns" "${install_prefix}/gimp.icns" &&
	xattr -wx com.apple.FinderInfo 0000000000000000200000000000000000000000000000000000000000000000 "${app_root}" &&
	open -R "${app_root}"
}

main() {
	build_gimp && complete_app_bundle
}

main "$@"
