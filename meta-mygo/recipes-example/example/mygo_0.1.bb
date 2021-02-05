#
# This file was derived from the 'Hello World!' example recipe in the
# Yocto Project Development Manual.
#

SUMMARY = "Simple helloworld application"
SECTION = "examples"
LICENSE = "CLOSED"

SRC_URI = "file://helloworld.go"

#DEPENDS += "go-cross-arm gcc-runtime gcc-cross-arm"

export GOROOT="/usr/local/go"
export GOARM="5"
export GOOS="linux"
export GOARCH="arm"
S = "${WORKDIR}"

do_compile() {
	      /usr/local/go/bin/go build helloworld.go
}

do_install() {
	     install -d ${D}${bindir}
             install -m 0755 helloworld ${D}/${bindir}
}

