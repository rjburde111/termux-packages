TERMUX_PKG_HOMEPAGE=https://github.com/holman/spark
TERMUX_PKG_DESCRIPTION="▁▂▃▅▂▇ in your shell."
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION=1.0.1
TERMUX_PKG_SRCURL=$TERMUX_PKG_HOMEPAGE/archive/v$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=a81c1bc538ce8e011f62264fe6f33d28042ff431b510a6359040dc77403ebab6
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_DEPENDS=bash
TERMUX_PKG_PLATFORM_INDEPENDENT=true

termux_step_make_install() {
	local bin="$(basename $TERMUX_PKG_HOMEPAGE)"
	install -D "$bin" -t "$TERMUX_PREFIX/bin"
}
