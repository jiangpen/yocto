
FILESEXTRAPATHS_prepend := "${THISDIR}/${PV}:"
THISDIRSAVED := "${THISDIR}"

do_install() {
    install -d                          ${D}${sysconfdir}
    install -m 0644 ${WORKDIR}/inittab  ${D}${sysconfdir}
}

FILES_${PN} += "${sysconfdir}/inittab"

pkg_postinst_${PN} () {
    echo "Empty"
}
