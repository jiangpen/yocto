FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}-${PV}:"

#
# This .bbappend doesn't yet do anything - replace this text with
# modifications to the example_0.1.bb recipe, or whatever recipe it is
# that you want to modify with this .bbappend (make sure you change
# the recipe name (PN) and version (PV) to match).
#
do_install_append(){

    #echo "MM:12345:respawn:/usr/sbin/helloworld" >> ${D}${sysconfdir}/inittab

}
